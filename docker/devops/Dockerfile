FROM python:3.6-stretch

ENV PYTHONUNBUFFERED 1

ENV DOCKER_VER "17.03.0-ce"

ENV TERRAFORM_VER "0.11.14"

ENV KOPS_VER "1.12.1"

WORKDIR /src

RUN apt-get -y update && \
    apt-get -y install software-properties-common jq curl unzip wget

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VER}_linux_amd64.zip && \
    mv terraform /usr/local/bin/

RUN curl -L -o /tmp/docker-${DOCKER_VER}.tgz https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VER}.tgz && \
    tar -xz -C /tmp -f /tmp/docker-${DOCKER_VER}.tgz && \
    mv /tmp/docker/* /usr/bin

RUN curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/

RUN curl -LO https://github.com/kubernetes/kops/releases/download/${KOPS_VER}/kops-linux-amd64 && \
    chmod +x kops-linux-amd64 && \
    mv ./kops-linux-amd64 /usr/local/bin/kops

RUN pip install --upgrade pip && \
    pip --no-cache-dir install --upgrade awscli
