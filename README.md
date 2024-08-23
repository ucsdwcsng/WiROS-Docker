# WiROS-Docker

This repo contains the instructions to use Docker images of WiROS and the relavant tools. The images contain pre-built environment and repository necessary for WiROS deployment, offering a more user-friendly usage of the setup. 

## Installation and Setup


### Step 1: Install Docker 

- #### Follow the instructions from [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    - The summary of commands to install is below:
    
        1. *(Optional)* Uninstall all conflicting packages
        ```
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
        ``` 
        2. Set up Docker's apt repository
        ``` 
        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        ``` 
        3. Install the latest Docker packages
        ```
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        ```
        4. *(Optional)* Verify the installation
        ```
        sudo docker run hello-world
        ```

### Step 2: Pull the Image from Docker Hub
 
 1. Login on Docker Hub

    ```
    sudo docker login    
    ```

2. Find the image of the right platform of your device from <!-- TODO: correct page for wcsng -->[this page](https://hub.docker.com/u/zhh013)
    - hint use `lscpu` to find your hardware architecture

3. Pull the corresponding image (E.g. wiros-arm-v7)

    ```
    sudo docker pull zhh013/wiros-arm-v7
    ```

### Step 3: Run the image (E.g. wiros-arm-v7)

1. Run the image in a interative terminal and host network mode  
    ```
    sudo docker run -it --name=YOUR_CONTAINER_NAME --network=host zhh013/wiros-arm-v7
    ```

2.  Follow the [instructions](https://github.com/ucsdwcsng/wiros_csi_node?tab=readme-ov-file#usage-instructions) to use **WiROS**. **WiROS** workspace is compiled and ready-to-use under root directory.
    - E.g. 
        ```
        cd ~/wiros/src/wiros_csi_node/launch/  
        roslaunch basic.launch
        ```
    - Hint: remember to configure your `.launch` file and `emacs` is installed.
<!-- TODO: add env var to configure the wiros and context -->

