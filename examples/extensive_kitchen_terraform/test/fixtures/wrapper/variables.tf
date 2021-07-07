variable "instances_ami" {
  description = <<EOD
The Amazon Machine Image (AMI) to use for the AWS EC2 instances of the module
EOD

  type = string
}

variable "subnet_availability_zone" {
  description = <<EOD
The isolated, regional location in which to place the subnet of the module
EOD

  type = string
}
