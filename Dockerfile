# Define working directory
ARG WORKING_DIR="/tmp"

# Define function base image
ARG BASE_IMAGE=ubuntu:20.04
FROM $BASE_IMAGE

ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install wget, python, pip & ffmpeg
RUN apt-get update
RUN apt-get install -y wget python3 python3-pip ffmpeg

# Update pipe
RUN python3 -m pip install --upgrade pip

# Due to a bug, we reinstall tensorflow
# See https://stackoverflow.com/a/67177443

# Include global arg in this stage of the build
ARG WORKING_DIR

# Create function directory
RUN mkdir -p ${WORKING_DIR}

# Set working directory to function root directory
WORKDIR ${WORKING_DIR}

COPY requirements.txt .

# Install packages
RUN pip install -r requirements.txt --target .

# Copy script
COPY src/main.py .
COPY video.mp4 .

# Download Kinetics 600 label map
RUN wget https://raw.githubusercontent.com/tensorflow/models/f8af2291cced43fc9f1d9b41ddbf772ae7b0d7d2/official/projects/movinet/files/kinetics_600_labels.txt -O /tmp/labels.txt -q

RUN wget https://github.com/tensorflow/models/raw/f8af2291cced43fc9f1d9b41ddbf772ae7b0d7d2/official/projects/movinet/files/jumpingjack.gif -O /tmp/jumpingjack.gif -q

ENTRYPOINT [ "/usr/bin/python3", "main.py" ]


