# Video Action Recognizer [In Development]

This project contains all necessary components and services for the Video Action Recognizer application.

## Table of Contents

- [Components](#components)
- [Deployment](#deployment)
  - [Terraform Backend Setup](#terraform-backend-setup)
  - [Listener Lambda](#listener-lambda)
  - [RESTful Backend API](#restful-backend-api)
  - [Main Infrastructure](#main-infrastructure)
  - [Analysis Core](#analysis-core)
  - [Create First Admin User](#create-first-admin-user)
- [Development](#development)
  - [Updating Lambda Functions](#updating-lambda-functions)
  - [Run RESTful Backend Locally](#run-restful-backend-locally)
- [Usage (Analysis MVP)](#usage-analysis-mvp)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)
- [License](#license)

## Components

**Serverless Analysis Core**  
Implemented in Python, this component performs video analysis using TensorFlow and the Movinet kinetics-600 model. It operates as a serverless Fargate task within AWS ECS.

**Upload Listener Lambda**  
A Python AWS Lambda function that responds to S3 'object put' events by initiating the Analysis Core ECS task to process the uploaded video file.

**Serverless Backend**  
In development, this component will provide RESTful APIs, facilitating server-side interactions and integrations with AWS services.

**UI**  
The user interface is built with TypeScript and React.js, allowing for video or GIF file uploads and presenting analysis results. (Under Development)

**Infrastructure Code**  
Infrastructure as Code (IaC) managed through Terraform scripts automates the setup of the required AWS infrastructure.

## Deployment

Ensure the AWS CLI is installed and configured with an access key pair before beginning the deployment process.

### Terraform Backend Setup

Navigate to the `infrastructure/init` directory and create a `terraform.tfvars` file:

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
terraform plan -out init.tfplan
terraform apply "init.tfplan"
```

### Listener Lambda

Navigate to the `upload-listener` directory:

```bash
cd upload-listener
```

Package and deploy the Lambda function:

```bash
./deploy.sh --bucket <LAMBDA_BUCKET_NAME> [--profile <name>] [--region <value>]
```

Obtain the uploaded function bundle SHA sum from the script output and use it in the Main Infrastructure section.

### RESTful Backend API

For each of backend modules build zip bundle and upload it to S3. Get the bundle SHA sum.

```bash
cd rest-backend


./deploy.sh --bucket <LAMBDA_BUCKET_NAME> --skip-infra-update true [--profile <name>] [--region <value>]
```

Accepted values for module name argument are: `users`, `files`, `results`

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
rest_backend_lambda_bundle_sha    = "<REST_BACKEND_LAMBDA_BUNDLE_SHA>"
cognito_domain_prefix             = "<AWS_COGNITO_DOMAIN_PREFIX>"
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

Get
api_gateway_id, cognito_user_pool_client_id, cognito_user_pool_domain, cognito_user_pool_id, and cognito_user_pool_resource_server_identifier from terraform output.

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

### Create First Admin User

In order to send requests to the deployed serverless RESTful API, you need to create the first admin user in AWS Cognito:

```bash
cd rest-backend

./init.sh --user-pool-id <value> --email <value> --given-name <value> --family-name <value> --password <value> [--profile <name>] [--region <value>]
```

## Development

### Updating Lambda Functions

1. Re-run the code to build and upload the lambda function.
2. Replace the `*_lambda_bundle_sha` in `terraform.tfvars` with the newly obtained SHA sum.
3. Apply the changes using Terraform:

```bash
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```

4. For the rest backend lambda functions, re-deploy the API for `dev` stage from AWS console.

### Run RESTful Backend Locally

You can use AWS SAM to build and invoke backend lambda functions locally. You can find some mock event input in `rest-backend/mock-events` directory.

Go to one of the backend lambda functions’ directory and compile TypeScript and build the bundle:

```bash
cd rest-backend/users # or 'files' or 'results'
npm run build
```

Invoke the lambda locally using AWS SAM CLI and the related mock event:

```bash
sam local invoke VarBackend \
-e mock-events/createUser.json \
--template template.yaml \
--parameter-overrides \
UserPoolId=<USER_POOL_ID>
```

## Usage (Analysis MVP)

Upload a mp4 video or a gif file to S3 `<INPUT_BUCKET_NAME>` and see the analysis logs and results in CloudWatch.

## API Documentation

For more information, see our [API Reference](https://github.com/bugfloyd/video-action-recognizer/wiki/API-Reference).

## Contributing

We welcome contributions from the community. If you'd like to contribute, please fork the repository and make your changes, then create a pull request against the main branch.

## License

Code released under the GNU GPL v3 License.
