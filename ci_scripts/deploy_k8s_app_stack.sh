#!/usr/bin/env bash

STACK_NAME="$1"
IMAGE_TAG="$2"
ENV_FILE="$3"
WEBAPP_REPLICAS="$4"
WORKER_REPLICAS="$5"

echo "Deploying k8s stack:"
echo "STACK_NAME: ${STACK_NAME}"
echo "IMAGE_TAG: ${IMAGE_TAG}"
echo "ENV_FILE: ${ENV_FILE}"
echo "WEBAPP_REPLICAS: ${WEBAPP_REPLICAS}"
echo "WORKER_REPLICAS: ${WORKER_REPLICAS}"

kubectl create namespace ${STACK_NAME}

kubectl -n ${STACK_NAME} create cm stack-environment-variables --from-env-file=./container_environments/${ENV_FILE}

cat kubernetes/spec_templates/redis.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} create -f -

cat kubernetes/spec_templates/rabbitmq.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} create -f -

cat kubernetes/spec_templates/postgres.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | kubectl -n ${STACK_NAME} create -f -

cat kubernetes/spec_templates/webapp.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@ENV_FILE@${ENV_FILE}@g" \
  | sed -e  "s@WEBAPP_REPLICAS@${WEBAPP_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} create -f -

cat kubernetes/spec_templates/celeryworker.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@ENV_FILE@${ENV_FILE}@g" \
  | sed -e  "s@WORKER_REPLICAS@${WORKER_REPLICAS}@g" \
  | kubectl -n ${STACK_NAME} create -f -

cat kubernetes/spec_templates/celerybeat.yaml \
  | sed -e  "s@STACK_NAME@${STACK_NAME}@g" \
  | sed -e  "s@IMAGE_TAG@${IMAGE_TAG}@g" \
  | sed -e  "s@ENV_FILE@${ENV_FILE}@g" \
  | kubectl -n ${STACK_NAME} create -f -

echo "Deployed stack \"${STACK_NAME}\"."