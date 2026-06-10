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
  subnetIds:
  - subnet-0000000000000000a
  - subnet-0000000000000000b
```

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
| `encryptionEnabled` | `true` |
| `oidc.enabled` | `true` |
| `fargate.enabled` | `true` |
| `fargate.profileName` | `bootstrap` |
| `karpenter.enabled` | `true` |
| `karpenter.namespace` | `karpenter` |
| `karpenter.chartVersion` | `1.12.1` |
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
