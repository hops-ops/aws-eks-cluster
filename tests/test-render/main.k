import models.ai.com.ops.hops.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_ready = [{type = "Ready", status = "True", reason = "Available"}]

_control_plane_role = {
    apiVersion = "iam.aws.m.upbound.io/v1beta1"
    kind = "Role"
    metadata = {
        name = "test-cluster-controlplane"
        annotations = {
            "crossplane.io/composition-resource-name" = "iam-role-controlplane"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "iam-role-controlplane"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:iam::123456789012:role/test-cluster-controlplane"
            id = "test-cluster-controlplane"
            name = "test-cluster-controlplane"
        }
    }
}

_node_role = {
    apiVersion = "iam.aws.m.upbound.io/v1beta1"
    kind = "Role"
    metadata = {
        name = "test-cluster-node"
        annotations = {
            "crossplane.io/composition-resource-name" = "iam-role-node"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "iam-role-node"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:iam::123456789012:role/test-cluster-node"
            id = "test-cluster-node"
            name = "test-cluster-node"
        }
    }
}

_fargate_role = {
    apiVersion = "iam.aws.m.upbound.io/v1beta1"
    kind = "Role"
    metadata = {
        name = "test-cluster-fargate"
        annotations = {
            "crossplane.io/composition-resource-name" = "iam-role-fargate"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "iam-role-fargate"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:iam::123456789012:role/test-cluster-fargate"
            id = "test-cluster-fargate"
            name = "test-cluster-fargate"
        }
    }
}

_kms_key = {
    apiVersion = "kms.aws.m.upbound.io/v1beta1"
    kind = "Key"
    metadata = {
        name = "test-cluster-secrets"
        annotations = {
            "crossplane.io/composition-resource-name" = "kms-key"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "kms-key"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
            keyId = "12345678-1234-1234-1234-123456789012"
        }
    }
}

_queue = {
    apiVersion = "sqs.aws.m.upbound.io/v1beta1"
    kind = "Queue"
    metadata = {
        name = "test-cluster-karpenter"
        annotations = {
            "crossplane.io/composition-resource-name" = "karpenter-queue"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "karpenter-queue"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:sqs:us-east-1:123456789012:test-cluster"
            url = "https://sqs.us-east-1.amazonaws.com/123456789012/test-cluster"
        }
    }
}

_cluster = {
    apiVersion = "eks.aws.m.upbound.io/v1beta1"
    kind = "Cluster"
    metadata = {
        name = "test-cluster"
        annotations = {
            "crossplane.io/composition-resource-name" = "cluster"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "cluster"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            endpoint = "https://ABCDEF1234567890.gr7.us-east-1.eks.amazonaws.com"
            id = "test-cluster"
            identity = [{oidc = [{issuer = "https://oidc.eks.us-east-1.amazonaws.com/id/ABCDEF1234567890"}]}]
            status = "ACTIVE"
            vpcConfig = {
                clusterSecurityGroupId = "sg-0123456789abcdef0"
                subnetIds = ["subnet-aaa", "subnet-bbb"]
            }
        }
    }
}

_cluster_auth = {
    apiVersion = "eks.aws.m.upbound.io/v1beta1"
    kind = "ClusterAuth"
    metadata = {
        name = "test-cluster"
        annotations = {
            "crossplane.io/composition-resource-name" = "cluster-auth"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "cluster-auth"
        }
    }
    status.conditions = _ready
}

_oidc_provider = {
    apiVersion = "iam.aws.m.upbound.io/v1beta1"
    kind = "OpenIDConnectProvider"
    metadata = {
        name = "test-cluster"
        annotations = {
            "crossplane.io/composition-resource-name" = "oidc-provider"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "oidc-provider"
        }
    }
    status = {
        conditions = _ready
        atProvider.arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/ABCDEF1234567890"
    }
}

_fargate_profile = {
    apiVersion = "eks.aws.m.upbound.io/v1beta1"
    kind = "FargateProfile"
    metadata = {
        name = "test-cluster-bootstrap"
        annotations = {
            "crossplane.io/composition-resource-name" = "fargate-profile"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "fargate-profile"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            arn = "arn:aws:eks:us-east-1:123456789012:fargateprofile/test-cluster/bootstrap/1234567890"
            id = "test-cluster:bootstrap"
        }
    }
}

_karpenter_irsa = {
    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
    kind = "IRSA"
    metadata = {
        name = "test-cluster-karpenter"
        annotations = {
            "crossplane.io/composition-resource-name" = "karpenter-irsa"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "karpenter-irsa"
        }
    }
    status = {
        conditions = _ready
        role = {
            arn = "arn:aws:iam::123456789012:role/test-cluster-karpenter"
            name = "test-cluster-karpenter"
        }
    }
}

_ebs_irsa = {
    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
    kind = "IRSA"
    metadata = {
        name = "test-cluster-ebs-csi"
        annotations = {
            "crossplane.io/composition-resource-name" = "ebs-csi-irsa"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "ebs-csi-irsa"
        }
    }
    status = {
        conditions = _ready
        role = {
            arn = "arn:aws:iam::123456789012:role/test-cluster-ebs-csi"
            name = "test-cluster-ebs-csi"
        }
    }
}

_karpenter_namespace = {
    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
    kind = "Object"
    metadata = {
        name = "test-cluster-karpenter-namespace"
        annotations = {
            "crossplane.io/composition-resource-name" = "karpenter-namespace"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "karpenter-namespace"
        }
    }
    status.conditions = _ready
}

_karpenter_release = {
    apiVersion = "helm.m.crossplane.io/v1beta1"
    kind = "Release"
    metadata = {
        name = "test-cluster-karpenter"
        annotations = {
            "crossplane.io/composition-resource-name" = "karpenter-release"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "karpenter-release"
        }
    }
    status = {
        conditions = _ready
        atProvider = {
            revision = 1
            state = "deployed"
        }
    }
}

_ebs_addon = {
    apiVersion = "eks.aws.m.upbound.io/v1beta1"
    kind = "Addon"
    metadata = {
        name = "test-cluster-ebs-csi"
        annotations = {
            "crossplane.io/composition-resource-name" = "addon-ebs-csi"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "addon-ebs-csi"
        }
    }
    status = {
        conditions = _ready
        atProvider.id = "test-cluster:aws-ebs-csi-driver"
    }
}

_coredns_addon = {
    apiVersion = "eks.aws.m.upbound.io/v1beta1"
    kind = "Addon"
    metadata = {
        name = "test-cluster-coredns"
        annotations = {
            "crossplane.io/composition-resource-name" = "addon-coredns"
            "gotemplating.fn.crossplane.io/composition-resource-name" = "addon-coredns"
        }
    }
    status = {
        conditions = _ready
        atProvider.id = "test-cluster:coredns"
    }
}

_base_spec = {
    clusterName = "test-cluster"
    region = "us-east-1"
    accountId = "123456789012"
    version = "1.35"
    subnetIds = ["subnet-aaa", "subnet-bbb"]
}

_bootstrap_observed = [_control_plane_role, _node_role, _fargate_role, _kms_key, _queue]
_cluster_observed = _bootstrap_observed + [_cluster, _cluster_auth, _oidc_provider, _fargate_profile]
_ready_observed = _cluster_observed + [_karpenter_irsa, _ebs_irsa, _karpenter_namespace, _coredns_addon, _karpenter_release, _ebs_addon]

_items = [
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-bootstrap-primitives"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "test-cluster"
                spec = _base_spec
            }
            assertResources = [
                {apiVersion = "iam.aws.m.upbound.io/v1beta1", kind = "Role", metadata.name = "test-cluster-controlplane"}
                {apiVersion = "iam.aws.m.upbound.io/v1beta1", kind = "Role", metadata.name = "test-cluster-node"}
                {apiVersion = "iam.aws.m.upbound.io/v1beta1", kind = "Role", metadata.name = "test-cluster-fargate"}
                {apiVersion = "sqs.aws.m.upbound.io/v1beta1", kind = "Queue", metadata.name = "test-cluster-karpenter"}
                {apiVersion = "kms.aws.m.upbound.io/v1beta1", kind = "Key", metadata.name = "test-cluster-secrets"}
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "cluster-renders-after-iam-and-kms"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "test-cluster"
                spec = _base_spec
            }
            observedResources = _bootstrap_observed
            assertResources = [
                {
                    apiVersion = "eks.aws.m.upbound.io/v1beta1"
                    kind = "Cluster"
                    metadata.name = "test-cluster"
                    spec.forProvider = {
                        accessConfig = {
                            authenticationMode = "API"
                            bootstrapClusterCreatorAdminPermissions = True
                        }
                        bootstrapSelfManagedAddons = False
                        roleArnRef.name = "test-cluster-controlplane"
                        version = "1.35"
                        vpcConfig = {
                            endpointPrivateAccess = True
                            endpointPublicAccess = False
                            subnetIds = ["subnet-aaa", "subnet-bbb"]
                        }
                    }
                }
                {
                    apiVersion = "iam.aws.m.upbound.io/v1beta1"
                    kind = "RolePolicyAttachment"
                    metadata.name = "test-cluster-node-worker"
                    spec.forProvider.policyArn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "platform-renders-after-cluster"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "test-cluster"
                spec = _base_spec
            }
            observedResources = _cluster_observed
            assertResources = [
                {
                    apiVersion = "eks.aws.m.upbound.io/v1beta1"
                    kind = "FargateProfile"
                    metadata.name = "test-cluster-bootstrap"
                    spec.forProvider.selector = [
                        {namespace = "karpenter"}
                        {namespace = "kube-system", labels = {"k8s-app" = "kube-dns"}}
                    ]
                }
                {
                    apiVersion = "eks.aws.m.upbound.io/v1beta1"
                    kind = "Addon"
                    metadata.name = "test-cluster-coredns"
                    spec.forProvider = {
                        addonName = "coredns"
                        configurationValues = "{\"computeType\":\"Fargate\"}"
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "IRSA"
                    metadata.name = "test-cluster-karpenter"
                    spec.serviceAccount = {
                        name = "karpenter"
                        namespace = "karpenter"
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "karpenter-capacity-after-release"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "test-cluster"
                spec = _base_spec
            }
            observedResources = _ready_observed
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "test-cluster-karpenter"
                    spec.forProvider = {
                        chart = {
                            name = "karpenter"
                            repository = "oci://public.ecr.aws/karpenter"
                            version = "1.12.1"
                        }
                        values.settings = {
                            clusterName = "test-cluster"
                            interruptionQueue = "test-cluster"
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "test-cluster-karpenter-namespace"
                    spec.forProvider.manifest = {
                        kind = "Namespace"
                        metadata.name = "karpenter"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "test-cluster-hops-default"
                    spec.forProvider.manifest = {
                        apiVersion = "karpenter.k8s.aws/v1"
                        kind = "EC2NodeClass"
                        spec.role = "test-cluster-node"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "test-cluster-hops-apps"
                    spec.forProvider.manifest.spec.template.spec.nodeClassRef = {
                        group = "karpenter.k8s.aws"
                        kind = "EC2NodeClass"
                        name = "hops-default"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "test-cluster-default-storage-class"
                    spec.forProvider.manifest = {
                        kind = "StorageClass"
                        provisioner = "ebs.csi.aws.com"
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "explicit-false-defaults-allow-cluster-without-kms"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "test-cluster"
                spec = {
                    clusterName = "test-cluster"
                    region = "us-east-1"
                    accountId = "123456789012"
                    version = "1.35"
                    subnetIds = ["subnet-aaa", "subnet-bbb"]
                    encryptionEnabled = False
                    fargate.enabled = False
                    oidc.enabled = False
                    storage.defaultClass.enabled = False
                }
            }
            observedResources = [_control_plane_role, _node_role, _fargate_role]
            assertResources = [
                {
                    apiVersion = "eks.aws.m.upbound.io/v1beta1"
                    kind = "Cluster"
                    metadata.name = "test-cluster"
                    spec.forProvider.vpcConfig = {
                        endpointPrivateAccess = True
                        endpointPublicAccess = False
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "import-management-policies-preserved"
        spec = {
            compositionPath = "apis/eksclusters/composition.yaml"
            xrdPath = "apis/eksclusters/definition.yaml"
            timeoutSeconds = 120
            validate = False
            xr = awsv1alpha1.EKSCluster {
                metadata.name = "imported"
                spec = {
                    clusterName = "existing"
                    region = "us-east-1"
                    accountId = "123456789012"
                    version = "1.35"
                    subnetIds = ["subnet-aaa", "subnet-bbb"]
                    managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                    iam.controlPlaneRole.externalName = "existing-controlplane"
                }
            }
            assertResources = [
                {
                    apiVersion = "iam.aws.m.upbound.io/v1beta1"
                    kind = "Role"
                    metadata.name = "existing-controlplane"
                    spec.managementPolicies = ["Create", "Observe", "Update", "LateInitialize"]
                }
            ]
        }
    }
]

items = _items
