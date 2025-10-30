module "networking" {
  source                    = "./modules/networking"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  env                       = var.env
}

module "ecs" {
  source                  = "./modules/ecs"
  env                     = var.env
  vpc_id                  = module.networking.vpc_id
  ecr_repository_name     = var.ecr_repository_name
  ecs_cluster_name        = var.ecs_cluster_name
  region                  = var.region
  operating_system_family = var.operating_system_family
  ecs_service_name        = var.ecs_service_name
  private_subnet_ids      = module.networking.private_subnet_ids
  ecs_container_memory    = var.ecs_container_memory
  ecs_container_cpu       = var.ecs_container_cpu
  ecs_task_cpu            = var.ecs_task_cpu
  ecs_task_memory         = var.ecs_task_memory
  container_name          = var.container_name
  container_port          = var.container_port
  desired_count           = var.desired_count
  dynamodb_table_name     = module.dynamodb.table_name
  cpu_architecture        = var.cpu_architecture
  alb_sg_id               = module.alb.alb_sg_id
  green_target_group_arn  = module.alb.green_target_group_arn
  kms_key_arn             = module.dynamodb.kms_key_arn

}

module "alb" {
  source            = "./modules/alb"
  env               = var.env
  vpc_id            = module.networking.vpc_id
  lb_name           = var.lb_name
  public_subnet_ids = module.networking.public_subnet_ids
  domain            = var.domain
}

module "dynamodb" {
  source = "./modules/dynamodb"
  env    = var.env
  region = var.region
}


module "endpoints" {
  source                  = "./modules/endpoints"
  env                     = var.env
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  private_route_table_ids = module.networking.private_route_table_ids
  ecs_task_sg_id          = module.ecs.ecs_task_sg_id
  region                  = var.region
}

module "route53" {
  source       = "./modules/route53"
  domain_name  = var.domain
  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
  record_name  = "ecs.${var.domain}"
}

module "codedeploy" {
  source                  = "./modules/codedeploy"
  env                     = var.env
  ecs_cluster_name        = var.ecs_cluster_name
  ecs_service_name        = var.ecs_service_name
  https_listener_arn      = module.alb.https_listener_arn
  blue_target_group_name  = module.alb.blue_target_group_name
  green_target_group_name = module.alb.green_target_group_name
}

module "autoscaling" {
  source           = "./modules/autoscaling"
  ecs_cluster_name = var.ecs_cluster_name
  ecs_service_name = var.ecs_service_name
  max_capacity     = var.max_capacity
  min_capacity     = var.min_capacity
  env              = var.env
}

module "waf" {
  source       = "./modules/waf"
  env          = var.env
  region       = var.region
  resource_arn = module.alb.alb_arn
}

//module "cloudfront" {
//  source = "./modules/cloudfront"
//}