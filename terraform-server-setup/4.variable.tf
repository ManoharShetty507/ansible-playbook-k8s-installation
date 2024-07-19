variable "instance_ami_type" {
  description = "The Image ID to be used"
  type        = string
  default     = "ami-03bb6d83c60fc5f7c"

}

variable "region" {
  description = "The regions used"
  type        = string
  default     = "ap-south-1"

}

variable "instance_type_bastion" {
  description = "Instance type for the dev instance"
  type        = string
  default     = "t2.medium"
}

variable "instance_type_master" {
  description = "Instance type for the test instance"
  type        = string
  default     = "t2.medium"
}

variable "instance_type_lb" {
  description = "Instance type for the prod instance"
  type        = string
  default     = "t2.medium"
}
