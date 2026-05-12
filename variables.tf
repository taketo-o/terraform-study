#####################################################
# variables.tf
#####################################################
variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "CloudWatch SNS notification email"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair Name"
  type        = string
}