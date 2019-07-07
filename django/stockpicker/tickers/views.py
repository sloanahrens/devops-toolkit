from django.conf import settings

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_412_PRECONDITION_FAILED, HTTP_200_OK
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import AllowAny

from tickers.models import Ticker, Quote
from tickers.utility import update_ticker_data


class SearchTickerDataView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def post(self, request, format=None):

        ticker_symbol = request.data['ticker']
        try:
            ticker = Ticker.objects.get(symbol=ticker_symbol)
        except Ticker.DoesNotExist:
            return Response({'success': False, 'error': 'Ticker "{0}" does not exist'.format(ticker_symbol)},
                            status=HTTP_412_PRECONDITION_FAILED)

        return Response({
            'success': True,
            'ticker': ticker.symbol,
            'index': settings.INDEX_TICKER,
            'avg_weeks': settings.MOVING_AVERAGE_WEEKS,
            'results': [quote.serialize() for quote in ticker.quote_set.order_by('date')]
        }, status=HTTP_200_OK)


class TickersLoadedView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, format=None):

        return Response({'tickers': [t.symbol for t in Ticker.objects.order_by('symbol')]}, status=HTTP_200_OK)


class GetRecommendationsView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, format=None):

        try:
            index_ticker = Ticker.objects.get(symbol=settings.INDEX_TICKER)
        except Ticker.DoesNotExist:
            return Response({'success': False, 'error': 'Ticker "{0}" does not exist'.format(settings.INDEX_TICKER)},
                            status=HTTP_412_PRECONDITION_FAILED)

        if index_ticker.latest_quote_date() is None:
            return Response({'success': False, 'error': 'No Quotes available.'}, status=HTTP_412_PRECONDITION_FAILED)

        sell_hits = Quote.objects.filter(date=index_ticker.latest_quote_date(),
                                         sac_to_sacma_ratio__gt=1).order_by('-sac_to_sacma_ratio')
        buy_hits = Quote.objects.filter(date=index_ticker.latest_quote_date(),
                                        sac_to_sacma_ratio__gt=0,
                                        sac_to_sacma_ratio__lt=1).order_by('sac_to_sacma_ratio')
        return Response({
            'success': True,
            'latest_data_date': index_ticker.latest_quote_date().strftime('%Y-%m-%d'),
            'sell_hits': [quote.serialize() for quote in list(sell_hits)[:25]],
            'buy_hits': [quote.serialize() for quote in list(buy_hits)[-25:]]
        }, status=HTTP_200_OK)


class AddTickerView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def post(self, request, format=None):

        ticker_symbol = request.data['ticker']
        update_ticker_data(ticker_symbol, force=True)

        return Response({'success': True}, status=HTTP_200_OK)
