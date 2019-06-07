#!/bin/bash
set -e

echo "------------------"
echo "Start Celery Worker..."
echo "------------------"
export C_FORCE_ROOT=true
celery worker -O fair -c 1 --app=stockpicker.celery --loglevel=info