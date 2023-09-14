terraform {
  backend "s3" {
    bucket = "<<YOUR_S3_BUCKET_NAME>>"        # my-s3-bucket
    key    = "emarket/terraform.tfstate"
    region = "<<YOUR_S3_BUCKET_REGION>>"      # us-east-1, us-west-2 
  }
  required_version = ">=1.1.3"
}

provider "aws" {
  region = var.aws_region
}

