terraform {
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
  
  default_tags {
    tags = {
        Region          = "eu-west-2"
        Environment     = "test"
        ProvisionedBy   = "terraform"
        ServiceName     = "jcn-poc"
    }
  }
}
