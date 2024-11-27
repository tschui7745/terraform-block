# apply using cli arguments
terraform apply -var="name=tschui"  -var="vpc_id=vpc-067f3ab097282bc4d" -var="subnet_id=subnet-0021081c508245985"

# apply using tfvars file
terraform apply -var-file=dev.tfvars

# show outputs
terraform output
terraform output -json
terraform output -raw public_ip