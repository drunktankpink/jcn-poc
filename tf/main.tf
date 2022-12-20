# vpc
module "vpc" {
  source = "./modules/vpc"

  vpc_name          = "jcn-poc"
  resource_location = "eu-west-2"
  vpc_cidr_block    = "172.16.0.0/16"
}

resource "aws_iam_role" "ecs_exe_role" {
  name               = "ecs-execution-role"
  path               = "/system/"
  assume_role_policy = "arn:aws:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
}  

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  service_name = "jcn-poc"
}  

module "ecs_task" {
  source = "./modules/ecs-task"

  service_name = "jcn-poc"
  cluster_id = module.ecs_cluster.cluster_id
  task_exe_role = aws_iam_role.ecs_exe_role.arn
} 
  
module "loadbalancer" {
  source = "./modules/load-balancer"

  service_name = "jcn-poc"
  vpc_id = module.vpc.id
  subnets = module.vpc.public_subnet_id
  security_groups = module.vpc.security_group_id
  lb_port = 80
  ecs_target_id = module.ecs_task.service_id
}
