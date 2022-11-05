from bin.services.tf_service import run_prediction
from bin.config import video_s3_bucket, video_s3_key
from bin.services.s3_service import download_video
from bin.utils import logger

# Show video
# print(video.shape)
# media.show_video(video.numpy(), fps=5)

if __name__ == "__main__":
    if not video_s3_bucket and not video_s3_key:
        logger.log_warning('No data provided')
    else:
        vide_path = download_video(video_s3_bucket, video_s3_key)
        if not vide_path:
            logger.log_warning('Could not download file.')
        else:
            top5_predictions = run_prediction(vide_path)
            for label, prob in top5_predictions:
                print(label, prob)
