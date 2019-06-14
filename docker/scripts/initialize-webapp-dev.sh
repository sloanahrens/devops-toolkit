#!/bin/bash
set -e

echo "------------------"

echo "Waiting for postgres..."
wait-for-it.sh -t 60 $POSTGRES_HOST:$POSTGRES_PORT

echo "Sleeping for 3 seconds..."
sleep 3

echo "Migrating databases..."
python manage.py migrate

echo "Start Development Server..."
python manage.py runserver 0.0.0.0:8000