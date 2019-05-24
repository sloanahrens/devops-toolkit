from django.urls import path

from tickers.views import TickersLoadedView, SearchTickerDataView, GetRecommendationsView, AddTickerView

app_name = 'tickers'

urlpatterns = [

    path('tickerlist/', TickersLoadedView.as_view(), name='tickers_loaded'),

    path('tickerdata/', SearchTickerDataView.as_view(), name='search_ticker_data'),

    path('recommendations/', GetRecommendationsView.as_view(), name='get_recommendations'),

    path('addticker/', AddTickerView.as_view(), name='add_ticker'),

]
