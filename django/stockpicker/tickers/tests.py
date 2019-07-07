import json
import random

from django.utils.timezone import datetime
from django.test import TestCase
from django.urls import reverse
from django.conf import settings

from tickers.models import Ticker, Quote


def fake_quote_serialize(quote):
    return {
        'symbol': quote.ticker.symbol,
        'date': quote.date.strftime('%Y-%m-%d'),
        'ac': round(float(quote.adj_close), settings.DECIMAL_DIGITS),
        'iac': round(float(quote.index_adj_close), settings.DECIMAL_DIGITS),
        'sac': round(float(quote.scaled_adj_close), settings.DECIMAL_DIGITS),
        'sac_ma': round(float(quote.sac_moving_average), settings.DECIMAL_DIGITS),
        'ratio': round(float(quote.sac_to_sacma_ratio), settings.DECIMAL_DIGITS)
    }


class TickerModelTests(TestCase):

    def setUp(self):
        Ticker.objects.create(symbol='TEST')

    def test_ticker_exists(self):
        self.assertTrue(Ticker.objects.get(symbol='TEST').id > 0)


class QuoteModelTests(TestCase):

    def setUp(self):
        Quote.objects.create(ticker=Ticker.objects.create(symbol='TEST'), date=datetime.today())

    def test_quote_exists(self):
        ticker = Ticker.objects.get(symbol='TEST')
        self.assertTrue(Quote.objects.get(ticker=ticker, date=datetime.today()).id > 0)

    def test_quote_serializes(self):
        ticker = Ticker.objects.get(symbol='TEST')
        quote = Quote.objects.get(ticker=ticker, date=datetime.today())
        self.assertEqual(
            json.dumps(quote.serialize()),
            json.dumps(fake_quote_serialize(quote)))


class TickersLoadedViewTests(TestCase):

    def test_no_tickers(self):
        response = self.client.get(reverse('tickers_loaded'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'tickers': []}))

    def test_ticker_exists(self):
        Ticker.objects.create(symbol='TEST')
        response = self.client.get(reverse('tickers_loaded'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'tickers': ["TEST"]}))


class SearchTickerDataViewTests(TestCase):

    def test_no_ticker(self):
        response = self.client.post(reverse('search_ticker_data'),
                                    content_type="application/json",
                                    data=json.dumps({'ticker': 'NOPE'}))
        self.assertEqual(response.status_code, 412)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': False,
                        'error': 'Ticker "NOPE" does not exist'}))

    def test_ticker_exists_but_no_data(self):
        Ticker.objects.create(symbol='TEST')
        response = self.client.post(reverse('search_ticker_data'),
                                    content_type="application/json",
                                    data=json.dumps({'ticker': 'TEST'}))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': True,
                        'ticker': 'TEST',
                        'index': settings.INDEX_TICKER,
                        'avg_weeks': 86, 'results': []}))

    def test_ticker_has_one_quote(self):
        def rand_value():
            return random.uniform(0, 10)
        ticker = Ticker.objects.create(symbol='TEST')
        quote = Quote.objects.create(ticker=ticker, date=datetime.today())
        quote.adj_close = rand_value()
        quote.index_adj_close = rand_value()
        quote.scaled_adj_close = rand_value()
        quote.sac_moving_average = rand_value()
        quote.sac_to_sacma_ratio = rand_value()
        quote.save()
        response = self.client.post(reverse('search_ticker_data'),
                                    content_type="application/json",
                                    data=json.dumps({'ticker': 'TEST'}))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': True,
                        'ticker': 'TEST',
                        'index': settings.INDEX_TICKER,
                        'avg_weeks': 86, 'results': [fake_quote_serialize(quote)]}))


class GetRecommendationsViewTests(TestCase):

    def test_index_ticker_does_not_exist(self):
        response = self.client.get(reverse('get_recommendations'))
        self.assertEqual(response.status_code, 412)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': False,
                        'error': 'Ticker "{0}" does not exist'.format(settings.INDEX_TICKER)}))

    def test_no_quotes_available(self):
        Ticker.objects.create(symbol=settings.INDEX_TICKER)
        response = self.client.get(reverse('get_recommendations'))
        self.assertEqual(response.status_code, 412)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': False,
                        'error': 'No Quotes available.'}))

    def test_buy_recommendation(self):
        Quote.objects.create(ticker=Ticker.objects.create(symbol=settings.INDEX_TICKER),
                             date=datetime.today())
        quote = Quote.objects.create(ticker=Ticker.objects.create(symbol='TEST'),
                                     date=datetime.today())
        quote.sac_to_sacma_ratio = 0.5
        quote.save()
        response = self.client.get(reverse('get_recommendations'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': True,
                        'latest_data_date': quote.date.strftime('%Y-%m-%d'),
                        'sell_hits': [],
                        'buy_hits': [fake_quote_serialize(quote)]}))

    def test_sell_recommendation(self):
        Quote.objects.create(ticker=Ticker.objects.create(symbol=settings.INDEX_TICKER),
                             date=datetime.today())
        quote = Quote.objects.create(ticker=Ticker.objects.create(symbol='TEST'),
                                     date=datetime.today())
        quote.sac_to_sacma_ratio = 1.5
        quote.save()
        response = self.client.get(reverse('get_recommendations'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': True,
                        'latest_data_date': quote.date.strftime('%Y-%m-%d'),
                        'sell_hits': [fake_quote_serialize(quote)],
                        'buy_hits': []}))
