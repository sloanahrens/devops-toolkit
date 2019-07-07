from django.db.utils import ProgrammingError

from stockpicker.celery import app
from tickers.models import Ticker


@app.task(bind=True, hard_time_limit=5)
def celery_worker_health_check(self, timestamp):

    try:
        Ticker.objects.all().count()
    except ProgrammingError:
        return None
    return timestamp
