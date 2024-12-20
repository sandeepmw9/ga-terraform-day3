terraform {
    backend "s3" {
      bucket = "tfstate1224"
      key    = "terraform_state_store"
      region = "ap-south-1"
      dynamodb_table = "tfstate-locking"
      encrypt = true
    }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }

  }
}
