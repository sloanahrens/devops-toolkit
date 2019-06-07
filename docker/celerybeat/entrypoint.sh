#!/bin/bash
set -e

echo "------------------"
echo "Sleep three minutes..."
echo "------------------"
sleep 180

echo "------------------"
echo "Start Celery Beat..."
echo "------------------"
export C_FORCE_ROOT=true
celery beat --app=stockpicker.celery --loglevel=info