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
  echo "Usage: $0 --bucket <LAMBDA_BUCKET_NAME> [--profile <name>] [--region <value>]"
  exit 1
fi

echo "Cleaning old build artifacts"
rm -rf ./package && rm -rf ./build
echo "Copying source code"
mkdir -p ./package && mkdir -p ./build
cp listener_lambda.py ./package/
echo "Entering python virtual environment"
python -m venv venv
source venv/bin/activate
echo "Installing packages"
pip install --upgrade pip > /dev/null
pip install -r requirements.txt -t ./package > /dev/null
cd ./package
echo "Creating zip bundle"
zip -r9 ../build/upload_listener.zip . > /dev/null
echo "Cleaning up"
cd ..
rm -rf ./package
deactivate

if [ $? -eq 0 ]; then
  echo "Uploading function zip to S3 bucket $BUCKET_NAME"
  aws s3 cp build/upload_listener.zip \
  "s3://$BUCKET_NAME/upload_listener/latest/function.zip" $AWS_PROFILE $AWS_REGION
  if [ $? -eq 0 ]; then
    echo "Uploaded function bundle SHA:"
    shasum -a 256 build/upload_listener.zip | awk '{print $1}' | xxd -r -p | base64
  else
    echo "Failed to upload function zip bundle to S3."
  fi
else
  echo "Failed to create function zip bundle."
fi