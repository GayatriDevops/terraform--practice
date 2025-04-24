variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "custom-vpc"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the custom VPC"
  type        = string
  
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  
}

# variable "tags" {
#   description = "A map of common tags to assign to resources"
#   type        = map(string)
  
# }
