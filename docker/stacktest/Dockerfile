FROM yikaus/alpine-bash

WORKDIR /usr/src

RUN apk update && apk upgrade && apk add curl jq

COPY ./docker/wait-for-it.sh /usr/bin/wait-for-it.sh
RUN chmod 755 /usr/bin/wait-for-it.sh

COPY ./docker/stacktest/integration-tests.sh .
RUN chmod 755 /usr/src/integration-tests.sh