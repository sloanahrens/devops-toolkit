#!/usr/bin/env bash


function run_install {
#    apt-get -y update
#    apt-get -y install software-properties-common
    apt-add-repository universe
    apt-get -y update
    apt-get -y install jq curl
    # aws cli
#    apt-get -y install python-dev python-pip
#    pip install awscli --allow-all-external
    pip install awscli
    # kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/
    # docker client
    VER="17.03.0-ce"
    curl -L -o /tmp/docker-$VER.tgz https://get.docker.com/builds/Linux/x86_64/docker-$VER.tgz
    tar -xz -C /tmp -f /tmp/docker-$VER.tgz
    mv /tmp/docker/* /usr/bin
    # docker-compose
    curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}


echo "Installing dependencies.."
finished='Finished installing dependencies!'
again='Trying Again!'
failed='Failed after three tries!'
(run_install && echo $finished) || (echo $again && run_install && echo $finished) || (echo $again && run_install && echo $finished) || echo $failed
