# Define working directory
ARG WORKING_DIR="/tmp/video-action-recognizer"

# Define function base image
ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

# Set timezone
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install wget, python, pip & ffmpeg
RUN apt-get update
RUN apt-get install python3 python3-pip ffmpeg -y

# Update pipe
RUN python3 -m pip install --upgrade pip

# Include global arg in this stage of the build
ARG WORKING_DIR
ENV WORKING_DIR=$WORKING_DIR

# Create working, videos, and models directories
RUN mkdir -p ${WORKING_DIR}
RUN mkdir -p "$WORKING_DIR/videos"
RUN mkdir -p "$WORKING_DIR/models/base" && mkdir -p "$WORKING_DIR/models/stream"

# Download and extract the model tarball
ADD https://tfhub.dev/tensorflow/movinet/a2/base/kinetics-600/classification/3?tf-hub-format=compressed /tmp/base_model.tar.gz
RUN tar -xzf /tmp/base_model.tar.gz -C "${WORKING_DIR}/models/base" && rm /tmp/base_model.tar.gz

ADD https://tfhub.dev/tensorflow/movinet/a2/stream/kinetics-600/classification/3?tf-hub-format=compressed /tmp/stream_model.tar.gz
RUN tar -xzf /tmp/stream_model.tar.gz -C "${WORKING_DIR}/models/stream" && rm /tmp/stream_model.tar.gz

# Copy Kinetics 600 label map
ADD https://raw.githubusercontent.com/tensorflow/models/f8af2291cced43fc9f1d9b41ddbf772ae7b0d7d2/official/projects/movinet/files/kinetics_600_labels.txt "${WORKING_DIR}/kinetics_600_labels.txt"

# Set working directory to function root directory
WORKDIR ${WORKING_DIR}

# Install packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy script source
COPY src src/

ENV PYTHONPATH "${WORKING_DIR}/src"

# Run main script
ENTRYPOINT [ "/usr/bin/python3", "-m", "src.app" ]