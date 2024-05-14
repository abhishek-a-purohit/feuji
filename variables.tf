variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "us-west-1"
}

# Note: The following AWS credential variables are intentionally omitted.
# It is recommended to manage AWS credentials using the AWS CLI configured profiles 
# or environment variables. Use 'aws configure' to set up your credential file securely 
# or set the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN 
# environment variables for your session.

# Original validation logic, which was incorrect and now commented for reference
# variable "vpc_cidr" {
#   description = "The IPv4 CIDR block to use for the VPC"
#   type        = string
#   default     = "192.170.0.0/20"
#   validation {
#     condition     = tonumber(split("/", var.vpc_cidr)[1]) <= 20 && tonumber(split("/", var.vpc_cidr)[1]) >= 16
#     error_message = "CIDR size must be at least /20 and no larger than /16"
#   }
# }

# Corrected version
variable "vpc_cidr" {
  description = "The IPv4 CIDR block to use for the VPC"
  type        = string
  default     = "192.170.0.0/20"
  validation {
    condition     = (
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 && 
      tonumber(split("/", var.vpc_cidr)[1]) <= 20
    )
    error_message = "CIDR size must be at least /20 and no larger than /16."
  }
}
