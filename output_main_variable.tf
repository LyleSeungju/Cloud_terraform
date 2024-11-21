# output_main_variable.tf

# 로컬 변수를 사용하여 출력 값을 한 곳에서 정의합니다.
locals {
  outputs = {
    instances_info = {
      for instance_name, instance in module.ec2_instance :
      instance_name => {
        instance_id  = instance.instance_id
        private_ip   = instance.instance_private_ip
        public_ip    = instance.instance_public_ip
      }
    }
    rds_endpoint = var.is_rds && length(module.rds) > 0 ? module.rds[0].rds_endpoint : null
    ecr_repository_urls = module.ecr.repository_urls
    dynamodb_tables_info = {
      for table_name, table in module.dynamodb_tables :
      table_name => {
        table_name = table.table_name
        table_arn  = table.table_arn
        table_id   = table.table_id
      }
    }
  }
}

# 출력 블록에서 로컬 변수를 사용하여 값을 출력합니다.
output "instances_info" {
  value       = local.outputs.instances_info
  description = "각 인스턴스 이름에 따른 EC2 인스턴스 정보 (ID, 사설 IP, 공인 IP)"
}

output "rds_endpoint" {
  value       = local.outputs.rds_endpoint
  description = "RDS 인스턴스의 엔드포인트"
}

output "ecr_repository_urls" {
  value       = local.outputs.ecr_repository_urls
  description = "각 ECR 리포지토리의 URL 목록"
}

output "dynamodb_tables_info" {
  value       = local.outputs.dynamodb_tables_info
  description = "생성된 DynamoDB 테이블 정보 목록"
}

# S3에 outputs.json 파일을 업로드하는 리소스입니다.
resource "aws_s3_object" "outputs" {
  bucket = module.s3_buckets["lyle_terraform_outputs"].bucket_id
  key    = "terraform/outputs.json"
  content = jsonencode(local.outputs)
  acl    = "private"  # 데이터 보호를 위해 파일 접근 권한 설정

  depends_on = [
    module.ec2_instance,
    module.rds,
    module.ecr,
    module.dynamodb_tables,
    module.s3_buckets
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}