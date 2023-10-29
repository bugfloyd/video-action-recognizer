import os
from services.video_predictor import VideoPredictor
from config import video_s3_bucket, video_s3_key
from services.s3_service import download_video, upload_video
from services.results_service import ResultsService
from utils import logger
from config import working_dir
import imageio


if __name__ == "__main__":
    if not video_s3_bucket and not video_s3_key:
        logger.log_warning("No data provided")
    else:
        vide_path = download_video(video_s3_bucket, video_s3_key)
        if not vide_path:
            logger.log_warning("Could not download file.")
        else:
            predictor = VideoPredictor("base")
            top5_predictions = predictor.run_prediction(vide_path)
            for label, prob in top5_predictions:
                print(f"{label:20s}: {prob:.3f}")

            # Generate a plot and output to a video tensor
            predictor = VideoPredictor("stream")
            top5_predictions = predictor.run_prediction(vide_path)

            logger.log_info("Generating the output streaming plot output...")
            results_service = ResultsService(predictor)
            plot_video = results_service.plot_streaming_top_preds()

            logger.log_info(f"Generating video file from the streaming plot")
            # Convert the numpy array of images into a video and save it to the file system
            local_file_path = (
                f"{working_dir}/videos/output_{os.path.basename(video_s3_key)}"
            )
            imageio.mimsave(
                local_file_path, plot_video, fps=25
            )  # Set fps to desired frames per second
            logger.log_info(f"Stored {local_file_path}")

            upload_video(video_s3_bucket, local_file_path)
