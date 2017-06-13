#!/bin/bash
set -e

# This script follows the installation instructions from docs.docker.com/engine/installation/linux/ubuntu

sudo apt-get update

# Install packages to allow apt to use repository over HTTPS
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Install Stable
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce

curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > docker-compose
sudo chmod +x docker-compose
sudo mv docker-compose /usr/local/bin/docker-compose

