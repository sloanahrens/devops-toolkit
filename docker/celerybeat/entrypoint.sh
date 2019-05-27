#!/bin/bash
set -e

echo "------------------"
echo "Sleep 40 seconds..."
echo "------------------"
sleep 40

echo "------------------"
echo "Start Celery Beat..."
echo "------------------"
export C_FORCE_ROOT=true
celery beat --app=stockpicker.celery --loglevel=info