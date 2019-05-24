from django.db.utils import ProgrammingError
from django.utils.timezone import now

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
from rest_framework.permissions import AllowAny

from tickers.models import Ticker
from stockpicker.tasks import celery_worker_health_check


class AppHealthCheckView(APIView):

    def get(self, request, *args, **kwargs):

        return Response({'status': 'healthy'})


class DatabaseHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication, BasicAuthentication)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):

        try:
            # run a DB query (from the app node)
            return Response({'status': 'healthy',
                             'ticker_count': Ticker.objects.all().count()})

        except ProgrammingError as e:
            # this will tell k8s the webapp isn't ready yet
            Response(data={'status': 'unhealthy',
                           'reason': 'database query failed',
                           'exception': str(e)},
                     status=HTTP_412_PRECONDITION_FAILED)


class CeleryHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication, BasicAuthentication)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):

        try:
            #  Trigger a health check job (run db query from the worker).
            current_datetime = now()
            response = celery_worker_health_check.delay(current_datetime)
            assert response.get(timeout=6) == current_datetime
            return Response({'status': 'healthy'})

        except AssertionError as e:
            Response(data={'status': 'unhealthy',
                           'reason': 'celery job failed',
                           'exception': str(e)},
                     status=HTTP_412_PRECONDITION_FAILED)
