terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-storage-us-east-2"
    dynamodb_table = "terraform-state-lock-dynamo-us-east-2"
    region = "us-east-2"
    key = "terraform.tfstate"
  }
}