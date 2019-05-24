from django.core.management import BaseCommand
from django.conf import settings

from tickers.models import Ticker
from tickers.utility import update_ticker_data


class Command(BaseCommand):

    def handle(self, *args, **options):
        update_ticker_data(settings.INDEX_TICKER)
        for ticker in Ticker.objects.all():
            update_ticker_data(ticker.symbol)
