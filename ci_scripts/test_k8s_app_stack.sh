#!/usr/bin/env bash

STACK_NAME="$1"

echo "Testing: ${STACK_NAME}.sloanahrens.com"

docker run -e SERVICE="https://${STACK_NAME}.sloanahrens.com" stacktest ./integration-tests.sh \
    || \
    (echo "*** PODS:" && echo "$(kubectl -n ${STACK_NAME} get pods)" && \
    WEBAPP_POD=$(kubectl -n ${STACK_NAME} get pod -l service=webapp -o jsonpath="{.items[0].metadata.name}") && \
    WORKER_POD=$(kubectl -n ${STACK_NAME} get pod -l service=celeryworker -o jsonpath="{.items[0].metadata.name}") && \
    echo "*** WORKER LOGS:" && echo "$(kubectl -n ${STACK_NAME} logs $WORKER_POD)" && \
    echo "*** WEBAPP LOGS:" && echo "$(kubectl -n ${STACK_NAME} logs $WEBAPP_POD)" && \
    echo "Integration Tests Failed. See response and logs output above." && exit 1)