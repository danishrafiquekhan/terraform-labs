**08 — a real apply/destroy cycle, against LocalStack instead of Azure**

Every other exercise in this repo is validated with `terraform fmt`/`terraform validate` and has never actually been applied — a real, honestly-stated gap, since none of it has ever proven it deploys correctly, only that it parses correctly. Getting a genuine `apply`/`destroy` cycle proven needed a target that doesn't require logging into a real cloud account, and LocalStack (free, local, already used elsewhere in this portfolio for `aws-identity-detection`) is that target.

**Why AWS/LocalStack instead of Azure**

LocalStack only emulates AWS — it has no Azure equivalent. The `azurerm` provider used everywhere else in this repo talks to Azure's real API and can't be pointed at LocalStack at all. Rather than fake an Azure apply that isn't actually possible, this exercise deliberately uses the `aws` provider instead: a real init/plan/apply/destroy cycle against a real (if simulated) backend, proving the actual terraform workflow end to end, even though it's a different cloud than the rest of the repo.

**What it builds**

An S3 bucket (public access blocked, versioning on) and an IAM role scoped to `s3:PutObject` only — deliberately narrow, no read/list/delete permissions, since a role that writes logs doesn't need to read them back. Same least-privilege principle as the Auth0 lesson in `detection-engineering` (an over-broad grant found and narrowed after the fact via the API), applied here at the infrastructure-definition stage instead.

**The real bug this hit**

First `apply` attempt hung indefinitely. LocalStack's logs showed the actual cause: `exception during call chain: Unable to find operation for request to service s3: HEAD /`. The AWS provider defaults to virtual-hosted-style S3 addressing (`bucket-name.s3.amazonaws.com`), but LocalStack serves every service off one endpoint (`localhost:4566`) and needs path-style addressing (`localhost:4566/bucket-name`) to route requests correctly. Fixed with one line in the provider block: `s3_use_path_style = true`. A well-known LocalStack gotcha once you've hit it, genuinely confusing the first time — the apply doesn't error, it just retries the same failing request forever.

**Verified, for real**

```
$ terraform apply -auto-approve
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::soc-lab-log-bucket-localstack"
log_writer_role_arn = "arn:aws:iam::000000000000:role/soc-lab-log-bucket-localstack-log-writer"

$ aws --endpoint-url=http://localhost:4566 s3 ls
2026-09-04 23:53:41 soc-lab-log-bucket-localstack

$ aws --endpoint-url=http://localhost:4566 iam list-roles --query 'Roles[].RoleName'
["soc-lab-log-bucket-localstack-log-writer"]

$ terraform destroy -auto-approve
...
Destroy complete! Resources: 5 destroyed.

$ aws --endpoint-url=http://localhost:4566 s3 ls
(empty)
```

**Running it**
```bash
docker start localstack-localstack-1   # or docker compose up -d in aws-identity-detection/local-lab/
terraform init
terraform apply -auto-approve
terraform destroy -auto-approve   # when done
```
