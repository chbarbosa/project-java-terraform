variable "db_password" {
  description = "database pass"
  type        = string
  sensitive   = true 
}

variable "sqs_visibility_timeout" {
  description = "Visibily time"
  type        = number
  default     = 30
  
  validation {
    condition     = var.sqs_visibility_timeout <= 43200
    error_message = "SQS timeout cannot exceed 43200 seconds."
  }
}

variable "postgres_image" {
  type    = string
  default = "postgres:15-alpine"
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
  default   = "test_secret"
}