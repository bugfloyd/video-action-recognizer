from services.video_predictor import VideoPredictor
from config import input_video_s3_bucket, output_s3_bucket, video_s3_key
from services.s3_service import download_video, upload_video
from services.results_service import ResultsService
from utils import logger


if __name__ == "__main__":
    if not input_video_s3_bucket and not video_s3_key:
        logger.log_warning("No data provided")
    else:
        vide_path = download_video(input_video_s3_bucket, video_s3_key)
        if not vide_path:
            logger.log_warning("Could not download file.")
        else:
            # Recognize the actyion in average for the whole video
            predictor = VideoPredictor("base")
            top5_predictions = predictor.run_prediction(vide_path)
            for label, prob in top5_predictions:
                print(f"{label:20s}: {prob:.3f}")

            # Generate a plot and output to a video tensor
            predictor = VideoPredictor("stream")
            top5_predictions = predictor.run_prediction(vide_path)

            logger.log_info("Generating the output streaming plot output...")
            results_service = ResultsService(predictor)
            output_file_path = results_service.generate_stream_output(
                input_video_s3_key=video_s3_key
            )
            upload_video(output_s3_bucket, output_file_path)
