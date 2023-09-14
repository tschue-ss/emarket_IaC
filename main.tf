
module "vpc" {
  source          = "./vpc_module"
  resource_prefix = var.resource_prefix
  cluster_name    = var.cluster_name
}


module "eks" {
  source = "./eks_module"

  resource_prefix   = var.resource_prefix
  cluster_name      = var.cluster_name
  cluster_node_name = var.cluster_node_name
  node_type         = var.node_type
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size
  node_min_size     = var.node_min_size
  aws_region        = var.aws_region

  vpc_id     = module.vpc.vpc_id
  subnet_id1 = module.vpc.private_subnet_id[0]
  subnet_id2 = module.vpc.private_subnet_id[1]
}


module "data" {
  source          = "./data_module"
  resource_prefix = var.resource_prefix

  mariadb_version          = var.mariadb_version
  mariadb_storage          = var.mariadb_storage
  mariadb_port             = var.mariadb_port
  mariadb_name             = var.mariadb_name
  mariadb_instance_class   = var.mariadb_instance_class
  mariadb_master_user_name = var.mariadb_master_user_name
  redis_port               = var.redis_port
  redis_node_type          = var.redis_node_type

  vpc_id     = module.vpc.vpc_id
  subnet_id1 = module.vpc.private_subnet_id[0]
  subnet_id2 = module.vpc.private_subnet_id[1]
}

