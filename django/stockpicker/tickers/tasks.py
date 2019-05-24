from django.conf import settings

from psycopg2 import ProgrammingError

from stockpicker.celery import app
from tickers.models import Ticker
from tickers.utility import update_ticker_data


@app.task()
def update_all_tickers():

    try:
        ticker_list = Ticker.objects.all().order_by('symbol')
    except ProgrammingError:
        print('Database Not Ready!')
        return

    update_ticker.delay(settings.INDEX_TICKER)

    for ticker in ticker_list:
        update_ticker.delay(ticker.symbol)


@app.task()
def update_ticker(ticker_symbol):

    update_ticker_data(ticker_symbol)

    return ticker_symbol

