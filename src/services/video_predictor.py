import tensorflow as tf
import tensorflow_io as tfio
import tensorflow_hub as hub
import os
import tqdm
from config import working_dir
from utils import logger


class VideoPredictor:
    _instance = None

    KINETICS_600_LABELS = None
    KINETICS_600_LABELS_LIST = None
    k = 5
    model_type = None
    model = None
    video = None
    """The user uploaded video to analyze and display in the plot."""

    probs = None
    """The probability tensor of shape (num_frames, num_classes) that represents
        the probability of each class on each frame."""

    init_states_fn = None

    def __new__(self, model_type):
        if self._instance is None:
            self._instance = super(VideoPredictor, self).__new__(self)
        return self._instance

    def __init__(self, model_type="base"):
        if self.KINETICS_600_LABELS is None or self.KINETICS_600_LABELS_LIST is None:
            with tf.io.gfile.GFile(f"{working_dir}/kinetics_600_labels.txt") as f:
                lines = f.readlines()
                self.KINETICS_600_LABELS_LIST = [line.strip() for line in lines]
                self.KINETICS_600_LABELS = tf.constant(self.KINETICS_600_LABELS_LIST)

        if model_type != self.model_type:
            self.model_type = model_type
            self.load_movinet_from_hub(
                model_id="a2", model_mode=model_type, hub_version=3
            )

    def load_movinet_from_hub(self, model_id, model_mode, hub_version=3):
        """Loads a MoViNet model from TF Hub."""
        hub_url = f"https://tfhub.dev/tensorflow/movinet/{model_id}/{model_mode}/kinetics-600/classification/{hub_version}"

        encoder = hub.KerasLayer(hub_url, trainable=True)

        # Define the image (video) input
        image_input = tf.keras.layers.Input(
            shape=[None, None, None, 3], dtype=tf.float32, name="image"
        )

        if model_mode == "base":
            inputs = dict(image=image_input)
        else:
            # Define the state inputs, which is a dict that maps state names to tensors.
            self.init_states_fn = encoder.resolved_object.signatures["init_states"]
            state_shapes = {
                name: ([s if s > 0 else None for s in state.shape], state.dtype)
                for name, state in self.init_states_fn(
                    tf.constant([0, 0, 0, 0, 3])
                ).items()
            }
            states_input = {
                name: tf.keras.Input(shape[1:], dtype=dtype, name=name)
                for name, (shape, dtype) in state_shapes.items()
            }

            # The inputs to the model are the states and the video
            inputs = {**states_input, "image": image_input}

        # Output shape: [batch_size, 600]
        outputs = encoder(inputs)

        model = tf.keras.Model(inputs, outputs, name="movinet")
        model.build([1, 1, 1, 1, 3])
        self.model = model

    def predict_top_k(self):
        """Outputs the top k model labels and probabilities on the given video."""

        if self.model_type == "base":
            logger.log_info("Running the base model over the whole video...")
            outputs = self.model.predict(self.video[tf.newaxis])[0]
            self.probs = tf.nn.softmax(outputs)
            return self.get_top_k(self.probs)
        else:
            logger.log_info("Running the stream model for frame by frame analysis...")
            init_states = self.init_states_fn(tf.shape(self.video[tf.newaxis]))
            images = tf.split(self.video[tf.newaxis], self.video.shape[0], axis=1)

            all_logits = []
            # To run on a video, pass in one frame at a time
            states = init_states
            for image in tqdm.tqdm(images):
                # predictions for each frame
                logits, states = self.model({**states, "image": image})
                all_logits.append(logits)

            # concatinating all the logits
            logits = tf.concat(all_logits, 0)
            # estimating probabilities
            self.probs = tf.nn.softmax(logits, axis=-1)
            final_probs = self.probs[-1]
            return self.get_top_k(final_probs)

    def get_top_k(self, probs):
        """Outputs the top k model labels and probabilities on the given video."""
        top_predictions = tf.argsort(probs, axis=-1, direction="DESCENDING")[: self.k]
        top_labels = tf.gather(self.KINETICS_600_LABELS, top_predictions, axis=-1)
        top_labels = [label.decode("utf8") for label in top_labels.numpy()]
        top_probs = tf.gather(probs, top_predictions, axis=-1).numpy()
        return tuple(zip(top_labels, top_probs))

    def load_mp4(self, file_path, image_size=(224, 224)):
        video = tf.io.read_file(file_path)
        video = tfio.experimental.ffmpeg.decode_video(video)
        video = tf.image.resize(video, image_size)
        video = tf.cast(video, tf.float32) / 255.0
        self.video = video

    def load_gif(self, file_path, image_size=(224, 224)):
        """Loads a gif file into a TF tensor."""
        with tf.io.gfile.GFile(file_path, "rb") as f:
            video = tf.io.decode_gif(f.read())
        video = tf.image.resize(video, image_size)
        video = tf.cast(video, tf.float32) / 255.0
        self.video = video

    def run_prediction(self, vide_path):
        _, file_extension = os.path.splitext(vide_path)
        logger.log_info(f"Analyzing {vide_path}")

        if file_extension == ".mp4":
            self.load_mp4(vide_path)
        elif file_extension == ".gif":
            self.load_gif(vide_path)

        # Run the model on the video and output the top 5 predictions
        return self.predict_top_k()
