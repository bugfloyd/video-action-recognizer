#!/bin/bash

# Initialize variables for optional parameters
AWS_PROFILE=""
AWS_REGION=""

# Initialize variables for required parameters with empty defaults
BUCKET_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --bucket)
      BUCKET_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    --profile)
      AWS_PROFILE="--profile $2"
      shift # past argument
      shift # past value
      ;;
    --region)
      AWS_REGION="--region $2"
      shift # past argument
      shift # past value
      ;;
    *)
      shift # past argument
      ;;
  esac
done

# Check for required parameters
if [[ -z "$BUCKET_NAME" ]]; then
  echo "Error: Missing required parameters."
  echo "Usage: $0 --module <MODULE_NAME> --bucket <LAMBDA_BUCKET_NAME> [--profile <name>] [--region <value>]"
  exit 1
fi

echo "Building function zip bundle for backend"
npm run bundle > /dev/null

if [ $? -eq 0 ]; then
  echo "Uploading function zip bundle for backend to S3 bucket: $BUCKET_NAME"
  aws s3 cp function.zip \
  s3://$BUCKET_NAME/rest_backend/function.zip
  if [ $? -eq 0 ]; then
    echo "Uploaded function bundle SHA:"
    shasum -a 256 function.zip | awk '{print $1}' | xxd -r -p | base64
  else
    echo "Failed to upload function zip bundle to S3."
  fi
else
  echo "Failed to create function zip bundle."
fi