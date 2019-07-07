from django.urls import path
from django.contrib import admin
from django.conf.urls.static import static
from django.conf import settings

from tickers.views import (TickersLoadedView,
                           SearchTickerDataView,
                           GetRecommendationsView,
                           AddTickerView)

from stockpicker.views import (PickerPageView,
                               AppHealthCheckView,
                               CeleryHealthCheckView,
                               DatabaseHealthCheckView,
                               TickersLoadedHealthCheckView,
                               QuotesUpdatedHealthCheckView)

urlpatterns = [
    path('admin/', admin.site.urls),

    path('', PickerPageView.as_view(), name='picker_page'),

    path('tickers/tickerlist/', TickersLoadedView.as_view(), name='tickers_loaded'),

    path('tickers/tickerdata/', SearchTickerDataView.as_view(), name='search_ticker_data'),

    path('tickers/recommendations/', GetRecommendationsView.as_view(), name='get_recommendations'),

    path('tickers/addticker/', AddTickerView.as_view(), name='add_ticker'),

    path('health/app/', AppHealthCheckView.as_view()),
    path('health/celery/', CeleryHealthCheckView.as_view()),
    path('health/database/', DatabaseHealthCheckView.as_view()),
    path('health/tickers-loaded/', TickersLoadedHealthCheckView.as_view()),
    path('health/quotes-updated/', QuotesUpdatedHealthCheckView.as_view()),

] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
