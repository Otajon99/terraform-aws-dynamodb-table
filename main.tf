provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  # Optional Global Secondary Index
  dynamic "global_secondary_index" {
    for_each = var.gsi_name != null ? [1] : []
    content {
      name            = var.gsi_name
      hash_key        = var.gsi_hash_key
      projection_type = "ALL"

      # GSI attribute definition
      write_capacity = null
      read_capacity  = null
    }
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = var.tags
}
