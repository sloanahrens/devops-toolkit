FROM python:3.6-stretch

ENV PYTHONUNBUFFERED 1

WORKDIR /src

RUN apt-get update && apt-get install -y postgresql

COPY ./docker/scripts/wait-for-it.sh /usr/bin/wait-for-it.sh
RUN chmod 755 /usr/bin/wait-for-it.sh

COPY ./django/requirements.txt /src/requirements.txt

RUN pip --no-cache-dir install --progress-bar pretty -r requirements.txt