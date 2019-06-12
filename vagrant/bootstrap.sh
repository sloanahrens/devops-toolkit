#!/usr/bin/env bash

export PYTHONUNBUFFERED=1

export TERRAFORM_VER="0.11.14"

export KOPS_VER="1.12.1"

echo "Installing Apt Dependencies..."
apt-get -y update
apt-get -y install software-properties-common jq curl unzip wget
apt-get -y install python3-pip python3-dev python3-venv libpq-dev

echo "Installing AWS CLI..."
pip3 install --upgrade awscli

echo "Installing Docker..."
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -y update
apt-cache policy docker-ce
apt-get install -y docker-ce
systemctl status docker
usermod -aG docker ubuntu

echo "Installing Docker-Compose..."
curl -s -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Installing Kubectl..."
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/

echo "Installing Kops..."
curl -s -LO https://github.com/kubernetes/kops/releases/download/${KOPS_VER}/kops-linux-amd64
chmod +x kops-linux-amd64
mv ./kops-linux-amd64 /usr/local/bin/kops

echo "Installing Terraform..."
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip --quiet
unzip terraform_${TERRAFORM_VER}_linux_amd64.zip
mv terraform /usr/local/bin/

echo "Done."