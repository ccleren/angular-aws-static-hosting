# Backend remoto: el bucket y la tabla DynamoDB deben existir ya, creados
# previamente por `infrastructure/bootstrap`. Terraform no permite variables
# en un bloque backend, así que estos valores hay que rellenarlos a mano
# (o pasarlos con `terraform init -backend-config=...`) para que coincidan
# con los outputs del bootstrap.
terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_STATE_BUCKET_NAME"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
