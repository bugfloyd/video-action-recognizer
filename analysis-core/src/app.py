import json
import os

import boto3
import numpy as np

from config import input_video_s3_bucket, output_s3_bucket, video_s3_key, user_id, file_id, analysis_id, event_bus_name, \
    model_name
from services.results_service import ResultsService
from services.s3_service import download_video, upload_video
from services.video_predictor import VideoPredictor
from utils import logger

events_client = boto3.client('events')


def default_serializer(obj):
    """If input object is an unsupported type, convert it to a serializable type."""
    if isinstance(obj, np.float32):
        return float(obj)
    raise TypeError(f"Object of type {obj.__class__.__name__} is not JSON serializable")


if __name__ == "__main__":
    logger.log_info(f"input_video_s3_bucket={input_video_s3_bucket}")
    logger.log_info(f"video_s3_key={video_s3_key}")
    logger.log_info(f"user_id={user_id}")
    logger.log_info(f"file_id={file_id}")
    logger.log_info(f"analysis_id={analysis_id}")
    logger.log_info(f"model_name={model_name}")
    logger.log_info(f"event_bus_name={event_bus_name}")

    if not input_video_s3_bucket or not video_s3_key or not user_id or not file_id or not analysis_id or not event_bus_name or not model_name:
        logger.log_warning("No data provided")
    else:
        vide_path = download_video(input_video_s3_bucket, video_s3_key)
        if not vide_path:
            logger.log_warning("Could not download file.")
        else:
            if model_name == "a2-base-kinetics-600-classification":
                # Recognize the action in average for the whole video
                predictor = VideoPredictor("base")
                top5_predictions = predictor.run_prediction(vide_path)
                for label, prob in top5_predictions:
                    print(f"{label:20s}: {prob:.3f}")

                # Put the event
                event_payload = {
                    "userId": user_id,
                    "fileId": file_id,
                    "analysisId": analysis_id,
                    "data": {
                        "model": model_name,
                        "output": json.dumps({
                            "predictions": top5_predictions
                        }, default=default_serializer)
                    }
                }
                event = {
                    'Entries': [
                        {
                            'Source': 'var.analysis_core',
                            'DetailType': 'FileAnalyzed',
                            'Detail': json.dumps(event_payload),
                            'EventBusName': event_bus_name
                        }
                    ]
                }
                response = events_client.put_events(**event)
                print(f"Event published to EventBridge: 'FileAnalyzed'.", response)

            elif model_name == "a2-stream-kinetics-600-classification":
                # Generate a plot and output to a video tensor
                predictor = VideoPredictor("stream")
                top5_predictions = predictor.run_prediction(vide_path)

                logger.log_info("Generating the output streaming plot output...")
                results_service = ResultsService(predictor)
                output_file_path = results_service.generate_stream_output(
                    input_video_s3_key=video_s3_key
                )

                base_name_with_ext = os.path.basename(video_s3_key)
                base_name, extension = os.path.splitext(base_name_with_ext)
                output_file_key = video_s3_key.replace(base_name_with_ext,
                                                       f"{base_name}/a2-stream-kinetics-600-classification{extension}")
                upload_video(output_s3_bucket, output_file_key, output_file_path)

                # Put the event
                event_payload = {
                    "userId": user_id,
                    "fileId": file_id,
                    "analysisId": analysis_id,
                    "data": {
                        "model": model_name,
                        "output": json.dumps({
                            "output_file_path": output_file_key
                        })
                    }
                }
                event = {
                    'Entries': [
                        {
                            'Source': 'var.analysis_core',
                            'DetailType': 'FileAnalyzed',
                            'Detail': json.dumps(event_payload),
                            'EventBusName': event_bus_name
                        }
                    ]
                }
                response = events_client.put_events(**event)
                print(f"Event published to EventBridge: 'FileAnalyzed'.", response)
