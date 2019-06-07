from django.conf import settings
from django.core.cache import cache

from stockpicker.celery import app
from tickers.models import Ticker
from tickers.utility import update_ticker_data


@app.task()
def update_all_tickers():

    update_ticker(settings.INDEX_TICKER)

    ticker_list = Ticker.objects.all().order_by('symbol')

    for ticker in ticker_list:
        update_ticker.delay(ticker.symbol)


@app.task()
def update_ticker(ticker_symbol):

    # cache.add returns False if the key already exists
    if not cache.add(ticker_symbol, 'true', 5 * 60):
        print('{0} has already been accepted by another task.'.format(ticker_symbol))
        return

    update_ticker_data(ticker_symbol)

    cache.delete(ticker_symbol)

    return ticker_symbol


@app.task()
def chained_ticker_updates(ticker_id=0):

    if Ticker.objects.filter(id=ticker_id).exists():
        ticker = Ticker.objects.get(id=ticker_id)
        if not cache.add(ticker.symbol, 'true', 5 * 60):
            print('{0} has already been accepted by another task.'.format(ticker.symbol))
            return
        update_ticker_data(ticker.symbol)
        cache.delete(ticker.symbol)

    next_ticker_id = ticker_id + 1
    for tid in list(Ticker.objects.order_by('id').values_list('id', flat=True)):
        if tid >= next_ticker_id and Ticker.objects.filter(id=tid).exists():
            next_ticker_id = tid
            break

    chained_ticker_updates.delay(next_ticker_id)
