variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "hash_key" {
  description = "Partition key name"
  type        = string
}

variable "hash_key_type" {
  description = "Partition key type (S, N, B)"
  type        = string
  default     = "S"
}

variable "enable_point_in_time_recovery" {
  description = "Enable PITR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for table"
  type        = map(string)
  default     = {}
}

# ---- Optional GSI ----
variable "gsi_name" {
  type    = string
  default = null
}

variable "gsi_hash_key" {
  type    = string
  default = null
}
