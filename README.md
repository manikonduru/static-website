# Static Website + Terraform + GitHub Actions

This repository contains a minimal static website and Terraform configuration to deploy it to AWS using S3 + CloudFront. A GitHub Actions workflow is included to run Terraform and upload site files on pushes to `main`.

Important: This is a minimal example. Review, adapt, and secure it before using in production. Cloud resources may incur AWS charges.

## Required GitHub repository secrets

- `AWS_ACCESS_KEY_ID` – IAM key with permissions to manage S3, CloudFront, and IAM as needed
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` – AWS region, e.g. `us-east-1`
- `SITE_BUCKET_NAME` – (optional) globally unique S3 bucket name for the site. If not provided, a bucket name will be auto-generated as `static-site-{aws_account_id}-{region}`

## Files included

- `site/index.html` — example static site
- `terraform/` — Terraform code to create S3 bucket, OAI and CloudFront
  - `main.tf` — resources: S3, CloudFront, OAI, bucket policy
  - `variables.tf` — input variables with auto-generation logic
  - `outputs.tf` — outputs: bucket name, CloudFront domain, distribution id
  - `backend.tf` — (optional) S3 backend configuration for remote state
- `.github/workflows/deploy.yml` — workflow with secrets validation, terraform plan/apply, site sync, and cache invalidation

## Quick start

1. Create a GitHub repository and push this folder tree to it (branch `main`).
2. In the repository Settings → Secrets and variables → Actions, add:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION` (e.g., `us-east-1`)
   - `SITE_BUCKET_NAME` (optional; auto-generated if not provided)
3. Push to `main`. The workflow will:
   - Validate required secrets
   - run `terraform init` and `terraform plan/apply`
   - get outputs (bucket name and CloudFront distribution id)
   - sync `site/` to the S3 bucket
   - invalidate CloudFront cache

## Quick local test (optional)

1. Install Terraform (1.0+) and AWS CLI.
2. Configure AWS credentials locally (e.g. `aws configure`).
3. (Optional) If using S3 backend:
   - Create a state bucket and DynamoDB table first (or use local state by commenting out `backend.tf`)
   - Update `terraform/backend.tf` with your state bucket name
4. From the `terraform` directory, set `TF_VAR_bucket_name` or leave empty to auto-generate:
   - Export to auto-generate: (no export needed, will auto-generate)
   - Or provide a name: `export TF_VAR_bucket_name=my-unique-bucket-name`
5. Run:

```bash
terraform init
terraform plan
terraform apply
```

6. Upload your site locally (or use the GitHub Action):

```bash
aws s3 sync ../site/ s3://$(terraform output -raw bucket_name) --delete
```

7. Retrieve outputs:

```bash
terraform output cloudfront_domain
```

## Remote state backend (optional)

By default, Terraform state is stored locally. For team collaboration or CI/CD, use an S3 backend:

1. Create an S3 bucket and DynamoDB table for Terraform state (e.g., with separate Terraform):
   ```bash
   aws s3api create-bucket --bucket terraform-state-{account-id} --region us-east-1
   aws s3api put-bucket-versioning --bucket terraform-state-{account-id} --versioning-configuration Status=Enabled
   
   aws dynamodb create-table --table-name terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
     --region us-east-1
   ```
2. Update `terraform/backend.tf` with your state bucket name and region.
3. Run `terraform init` again to migrate state.

## Auto-generated bucket names

If `SITE_BUCKET_NAME` secret is not provided, Terraform will auto-generate a unique bucket name using your AWS account ID and region:

```
static-site-123456789012-us-east-1
```

This ensures uniqueness without manual configuration. You can override by setting `SITE_BUCKET_NAME` secret.

## GitHub Actions workflow features

- **Secrets validation**: Fails fast if required secrets are missing
- **Terraform plan**: Shows changes before applying
- **Terraform apply**: Creates or updates infrastructure
- **S3 sync**: Uploads site files with automatic deletion of removed files
- **CloudFront invalidation**: Clears cache so viewers see fresh content immediately

## Notes and next steps

- **Custom domain**: To use a custom domain, provision an ACM certificate in `us-east-1`, update `viewer_certificate` in `terraform/main.tf`, and add Route53 DNS records.
- **IAM security**: Create a CI IAM user with least-privilege permissions (S3, CloudFront, STS AssumeRole only).
- **State locking**: Recommended for team use; DynamoDB table created as shown above.
- **Costs**: S3, CloudFront, and data transfer may incur charges. Use `terraform destroy` when done testing.
- **TLS/HTTPS**: CloudFront default certificate works for the CloudFront domain. Custom domains require an ACM certificate.

## Example: destroy infrastructure

```bash
cd terraform
terraform destroy
```
