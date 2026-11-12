# aws-eks-cluster

`EKSCluster` creates a standard Amazon EKS cluster for Hops workloads. It uses
Fargate only as bootstrap capacity for Karpenter and CoreDNS, then installs
Karpenter to provision EC2 nodes through `EC2NodeClass` and `NodePool` objects.

## What It Creates

- EKS cluster with API authentication mode.
- IAM roles for the control plane, Karpenter nodes, and Fargate pod execution.
- Optional KMS key for Kubernetes secrets encryption.
- IAM OIDC provider plus child `IRSA` XRs for Karpenter and the EBS CSI add-on.
- Fargate profile for the Karpenter namespace and CoreDNS pods.
- Core EKS add-ons: VPC CNI, CoreDNS, kube-proxy, EKS Pod Identity Agent, and EBS CSI.
- SQS/EventBridge interruption queue wiring for Karpenter.
- Karpenter Helm release, default `EC2NodeClass`, optional storage-NVMe `EC2NodeClass`, and default `NodePool`.
- Child Kubernetes and Helm `ProviderConfig` objects backed by the cluster kubeconfig.
- Default `hops-default` `StorageClass` using the EBS CSI provisioner.

## Minimal

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: EKSCluster
metadata:
  name: minimal
  namespace: default
spec:
  clusterName: minimal
  region: us-east-2
  accountId: "123456789012"
  version: "1.35"
  ipFamily: ipv6
  subnetIds:
  - subnet-0000000000000000a
  - subnet-0000000000000000b
```

For IPv6 clusters, the VPC must have both IPv4 and IPv6 CIDRs. Each node
subnet must have an IPv6 CIDR and automatically assign IPv6 addresses, and the
cluster must use VPC CNI version 1.10.1 or newer.

## Standard

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: EKSCluster
metadata:
  name: standard
  namespace: default
spec:
  clusterName: standard
  region: us-east-2
  accountId: "123456789012"
  version: "1.35"
  subnetIds:
  - subnet-0000000000000000a
  - subnet-0000000000000000b
  adminRoleArn: arn:aws:iam::123456789012:role/Admin
  tags:
    Environment: test
  karpenter:
    nodeClasses:
      storageNvme:
        enabled: true
        instanceStorePolicy: RAID0
        amiSelectorTerms:
        - alias: al2023@latest
    nodePools:
      default:
        limits:
          cpu: "4"
```

## Import

Use `managementPolicies` without `Delete` when adopting existing cluster
resources.

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: EKSCluster
metadata:
  name: imported
  namespace: default
spec:
  managementPolicies: [Create, Observe, Update, LateInitialize]
  externalName: existing-standard-cluster
  clusterName: existing-standard-cluster
  region: us-east-2
  accountId: "123456789012"
  version: "1.35"
  ipFamily: ipv4
  subnetIds:
  - subnet-0000000000000000a
  - subnet-0000000000000000b
  iam:
    controlPlaneRole:
      externalName: existing-standard-cluster-controlplane
    nodeRole:
      externalName: existing-standard-cluster-node
  fargate:
    podExecutionRole:
      externalName: existing-standard-cluster-fargate
  kms:
    externalName: 12345678-1234-1234-1234-123456789012
  oidc:
    externalName: arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/EXAMPLE
```

## Defaults

| Field | Default |
| --- | --- |
| `privateAccess` | `true` |
| `publicAccess` | `false` |
| `ipFamily` | `ipv4` |
| `encryptionEnabled` | `true` |
| `oidc.enabled` | `true` |
| `fargate.enabled` | `true` |
| `fargate.profileName` | `bootstrap` |
| `fargate.subnetIds` | All cluster subnets; independent of EKS control-plane placement. |
| `karpenter.enabled` | `true` |
| `karpenter.namespace` | `karpenter` |
| `karpenter.chartVersion` | `1.15.1` |
| `karpenter.interruptionQueue.enabled` | `true` |
| `karpenter.nodeClasses.default.name` | `hops-default` |
| `karpenter.nodePools.default.name` | `hops-apps` |
| `addons.*.enabled` | `true` |
| `addons.coredns.configurationValues` | `{"computeType":"Fargate"}` |
| `storage.defaultClass.enabled` | `true` |

Default Karpenter requirements use spot capacity, Linux, and the
`karpenter.k8s.aws/instance-category` and
`karpenter.k8s.aws/instance-generation` labels.

## Test

```sh
make render:all
make validate:all
make test
```


## Single-AZ Fargate placement and migration

Set `fargate.subnetIds` to an existing private subnet in the desired worker/NAT AZ.
This affects only the Fargate profile; `subnetIds`/`subnetSelector` still configure
the EKS control plane. Omitted or empty Fargate subnet IDs preserve the previous
all-cluster-subnets behavior. Keep the worker NodePool zone aligned separately.

```yaml
fargate:
  profileName: a-bootstrap
  subnetIds: [subnet-0000000000000000a]
```

[AWS Fargate profiles are immutable](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html).
For an existing cluster, select a new `profileName` along with the subnet override.
The new explicit-subnet profile gets its own composition resource key and Usage
identities; the existing Karpenter Helm release stays rendered while it becomes
ready. The cluster, execution role and unrelated resources keep their identities.
Keep `Delete` excluded from the XR's managementPolicies while migrating so the old
cloud profile is retained when its composed resource is retired. Do not try to
mutate the subnet list of a running `bootstrap` profile in place.

Wait for the new profile to be ACTIVE. Label the CoreDNS/Karpenter pod templates
with `eks.amazonaws.com/fargate-profile: a-bootstrap`, or use a name that sorts
before the old profile as AWS documents; recycle replicas one at a time and verify
their actual node AZ/profile and readiness. Retire the unused old AWS profile only
after no pod uses it. No DNS/Karpenter interruption or full migration is implied
by a matching render test. Pin an existing Karpenter chart version explicitly when
upgrading this configuration solely for placement support.
