import os

from celery.schedules import crontab

DEBUG = os.getenv('APP_DEBUG', False)

STATIC_ROOT = "/src/_static"

ALLOWED_HOSTS = ['*']

CELERY_BEAT_SCHEDULE = {
    'quotes-hourly-update': {
        'task': 'tickers.tasks.chained_ticker_updates',
        # # for production:
        'schedule': crontab(hour="*", minute=0, day_of_week='mon,tue,wed,thu,fri'),
        # for local development testing:
        # 'schedule': crontab(hour="*", minute="*", day_of_week='*'),
    }
}
