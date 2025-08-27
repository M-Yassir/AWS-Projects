# variables.tf
variable "db_password" {
  description = "The password for the database master user"
  type        = string
  sensitive   = true # This ensures the password is not shown in logs
}