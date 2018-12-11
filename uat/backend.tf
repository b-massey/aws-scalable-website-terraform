terraform {
  backend "s3" {
    bucket = "bm-terraform-testsite"
    key    = "tfstate/uat/terraform.tfstate"
    region = "eu-west-2"
  }
}