#!/bin/bash
set -e

echo "------------------"
echo "Start Celery..."
echo "------------------"
export C_FORCE_ROOT=true
cd /src && celery worker -A stockpicker.celery --loglevel=warning -Ofair