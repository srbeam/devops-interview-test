module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "devops-eks-cluster"
  cluster_version = "1.31" 

# Enable Public Access to API Endpoint
  cluster_endpoint_public_access = true

  subnet_ids = module.vpc.private_subnets  #Private Subnets from VPC
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true  

  eks_managed_node_groups = { 
    eks_nodes = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

