import boto3
import os
import json

# Initialize ECS and S3 clients
ecs_client = boto3.client("ecs")
s3_client = boto3.client("s3")


def lambda_handler(event, context):
    # Get bucket name and object key from the S3 event
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    object_key = event["Records"][0]["s3"]["object"]["key"]

    # Check if the object is an MP4 or GIF file
    if object_key.lower().endswith((".mp4", ".gif")):
        # Specify the task definition, cluster, and other parameters
        response = ecs_client.run_task(
            launchType="FARGATE",
            taskDefinition=os.environ["ANALYSIS_CORE_ECS_TASK_DEFINITION"],
            cluster=os.environ["ANALYSIS_CORE_ECS_CLUSTER"],
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": [
                        os.environ["ANALYSIS_CORE_SUBNET_ID_1"],
                        os.environ["ANALYSIS_CORE_SUBNET_ID_2"],
                    ],
                    "securityGroups": [os.environ["ANALYSIS_CORE_SECURITY_GROUP"]],
                    "assignPublicIp": "ENABLED",
                }
            },
            overrides={
                "containerOverrides": [
                    {
                        "name": os.environ["ANALYSIS_CORE_CONTAINER_NAME"],
                        "environment": [
                            {"name": "INPUT_VIDEO_S3_KEY", "value": object_key},
                        ],
                    },
                ],
            },
        )
        print(response)
        return {
            "statusCode": 200,
            "body": json.dumps("Successfully triggered Analysis Core ECS task."),
        }
    else:
        print("File is not an MP4 or GIF")
        return {
            "statusCode": 200,
            "body": json.dumps("Nothing to do, file is not an MP4 or GIF."),
        }
