#!/bin/bash
set -e

echo "------------------"
echo "Sleep three minutes..."
sleep 180

echo "Start Celery Beat..."
export C_FORCE_ROOT=true
celery beat --app=stockpicker.celery --loglevel=info