terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "remote" {
    organization = "lyle_terraform_test"

    workspaces {
      name = "Cloud_terraform_test"
    }
  }
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL for sending notifications"
  type        = string
}

resource "null_resource" "notify_slack" {
  provisioner "local-exec" {
    command = <<EOT
      curl -X POST -H 'Content-type: application/json' \
      --data '{
        "text": "Terraform Outputs: \n
        [Instances]\n 
        ${jsonencode(output.instances_info)} \n\n


        [RDS Endpoint]\n 
        ${output.rds_endpoint}\n\n
        
        
        [ECR Repository URLs] 
        ${jsonencode(output.ecr_repository_urls)} \n\n


        [DynamoDB Tables Info] 
        ${jsonencode(output.dynamodb_tables_info)}"
      }' \
      ${var.slack_webhook_url}
    EOT
  }

  depends_on = [module.ec2_instance, module.rds, module.ecr, module.dynamodb_tables]
}