FROM python:3.6-stretch

ENV PYTHONUNBUFFERED 1

WORKDIR /srv

RUN apt-get update && apt-get install -y postgresql

COPY ./django/requirements.txt /srv/requirements.txt

RUN pip --no-cache-dir install --progress-bar pretty -r requirements.txt