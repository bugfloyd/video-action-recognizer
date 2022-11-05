#!/usr/bin/env bash

MINIO_ACCESS_KEY_ID=minioAdmin
MINIO_SECRET_ACCESS_KEY=minioPassword
S3_ENDPOINT=http://127.0.0.1:9000


setup_mc() {
  # Check if there is a mc binary located in ~/mc. if not, download one
  if [ ! -f ~/mc ]; then
      echo "downloading mc binary..."
      if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -f -L -o ~/mc https://dl.min.io/client/mc/release/linux-amd64/mc
      elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -f -L -o ~/mc https://dl.min.io/client/mc/release/darwin-amd64/mc
      fi
      chmod +x ~/mc
  else
    echo "found minio client in ~/mc"
  fi

  # configure mc
  if ~/mc alias ls | grep "vr-s3" > /dev/null; then
    echo "MinIO client is already configured"
  else
    echo "authenticating mc to use local MinIO server..."
    ~/mc alias set vr-s3 "$S3_ENDPOINT" "$MINIO_ACCESS_KEY_ID" "$MINIO_SECRET_ACCESS_KEY" --api S3v4
  fi
}

create_bucket() {
  bucket_name=$1
    if ~/mc ls vr-s3 | \
    grep "$bucket_name" > /dev/null; then
      echo "$bucket_name bucket already exists."
    else
      ~/mc mb "vr-s3/$bucket_name" > /dev/null
      echo "bucket $bucket_name created."
    fi
}

run() {
  echo "configuring MinIO client (mc)..."
  setup_mc
  create_bucket video-recognition
}

run
