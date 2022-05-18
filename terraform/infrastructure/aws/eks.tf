module "eks" {
  depends_on      = [module.vpc]
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.21.0"
  cluster_name    = var.prefix
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets

  vpc_id           = module.vpc.vpc_id
  write_kubeconfig = false

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    hcp_consul = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_types            = ["t2.small"]
      k8s_labels                = var.tags
      additional_tags           = var.additional_tags
      key_name                  = var.key_pair_name
      source_security_group_ids = [module.boundary.boundary_security_group]
    }
  }
}

