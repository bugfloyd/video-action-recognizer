from os import getenv

working_dir = getenv("WORKING_DIR")
input_video_s3_bucket = getenv("INPUT_VIDEO_S3_BUCKET")
output_s3_bucket = getenv("INPUT_VIDEO_S3_BUCKET")
video_s3_key = getenv("INPUT_VIDEO_S3_KEY")
s3_access_key_id = getenv("S3_ACCESS_KEY_ID")
s3_secret_access_key = getenv("S3_SECRET_ACCESS_KEY")
s3_endpoint_url = getenv("S3_ENDPOINT_URL")
s3_region = getenv("S3_REGION")
