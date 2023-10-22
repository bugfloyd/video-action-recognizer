# Define working directory
ARG WORKING_DIR="/tmp/video_recognition"

# Define function base image
ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

# Set timezone
ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install wget, python, pip & ffmpeg
RUN apt-get update
RUN apt-get install wget python3 python3-pip ffmpeg -y

# Update pipe
RUN python3 -m pip install --upgrade pip

# Include global arg in this stage of the build
ARG WORKING_DIR

# Create working and videos directories
RUN mkdir -p ${WORKING_DIR}
RUN mkdir -p "$WORKING_DIR/videos"

# Set working directory to function root directory
WORKDIR ${WORKING_DIR}

# Install packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy script source
COPY src .

# Copy Kinetics 600 label map/usr/bin/python3
# RUN wget https://raw.githubusercontent.com/tensorflow/models/f8af2291cced43fc9f1d9b41ddbf772ae7b0d7d2/official/projects/movinet/files/kinetics_600_labels.txt -O "${WORKING_DIR}/labels.txt" -q
COPY kinetics_600_labels.txt "${WORKING_DIR}/labels.txt"

# Run main script
ENTRYPOINT [ "/usr/bin/python3", "src/app.py" ]

