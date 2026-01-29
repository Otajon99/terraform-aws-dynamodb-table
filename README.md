# Terraform AWS DynamoDB Table Module - Step by Step Guide

## 🧩 STEP 1 — Provider

```hcl
provider "aws" {
  region = var.aws_region
}
```

Terraform connects to AWS in a region (default us-east-1).

All resources go there.

## 🗄 STEP 2 — Create DynamoDB Table

```hcl
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "global_secondary_index" {
    for_each = var.gsi_name != null ? [1] : []
    content {
      name     = var.gsi_name
      hash_key = var.gsi_hash_key
      projection_type = "ALL"
    }
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = var.tags
}
```

This is the actual database table.

### Table Name
```hcl
name = var.table_name
```

Example: "users-table"
This is what you see in AWS console.

### Billing Mode
```hcl
billing_mode = "PAY_PER_REQUEST"
```

🔥 Important.

Means:

- No capacity planning
- Auto scales
- Pay only when used

Perfect for modern serverless apps.

### Primary Key (Partition Key)
```hcl
hash_key = var.hash_key
```

DynamoDB tables MUST have a primary key.

Example:

```hcl
hash_key = "user_id"
```

Every item must have unique user_id.

### Key Type
```hcl
attribute {
  name = var.hash_key
  type = var.hash_key_type
}
```

Defines data type of key:

| Type | Meaning |
|------|---------|
| S | String |
| N | Number |
| B | Binary |

Default is "S".

## 📈 STEP 3 — Optional Global Secondary Index (GSI)

```hcl
dynamic "global_secondary_index" {
  for_each = var.gsi_name != null ? [1] : []
  content {
    name     = var.gsi_name
    hash_key = var.gsi_hash_key
    projection_type = "ALL"
  }
}
```

This is advanced and powerful.

DynamoDB normally lets you search by main key only.

GSI lets you query using another field.

### When does Terraform create it?
```hcl
for_each = var.gsi_name != null ? [1] : []
```

- If you pass a GSI name → index is created
- If not → Terraform skips it

### Example:
```hcl
gsi_name     = "customer-index"
gsi_hash_key = "customer_id"
```

Now you can query:

> "Give me all orders for customer_id = 123"

## ⏪ STEP 4 — Point In Time Recovery (PITR)

```hcl
point_in_time_recovery {
  enabled = var.enable_point_in_time_recovery
}
```

This is like database time machine 🕒

If someone deletes data, you can restore to any second in past.

Default = enabled (very good practice).

## 🏷 STEP 5 — Tags

```hcl
tags = var.tags
```

Used for:

- Cost tracking
- Environment labels
- Organization

Example:

```hcl
tags = {
  Environment = "prod"
  Team        = "devops"
}
```

## 📤 STEP 6 — Outputs

```hcl
output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN (if enabled)"
  value       = aws_dynamodb_table.this.stream_arn
}
```

After creation Terraform gives:

| Output | Why useful |
|--------|------------|
| table_id | Internal ID |
| table_arn | Needed for IAM permissions |
| table_name | Reference elsewhere |
| table_stream_arn | For Lambda triggers |

## 🔄 FULL FLOW

```
Terraform → AWS:
    ↓
Connect region
    ↓
Create DynamoDB table
    ↓
Define primary key
    ↓
Optionally create GSI
    ↓
Enable backup recovery
    ↓
Apply tags
    ↓
Return table info
```

## 🧠 How This Works With Your Architecture

| Service | Role |
|---------|------|
| API Gateway | Receives request |
| Lambda | Processes logic |
| DynamoDB | Stores data |

### Example:

User signs up → Lambda stores user in DynamoDB using user_id.

## 🚀 What Makes DynamoDB Powerful

| Feature | Benefit |
|---------|---------|
| Serverless | No DB servers |
| Auto scaling | Handles traffic spikes |
| Millisecond latency | Very fast |
| PITR | Disaster recovery |

## ✅ You've now built:

- ✅ Compute (EC2/Lambda)
- ✅ Serverless (Lambda)
- ✅ Database (DynamoDB)

That's complete cloud application infrastructure 💪

## 📋 Complete Module Structure

```
terraform-aws-dynamodb-table/
├── providers.tf           # AWS provider
├── variables.tf           # Input variables
├── main.tf               # DynamoDB table
├── outputs.tf            # Output values
└── README.md             # Documentation
```

## 📝 Variables

```hcl
variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "hash_key" {
  description = "Primary key attribute name"
  type        = string
}

variable "hash_key_type" {
  description = "Primary key attribute type (S, N, B)"
  type        = string
  default     = "S"
}

variable "gsi_name" {
  description = "Global Secondary Index name (optional)"
  type        = string
  default     = null
}

variable "gsi_hash_key" {
  description = "GSI hash key attribute name"
  type        = string
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}

variable "student_name" {
  description = "Student's GitHub username"
  type        = string
}
```

## 🧠 Key Concepts to Remember

### 1. **DynamoDB = NoSQL Database**
- Schemaless design
- Document/key-value store
- Fully managed by AWS

### 2. **Primary Key = Unique Identifier**
- Every item must have one
- Can't be changed after creation
- Determines data distribution

### 3. **Billing Modes**
- **PAY_PER_REQUEST**: Serverless, auto-scaling
- **PROVISIONED**: Fixed capacity, cheaper at scale

### 4. **Global Secondary Index (GSI)**
- Alternative query patterns
- Separate primary key
- Additional cost but powerful

### 5. **Point In Time Recovery**
- 35-day backup window
- Per-second precision
- Automatic backups

### 6. **Attributes = Data Fields**
- No schema enforcement
- Can be any type
- Flexible data modeling

## ⚠️ Common Mistakes to Avoid

1. **Wrong Primary Key Design**
   - Can't query efficiently
   - Think about access patterns first

2. **Hot Partitioning**
   - Uneven data distribution
   - Performance degradation

3. **Ignoring Costs**
   - PAY_PER_REQUEST can be expensive
   - Monitor usage patterns

4. **No Error Handling**
   - Throttling is common
   - Implement retry logic

5. **Wrong Data Types**
   - Can't change after table creation
   - Plan your schema carefully

## 🔍 Troubleshooting Commands

```bash
# List tables
aws dynamodb list-tables

# Describe table
aws dynamodb describe-table --table-name my-table

# Query table
aws dynamodb query \
  --table-name my-table \
  --key-condition-expression "user_id = :uid" \
  --expression-attribute-values '{":uid":{"S":"123"}}'

# Scan table (expensive!)
aws dynamodb scan --table-name my-table

# Check table metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=my-table
```

## 🚀 Next Big Step

👉 **Give your Lambda permission to read/write this DynamoDB table (IAM policy).**

```hcl
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name = "${var.function_name}-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          module.dynamodb.table_arn,
          "${module.dynamodb.table_arn}/*"
        ]
      }
    ]
  })
}
```

This allows Lambda to:
- Read items from table
- Write new items
- Update existing items
- Delete items
- Query and scan data

## 💡 Pro Tips

- Use composite keys for complex queries
- Enable streams for real-time processing
- Monitor with CloudWatch alarms
- Use DynamoDB Accelerator (DAX) for caching
- Implement retry logic with exponential backoff
- Design for your access patterns
- Use TTL for automatic data cleanup

## 🎯 Use Cases for DynamoDB

1. **User Profiles** - Fast lookups by user ID
2. **Session Store** - Temporary data with TTL
3. **Product Catalog** - Product metadata
4. **IoT Data** - Time-series data
5. **Leaderboards** - High-score tracking
6. **Shopping Carts** - User-specific data
7. **Configuration Store** - Application settings

## 🏆 DynamoDB Benefits

✅ **Fully Managed** - No server maintenance  
✅ **Auto Scaling** - Handle any traffic  
✅ **Fast Performance** - Millisecond latency  
✅ **Global Tables** - Multi-region replication  
✅ **Security** - IAM integration, encryption  
✅ **Backup** - Point-in-time recovery  
✅ **Cost Effective** - Pay for what you use  
✅ **Integration** - Works with all AWS services  

You just built the data layer for modern cloud applications! This completes the full stack: compute, serverless, and database.
