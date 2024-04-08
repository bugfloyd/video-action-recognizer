import boto3
import os
import json
import re

# Initialize ECS and S3 clients
ecs_client = boto3.client("ecs")
s3_client = boto3.client("s3")
events_client = boto3.client('events')


def lambda_handler(event, _):
    destination_bucket_name = os.getenv('DESTINATION_BUCKET_NAME')
    # Check if the destination bucket name is not set
    if not destination_bucket_name:
        error_message = "Error: 'DESTINATION_BUCKET_NAME' environment variable is not defined."
        print(error_message)
        return {
            "statusCode": 400,
            "body": error_message
        }

    size_limit = 100 * 1024 * 1024  # 100MB
    source_bucket_name = event["detail"]["bucket"]["name"]
    object_key = event["detail"]["object"]["key"]
    object_size = event["detail"]["object"]["size"]
    pattern = r'^upload/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/[^/]+$'

    # Check if the object is an MP4 or GIF file
    if (object_key.lower().endswith((".mp4", ".gif"))
            and object_key.lower().startswith("upload/")
            and re.match(pattern, object_key)
            and object_size < size_limit):
        # Copy the object to the new bucket
        copy_source = {'Bucket': source_bucket_name, 'Key': object_key}
        destination_object_key = object_key.replace("upload/", "files/", 1)
        dest_key_parts = destination_object_key.split('/')
        user_id = dest_key_parts[1]
        filename = dest_key_parts[-1]

        s3_client.copy(copy_source, destination_bucket_name, destination_object_key)
        print(f"Object '{object_key}' copied to bucket '{destination_bucket_name}'.")

        # Now delete the original object
        s3_client.delete_object(Bucket=source_bucket_name, Key=object_key)
        print(f"Object '{object_key}' deleted from bucket '{source_bucket_name}'.")

        event_payload = {
            "userId": user_id,
            "key": destination_object_key,
            "name": filename
        }

        event = {
            'Entries': [
                {
                    'Source': 'var.upload_listener',
                    'DetailType': 'UploadedFileCopied',
                    'Detail': json.dumps(event_payload),
                    'EventBusName': 'var-main'
                }
            ]
        }

        # Put the event
        response = events_client.put_events(**event)
        print(f"Event published to EventBridge: 'UploadedFileCopied'.", response)

        return {
            "statusCode": 200,
            "body": json.dumps("Successfully processed the uploaded file."),
        }
    else:
        print("File is not a valid MP4 or GIF.", {
            "key": object_key,
            "size": object_size,
        })
        return {
            "statusCode": 200,
            "body": json.dumps("Nothing to do, file is not an MP4 or GIF."),
        }
