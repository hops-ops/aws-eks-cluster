# E2E Test for EKSCluster
# =======================
# Tests EKSCluster creation using the persistent hops-test network.
#
# This test creates:
# 1. An EKSCluster using subnet IDs from the persistent hops-test network
#
# Uses persistent network infrastructure from aws-network e2e test (hops-test)
# to speed up test execution by avoiding network creation/deletion.
#
# Prerequisites:
# 1. Create secrets/aws-creds file with AWS credentials in INI format:
#    [default]
#    aws_access_key_id = AKIA...
#    aws_secret_access_key = ...
#
# 2. Ensure the persistent hops-test network exists (from aws-network e2e test)
#
# 3. Run: make e2e

import base64
import file
import datetime
import math
import models.ai.com.ops.hops.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dev.meta.v2alpha1 as metav2alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# Read AWS credentials from local file (gitignored)
_creds = file.read("secrets/aws-creds")
_base64_creds = base64.encode(_creds)

# =============================================================================
# Test Configuration
# =============================================================================
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-eks-" + _now
_namespace = "default"
_region = file.read("env/AWS_REGION").strip()
_account_id = file.read("env/AWS_ACCOUNT_ID").strip()
_admin_role_arn = file.read("env/ADMIN_ROLE_ARN").strip()

# =============================================================================
# Persistent Network Infrastructure (from aws-network e2e test - hops-test)
# =============================================================================
# Private subnet IDs for the EKS cluster - these are already created and orphaned
_private_subnet_ids = [
    file.read("env/PRIVATE_SUBNET_ID_A").strip()
    file.read("env/PRIVATE_SUBNET_ID_B").strip()
]

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "ekscluster"
        spec = {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            timeoutSeconds = 5400  # 90 minutes for EKS cluster creation
            cleanupTimeoutSeconds = 1800  # 30 minutes for cleanup
            skipDelete = False

            extraResources = [
                {
                    apiVersion = "v1"
                    kind = "Secret"
                    metadata = {
                        name = "aws-creds"
                        namespace = _namespace
                    }
                    data = {
                        creds = _base64_creds
                    }
                }

                {
                    apiVersion = "aws.m.upbound.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = _namespace
                    }
                    spec = {
                        credentials = {
                            source = "Secret"
                            secretRef = {
                                namespace = _namespace
                                name = "aws-creds"
                                key = "creds"
                            }
                        }
                    }
                }

                # Kubernetes ProviderConfig for account ProviderConfig Objects
                # Uses InjectedIdentity for in-cluster access
                {
                    apiVersion: "kubernetes.m.crossplane.io/v1alpha1"
                    kind: "ProviderConfig"
                    metadata: {
                        name: "default"
                        namespace: "default"
                    }
                    spec: {
                        credentials: {
                            source: "InjectedIdentity"
                        }
                    }
                },
                # DeploymentRuntimeConfig for Kubernetes provider with known SA name
                {
                    apiVersion: "pkg.crossplane.io/v1beta1"
                    kind: "DeploymentRuntimeConfig"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                    }
                    spec: {
                        serviceAccountTemplate: {
                            metadata: {
                                name: "crossplane-contrib-provider-kubernetes"
                            }
                        }
                    }
                },
                # ServiceAccount for Kubernetes provider
                {
                    apiVersion: "v1"
                    kind: "ServiceAccount"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                        namespace: "crossplane-system"
                    }
                },
                # ClusterRoleBinding granting cluster-admin to the K8s provider SA
                {
                    apiVersion: "rbac.authorization.k8s.io/v1"
                    kind: "ClusterRoleBinding"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes-admin"
                    }
                    roleRef: {
                        apiGroup: "rbac.authorization.k8s.io"
                        kind: "ClusterRole"
                        name: "cluster-admin"
                    }
                    subjects: [
                        {
                            kind: "ServiceAccount"
                            name: "crossplane-contrib-provider-kubernetes"
                            namespace: "crossplane-system"
                        }
                    ]
                },
                # Provider with runtimeConfigRef to use our DeploymentRuntimeConfig
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Provider"
                    metadata: {
                        name: "crossplane-contrib-provider-kubernetes"
                    }
                    spec: {
                        package: "xpkg.crossplane.io/crossplane-contrib/provider-kubernetes:v1.2.0"
                        runtimeConfigRef: {
                            name: "crossplane-contrib-provider-kubernetes"
                        }
                    }
                }
            ]

            # manifests: EKSCluster (applied after initResources are Ready)
            # Uses persistent hops-test network - no Network manifest needed
            # Resources created in manifests are deleted during cleanup
            manifests = [
                awsv1alpha1.EKSCluster {
                    metadata = {
                        name = _test_name
                        namespace = _namespace
                    }
                    spec = {
                        adminRoleArn = _admin_role_arn
                        clusterName = _test_name
                        region = _region
                        accountId = _account_id
                        version = "1.35"
                        # Use subnet IDs from persistent hops-test network
                        subnetIds = _private_subnet_ids
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        kubernetesProviderConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        tags = {
                            "e2etest" = "true"
                            "test-run" = _now
                        }
                        # Enable public endpoint so e2e test can reach cluster API
                        publicAccess = True
                        # Enable OIDC for Karpenter and add-on IRSA.
                        oidc = {
                            enabled = True
                        }
                        fargate = {
                            enabled = True
                        }
                        karpenter = {
                            enabled = True
                        }
                    }
                }
            ]
        }
    }
]

items = _items
