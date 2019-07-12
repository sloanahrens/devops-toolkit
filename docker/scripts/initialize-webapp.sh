#!/bin/bash
set -e

echo "------------------"

echo "Waiting for dependencies..."
wait-for-it.sh -t 60 $REDIS_HOST:$REDIS_PORT
wait-for-it.sh -t 60 $RABBITMQ_HOST:$RABBITMQ_PORT
wait-for-it.sh -t 180 $POSTGRES_HOST:$POSTGRES_PORT

echo "Sleeping for 10 seconds..."
sleep 10

echo "Migrating databases..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Create default Tickers..."
python manage.py load_tickers

echo "Start Quotes Update Task..."
echo "from tickers.tasks import chained_ticker_updates; chained_ticker_updates.delay()" | python manage.py shell

echo "Start uWSGI..."
uwsgi --module stockpicker.wsgi:application --http 0.0.0.0:8001 --static-map /static=/srv/_static
