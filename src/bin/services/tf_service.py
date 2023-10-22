import tensorflow as tf
import tensorflow_io as tfio
import tensorflow_hub as hub
import os
from ..config import working_dir

with tf.io.gfile.GFile(F'{working_dir}/kinetics_600_labels.txt') as f:
    lines = f.readlines()
    KINETICS_600_LABELS_LIST = [line.strip() for line in lines]
    KINETICS_600_LABELS = tf.constant(KINETICS_600_LABELS_LIST)


def predict_top_k(model, video, k=5, label_map=KINETICS_600_LABELS):
    """Outputs the top k model labels and probabilities on the given video."""
    outputs = model.predict(video[tf.newaxis])[0]
    probs = tf.nn.softmax(outputs)
    return get_top_k(probs, k, label_map=label_map)


def get_top_k(probs, k=5, label_map=KINETICS_600_LABELS):
    """Outputs the top k model labels and probabilities on the given video."""
    top_predictions = tf.argsort(probs, axis=-1, direction='DESCENDING')[:k]
    top_labels = tf.gather(label_map, top_predictions, axis=-1)
    top_labels = [label.decode('utf8') for label in top_labels.numpy()]
    top_probs = tf.gather(probs, top_predictions, axis=-1).numpy()
    return tuple(zip(top_labels, top_probs))


def load_movinet_from_hub(model_id, model_mode, hub_version=3):
    """Loads a MoViNet model from TF Hub."""
    hub_url = f'https://tfhub.dev/tensorflow/movinet/{model_id}/{model_mode}/kinetics-600/classification/{hub_version}'

    encoder = hub.KerasLayer(hub_url, trainable=True)

    inputs = tf.keras.layers.Input(
        shape=[None, None, None, 3],
        dtype=tf.float32)

    if model_mode == 'base':
        inputs = dict(image=inputs)
    else:
        # Define the state inputs, which is a dict that maps state names to tensors.
        init_states_fn = encoder.resolved_object.signatures['init_states']
        state_shapes = {
            name: ([s if s > 0 else None for s in state.shape], state.dtype)
            for name, state in init_states_fn(tf.constant([0, 0, 0, 0, 3])).items()
        }
        states_input = {
            name: tf.keras.Input(shape[1:], dtype=dtype, name=name)
            for name, (shape, dtype) in state_shapes.items()
        }

        # The inputs to the model are the states and the video
        inputs = {**states_input, 'image': inputs}

    # Output shape: [batch_size, 600]
    outputs = encoder(inputs)

    model = tf.keras.Model(inputs, outputs)
    model.build([1, 1, 1, 1, 3])

    return model


def load_mp4(file_path, image_size=(224, 224)):
    video = tf.io.read_file(file_path)
    video = tfio.experimental.ffmpeg.decode_video(video)
    video = tf.image.resize(video, image_size)
    video = tf.cast(video, tf.float32) / 255.
    return video


def load_gif(file_path, image_size=(224, 224)):
    """Loads a gif file into a TF tensor."""
    with tf.io.gfile.GFile(file_path, 'rb') as f:
        video = tf.io.decode_gif(f.read())
    video = tf.image.resize(video, image_size)
    video = tf.cast(video, tf.float32) / 255.
    return video


def run_prediction(vide_path):
    model = load_movinet_from_hub('a2', 'base', hub_version=3)
    filename, file_extension = os.path.splitext(vide_path)

    if file_extension == '.mp4':
        video = load_mp4(vide_path)
    elif file_extension == '.gif':
        video = load_gif(vide_path)

    # Run the model on the video and output the top 5 predictions
    top5_predictions = predict_top_k(model, video)
    return top5_predictions
