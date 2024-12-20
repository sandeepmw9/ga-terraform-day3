#passing inputs to ec2 modules on module level

variable "instance_name" {} #variable will be passed from root module
variable "instance_type" {} #variable will be passed from root module
variable "public_subnet_id" {} #variable will be passed vpc child module
variable "vpc_id" {}
