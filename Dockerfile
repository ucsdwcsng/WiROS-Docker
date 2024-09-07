# Use Ubuntu 20.04 as the base image
FROM zhh013/wiros-amd64:latest
# FROM zhh013/wiros:basic-env
# FROM wiros_from_20.04

# Set the timezone to avoid interactive prompts during the installation
ENV TZ=Etc/UTC

# Prevent interactive prompts and set environment variables for language and encoding
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install necessary dependencies
RUN apt update && apt install -y \
    lsb-release \
    gnupg2 \
    curl \
    git \
    locales \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && rm -rf /var/lib/apt/lists/*

# Set up locales for UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8


# Add ROS Noetic repository

# Set up the keys
# RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Update package list and install ROS Noetic
RUN apt update && apt install -y \
    # ros-noetic-desktop-full \
    ros-noetic-ros-base \
    && rm -rf /var/lib/apt/lists/*
    
# Use bash -c to execute the source command
RUN bash -c "source /opt/ros/noetic/setup.bash" && \
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc 



RUN bash -c "source ~/.bashrc" && \
    apt-get update && apt-get install -y \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
    ros-noetic-catkin \
    python3-catkin-tools \
    emacs \
    sshpass \
    inetutils-ping \
    jq
    # network-manager \


# EXPOSE 5500/udp

# # Only initialize rosdep if the sources list file does not already exist
# RUN [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ] && rosdep init || echo "rosdep already initialized" \
#     && rosdep update 
    

# Set up environment variables
# Create a wiros workspace 
SHELL ["/bin/bash", "-c"]
RUN /bin/bash -c "source ~/.bashrc" && \
    source /opt/ros/noetic/setup.bash && \
    export SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt && \
    rosdep init && rosdep update && \
    mkdir -p ~/wiros/src && \
    cd ~/wiros/src && \
    git clone https://github.com/ucsdwcsng/wiros_csi_node.git && \
    git clone https://github.com/ucsdwcsng/rf_msgs.git && \
    git clone https://github.com/WS-UB/imu_publisher.git && \
    cd wiros_csi_node && \
    git checkout cleanup && \
    cd ../.. && \
    catkin init && \
    catkin build && \
    echo "source ~/wiros/devel/setup.bash" >> ~/.bashrc && \
    cd && \
    git clone https://github.com/ucsdwcsng/wiros_data_collection.git


# Set the default command to run a bash shell
CMD ["bash"]
