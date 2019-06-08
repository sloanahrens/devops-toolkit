from celery.schedules import crontab

DEBUG = True

CELERY_BROKER_URL = 'amqp://guest:guest@localhost:5672//'
CELERY_RESULT_BACKEND = 'redis://'

CELERY_BEAT_SCHEDULE = {
    'quotes-hourly-update': {
        'task': 'tickers.tasks.chained_ticker_updates',
        'schedule': crontab(hour="*", minute="*", day_of_week='*'),
    }
}

# for a local sqlite database:
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
#     }
# }
