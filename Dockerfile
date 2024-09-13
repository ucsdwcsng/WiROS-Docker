# Use Ubuntu 20.04 as the base image
FROM zhh013/wiros-arm-v7:latest
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
    jq \
    unzip \
    python-is-python3 \
    python3.8-venv \
    screen \
    pip && \
    # Change the version if necessary! 
    # curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    # unzip awscliv2.zip && \
    # sudo ./aws/install 
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws 
    # network-manager \



# Only initialize rosdep if the sources list file does not already exist
RUN [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ] && rosdep init || echo "rosdep already initialized" \
    && rosdep update 
    

# Set up environment variables
# Create a wiros workspace 
SHELL ["/bin/bash", "-c"]
RUN source /opt/ros/noetic/setup.bash && \
    export SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt && \
    mkdir -p ~/wiros/src && \
    cd ~/wiros/src && \
    # Array of repositories
    repos=( \
        "https://github.com/ucsdwcsng/wiros_csi_node.git" \
        "https://github.com/ucsdwcsng/rf_msgs.git" \
        "https://github.com/WS-UB/imu_publisher.git" \
    ) && \
    # Check if a repo exists, if not, clone it
    for repo in "${repos[@]}"; do \
        repo_name=$(basename -s .git $repo); \
        if [ -d "$repo_name" ]; then \
            echo "$repo_name already exists, skipping clone."; \
        else \
            echo "$repo_name does not exist, cloning repository..."; \
            git clone $repo; \
        fi; \
    done && \
    cd wiros_csi_node && \
    git checkout cleanup && \
    cd ../.. && \
    catkin init && \
    catkin build && \
    echo "source ~/wiros/devel/setup.bash" >> ~/.bashrc && \
    cd && \
    repo="https://github.com/ucsdwcsng/wiros_data_collection.git" && \
    # Extract the repository name
    repo_name=$(basename -s .git $repo) && \
    # Check if the repo exists, if not, clone it
    if [ -d "$repo_name" ]; then \
        echo "$repo_name already exists, skipping clone."; \
    else \
        echo "$repo_name does not exist, cloning repository..."; \
        git clone $repo; \
    fi && \
    curl https://www.amazontrust.com/repository/AmazonRootCA1.pem > root-CA.crt && \
    repo="https://github.com/aws/aws-iot-device-sdk-python-v2.git" && \
    # Extract the repository name
    repo_name=$(basename -s .git $repo) && \
    # Check if the repo exists, if not, clone it
    if [ -d "$repo_name" ]; then \
        echo "$repo_name already exists, skipping clone."; \
    else \
        echo "$repo_name does not exist, cloning repository..."; \
        git clone $repo; \
    fi && \
    python3 -m pip install ./aws-iot-device-sdk-python-v2


# Set the default command to run a bash shell
CMD ["bash"]