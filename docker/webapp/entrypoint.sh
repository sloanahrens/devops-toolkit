#!/bin/bash
set -e

echo "------------------"
echo "Waiting for dependencies..."
echo "------------------"
wait-for-it.sh -t 60 $REDIS_HOST:$REDIS_PORT
wait-for-it.sh -t 60 $RABBITMQ_HOST:$RABBITMQ_PORT
wait-for-it.sh -t 180 $POSTGRES_HOST:$POSTGRES_PORT

echo "------------------"
echo "Sleeping for 10 seconds..."
echo "------------------"
sleep 10

echo "------------------"
echo "Migrating databases..."
echo "------------------"
python manage.py migrate

echo "------------------"
echo "Collecting static files..."
echo "------------------"
python manage.py collectstatic --noinput

echo "------------------"
echo "Create default Tickers..."
echo "------------------"
python manage.py load_tickers

echo "------------------"
echo "Start uWSGI..."
echo "------------------"
uwsgi --module stockpicker.wsgi:application --http 0.0.0.0:8001 --static-map /static=/srv/_static