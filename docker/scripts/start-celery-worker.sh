#!/bin/bash
set -e

echo "------------------"
echo "Start Celery Worker..."
export C_FORCE_ROOT=true
celery worker -O fair -c 1 --app=stockpicker.celery --loglevel=info