import boto3
import os
from config import (
    s3_access_key_id,
    s3_secret_access_key,
    s3_endpoint_url,
    working_dir,
    s3_region,
)
from utils import logger


if s3_endpoint_url:
    s3_client = boto3.client(
        service_name="s3",
        region_name=s3_region,
        aws_access_key_id=s3_access_key_id,
        aws_secret_access_key=s3_secret_access_key,
        endpoint_url=s3_endpoint_url,
    )
else:
    s3_client = boto3.client(service_name="s3", region_name=s3_region)


def download_video(bucket, video_key):
    local_file_path = f"{working_dir}/videos/{os.path.basename(video_key)}"

    try:
        s3_client.download_file(bucket, video_key, local_file_path)
        logger.log_info(f"File downloaded: {bucket}/{video_key}")
        return local_file_path

    except Exception as error:
        logger.log_error("S3: {}".format(error))


def upload_video(bucket, s3_key, video_path):
    try:
        s3_client.upload_file(video_path, bucket, s3_key)
        logger.log_info(f"File uploaded: {bucket}/{s3_key}")
        return s3_key

    except Exception as error:
        logger.log_error("S3: {}".format(error))
