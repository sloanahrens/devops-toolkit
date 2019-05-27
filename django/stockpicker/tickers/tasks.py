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
