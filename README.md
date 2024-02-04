# Video Action Recognizer [In Development]

This project contains all necessary components and services for the Video Action Recognizer application.

## Components

### Serverless Analysis Core

Implemented in Python, this component performs video analysis using TensorFlow and the Movinet kinetics-600 model. It operates as a serverless Fargate task within AWS ECS.

### Upload Listener Lambda

A Python AWS Lambda function that responds to S3 'object put' events by initiating the Analysis Core ECS task to process the uploaded video file.

### Serverless Backend

In development, this component will provide RESTful APIs, facilitating server-side interactions and integrations with AWS services.

### UI

The user interface is built with TypeScript and React.js, allowing for video or GIF file uploads and presenting analysis results. (Under Development)

### Infrastructure Code

Infrastructure as Code (IaC) managed through Terraform scripts automates the setup of the required AWS infrastructure.

## Deployment

Ensure the AWS CLI is installed and configured with an access key pair before beginning the deployment process.

### Terraform Backend Setup

Navigate to the `infrastructure/setup` directory and create a `terraform.tfvars` file:

```hcl
aws_region             = "<AWS_REGION>"
terraform_state_bucket = "<TERRAFORM_STATE_BUCKET_NAME>"
lambda_bucket          = "<LAMBDA_BUCKET_NAME>"
```

Initialize Terraform:

```bash
terraform init
```

Deploy the resources:

```bash
terraform plan -out setup.tfplan
terraform apply "setup.tfplan"
```

### Listener Lambda

Navigate to the `upload-listener` directory:

```bash
cd upload-listener
```

Package and deploy the Lambda function:

```bash
rm -rf ./package && rm -rf ./build
mkdir -p ./package && mkdir -p ./build
cp listener_lambda.py ./package/
python -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt -t ./package
cd ./package
zip -r9 ../build/upload_listener.zip .
cd ..
rm -rf ./package
deactivate

aws s3 cp build/upload_listener.zip \
s3://<LAMBDA_BUCKET_NAME>/upload_listener/latest/function.zip

shasum -a 256 build/upload_listener.zip | awk '{print $1}' | xxd -r -p | base64
```

Otaining the SHA sum and use it in the Main Infrastructure section.

### Main Infrastructure

Navigate to the `infrastructure` directory and create a backend configuration file `backend_config.hcl`:

```hcl
bucket         = "<TERRAFORM_STATE_BUCKET_NAME>"
region         = "<AWS_REGION>"
```

Create a `terraform.tfvars` file:

```hcl
aws_region                        = "<AWS_REGION>"
input_bucket                      = "<INPUT_BUCKET_NAME>"
output_bucket                     = "<OUTPUT_BUCKET_NAME>"
lambda_bucket                     = "<LAMBDA_BUCKET_NAME>"
upload_listener_lambda_bundle_sha = "<UPLOAD_LISTENER_LAMBDA_BUNDLE_SHA>"
cognito_domain_prefix             = "<AWS_COGNITO_DOMAIN_PREFIX>"
users_lambda_bundle_sha           = "<USERS_LAMBDA_BUNDLE_SHA>"
results_lambda_bundle_sha         = "RESULTS_LAMBDA_BUNDLE_SHA>"
files_lambda_bundle_sha           = "<FILESLAMBDA_BUNDLE_SHA>"
```

Initialize Terraform with the S3 backend:

```bash
terraform init -backend-config="backend_config.hcl"
```

Deploy the main infrastructure:

```bash
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```

To view the state of deployed resources:

```bash
terraform state list
```

### Analysis Core

Build and push the Docker image:

```bash
aws ecr get-login-password --region <AWS_REGION> | \
docker login --username AWS --password-stdin \
<ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com
```

```bash
docker buildx build --platform=linux/amd64 \
-t <ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/video-action-regognizer:latest \
.
```

```bash
docker push <ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/video-action-regognizer:latest
```

## Updating resources

To update the Lambda function:

1. Re-run the code to build and upload the listener lambda function.
2. Replace the `upload_listener_lambda_bundle_sha` in `terraform.tfvars` with the newly obtained SHA sum.
3. Apply the changes using Terraform:

```bash
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```
