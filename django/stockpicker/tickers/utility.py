from django.utils.timezone import datetime, timedelta

from django.conf import settings

from pandas_datareader import data as web
from pandas_datareader._utils import RemoteDataError

from tickers.models import Ticker, Quote


def update_ticker_data(symbol, force=False):

    def update_quotes(ticker_symbol, force_update=False):

        ticker, _ = Ticker.objects.get_or_create(symbol=ticker_symbol)

        last_business_day = datetime.today().date()
        # weekday() gives 0 for Monday through 6 for Sunday
        while last_business_day.weekday() > 4:
            last_business_day = last_business_day + timedelta(days=-1)

        # if last_business_day > ticker.latest_quote_date():

        # don't waste work
        if force_update or ticker.latest_quote_date() is None or ticker.latest_quote_date() < last_business_day:

            print('latest_quote_date: {0}, last_business_day: {1}'.format(ticker.latest_quote_date(),
                                                                          last_business_day))

            print('Updating: {0}'.format(ticker_symbol))

            today = datetime.now()
            start = today + timedelta(weeks=-settings.WEEKS_TO_DOWNLOAD)

            new_quotes = dict()
            yahoo_data = web.get_data_yahoo(ticker_symbol, start, today)
            print(yahoo_data)
            try:
                for row in yahoo_data.iterrows():
                    quote_date = row[0].strftime('%Y-%m-%d')
                    quote_data = row[1].to_dict()
                    new_quotes[quote_date] = quote_data
            except RemoteDataError:
                print('Error getting finance data for {0}'.format(ticker_symbol))
                return

            # base data from finance API:
            for quote_date, quote_data in new_quotes.items():
                try:
                    quote, _ = Quote.objects.get_or_create(ticker=ticker, date=quote_date)
                except Quote.MultipleObjectsReturned:
                    quote = Quote.objects.filter(ticker=ticker, date=quote_date).first()
                quote.high = quote_data['High']
                quote.low = quote_data['Low']
                quote.open = quote_data['Open']
                quote.close = quote_data['Close']
                quote.volume = quote_data['Volume']
                quote.adj_close = quote_data['Adj Close']
                quote.save()

            index_quotes_dict = {q.date: q for q in Ticker.objects.get(symbol=settings.INDEX_TICKER).quote_set.order_by('date')}

            ticker_quotes_list = [q for q in ticker.quote_set.order_by('date')]

            # set scaled_adj_close on all quotes first
            for quote in ticker_quotes_list:
                quote.index_adj_close = index_quotes_dict[quote.date].adj_close
                quote.scaled_adj_close = quote.adj_close / quote.index_adj_close

            # calculate moving average for each day
            for quote in ticker_quotes_list:
                moving_average_start = quote.date + timedelta(weeks=-settings.MOVING_AVERAGE_WEEKS)
                moving_average_quote_set = [q for q in ticker_quotes_list if moving_average_start <= q.date <= quote.date]
                moving_average_quote_values = [v.scaled_adj_close for v in moving_average_quote_set]
                quote.quotes_in_moving_average = len(moving_average_quote_values)
                quote.sac_moving_average = sum(moving_average_quote_values) / quote.quotes_in_moving_average
                quote.sac_to_sacma_ratio = quote.scaled_adj_close / quote.sac_moving_average

            # save changes
            for quote in ticker_quotes_list:
                quote.save()

            print('Found %s quotes for %s from %s to %s' % (len(new_quotes), ticker_symbol,
                                                            start.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')))

    # first update the index data, since we need it for calculations
    update_quotes(ticker_symbol=settings.INDEX_TICKER)

    update_quotes(ticker_symbol=symbol, force_update=force)
