from django.views.generic import TemplateView
from django.db.utils import ProgrammingError
from django.utils.timezone import now
from django.conf import settings

from celery.exceptions import TimeoutError

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import AllowAny

from tickers.models import Ticker, Quote
from stockpicker.tasks import celery_worker_health_check


class PickerPageView(TemplateView):

    template_name = 'tickers/picker.html'


class AppHealthCheckView(APIView):

    def get(self, request, *args, **kwargs):
        return Response({'status': 'healthy'})


def postgres_error_response(err):
    return Response(data={'status': 'unhealthy',
                          'reason': 'database query failed (ProgrammingError)',
                          'exception': str(err)},
                    status=HTTP_412_PRECONDITION_FAILED)


class DatabaseHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            # run a DB query (from the app node)
            ticker_count = Ticker.objects.all().count()
            return Response({'status': 'healthy',
                             'ticker_count': ticker_count})
        except ProgrammingError as e:
            return postgres_error_response(e)


class CeleryHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        current_datetime = now().strftime('%c')
        try:
            # trigger a health check job (run db query from the worker).
            task = celery_worker_health_check.delay(current_datetime)
            result = task.get(timeout=6)
        except TimeoutError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'celery job failed (TimeoutError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        try:
            assert result == current_datetime
        except AssertionError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'celery job failed (AssertionError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        return Response({'status': 'healthy'})


class TickersLoadedHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            # make sure all the default tickers are created
            assert Ticker.objects.filter(symbol=settings.INDEX_TICKER).exists()
            for ticker in settings.DEFAULT_TICKERS:
                assert Ticker.objects.filter(symbol=ticker).exists()
            return Response({'status': 'healthy',
                             'ticker_count': Ticker.objects.all().count()})
        except AssertionError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'tickers not loaded (AssertionError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            return postgres_error_response(e)


class QuotesUpdatedHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            # make sure all the quotes have been updated
            for ticker in [settings.INDEX_TICKER] + [t for t in settings.DEFAULT_TICKERS]:
                assert Ticker.objects.get(symbol=ticker).latest_quote_date() is not None
            return Response({'status': 'healthy',
                             'quote_count': Quote.objects.all().count()})
        except AssertionError:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'quotes not updated (AssertionError)'},
                status=HTTP_412_PRECONDITION_FAILED)
        except Ticker.DoesNotExist:
            return Response(
                data={'status': 'unhealthy',
                      'reason': 'tickers not loaded (DoesNotExist)'},
                status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            return postgres_error_response(e)
