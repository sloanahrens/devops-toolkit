FROM yikaus/alpine-bash

WORKDIR /usr/src

RUN apk update && apk upgrade && apk add curl jq

COPY ./docker/stacktest/integration-tests.sh .
RUN chmod 755 /usr/src/integration-tests.sh