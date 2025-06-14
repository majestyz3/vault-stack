#!/bin/sh

terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

