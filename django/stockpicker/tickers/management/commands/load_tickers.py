from django.core.management import BaseCommand
from django.conf import settings

from tickers.models import Ticker


class Command(BaseCommand):

    def handle(self, *args, **options):
        for symbol in settings.DEFAULT_TICKERS:
            _, created = Ticker.objects.get_or_create(symbol=symbol)
            print('{0} {1}'.format(symbol, 'created' if created else 'exists'))
