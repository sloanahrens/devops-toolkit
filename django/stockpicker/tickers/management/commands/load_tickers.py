from django.core.management import BaseCommand
from django.conf import settings

from tickers.models import Ticker


class Command(BaseCommand):

    def handle(self, *args, **options):
        _, created = Ticker.objects.get_or_create(symbol=settings.INDEX_TICKER)
        print('{0} {1}'.format(settings.INDEX_TICKER, 'created' if created else 'exists'))
        for symbol in settings.DEFAULT_TICKERS:
            _, created = Ticker.objects.get_or_create(symbol=symbol)
            print('{0} {1}'.format(symbol, 'created' if created else 'exists'))
