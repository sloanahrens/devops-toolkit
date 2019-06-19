# A Toy Stock-Picker Application, Part 1: Django

### Intro
In order to do our DevOps work, we need a software application to build, test and deploy. 
We will ultimately deploy our application as several microservices, but first we have to build it. 
We could have approached the problem of building a modern DevOps system by using a pre-built application that we found somewhere on the Internet. 
However, since the purpose of the system we are building is, in fact, to support the building, testing and deployment of a software application, and since the deployment of any application is going to involve plenty of details about how that application functions, I think it makes sense to build the app ourselves so that we have a good handle on what it takes to run it.
 
So I had to pick a specific set of tools to use to build the application. 
I chose Python, Django and Celery, because I'm already pretty familiar with these technologies and how to deploy them. 
(Maybe one of these days I'll build a module that uses a [Go](https://golang.org/) app.)

DevOps typically involves using many different tools, and learning to use new tools is part of the game.
I'm not going to spend much time explaining each of the tools. 
I'm kind of a generalist, and I tend to dig just as far into a new tool as I need to, to accomplish whatever I need to do with that tool.
I will provide references for further study, of course, but I'm usually going to explain just as much as is needed for the problem at hand.

I would hope that the [Python](https://www.python.org/) programming language needs no introduction. 
If you are not already familiar with Python--or indeed have never done any computer programming whatsoever--you are in luck, because Python is pretty easy to learn at a basic level.
I highly recommend Zed Shaw's [Learn Python the Hard Way](https://learnpythonthehardway.org/).

[Django](https://www.djangoproject.com/) is known as "The web framework for perfectionists with deadlines.", and that's a pretty good description. 
I am very far from a Django expert, but I've been using it for several years now, and I am a big fan.
Django provides all the parts needed to quickly build a working web application, has a huge community and extensive documentation. 
It's certainly not the only way to build a Python web app ([Flask](http://flask.pocoo.org/) is a great tool as well; my general rule is that if I need an [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping), I use Django, if not I use Flask).

[Celery](http://www.celeryproject.org/) is a widely-used Python library (that also works with other languages) for setting up an asynchronous task-processing system.
In the world of Data Engineering (Data Engineers put Data Science into Production), asynchronous task-based data processing is an essential tool, and Celery is a relatively easy way to get it done.

[PostgreSQL](https://www.postgresql.org/) bills itself as, "The World's Most Advanced Open Source Relational Database", and I'm not going to argue with them.
There are lots of choices for data-store--many are highly specialized for certain tasks, like [Elasticsearch](https://www.elastic.co/products/elasticsearch) (distributed full-text search and analytics), and so choosing data-store(s) can be a critical engineering decision.
Unless I need some other data-store for some specific reason, however, Postgres is always my default choice. 
Thanks to sensible default behavior, it usually "just works".

The app has a number of other dependencies as well, and I will point them out very briefly along the way.

There are also plenty of DevOps dependencies we will need along the way, but the development environment will take care of most of them.


### Set up the development environment

The first thing you will need to do is set up your local development environment as described [here](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/local-development-environment.md).

If you are not familiar with [Docker](https://www.docker.com/) yet, do not fear. 
We are going to be using it enough that I think you will begin to get a feel for what it really is.


### Use a new source directory

Once you have Docker installed and the development environment working, start it with:

```bash
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src --rm --name local_dev devops /bin/bash
```

Now we are running inside the container, and you should see a prompt similar to:

```
root@1c80236a5992:/src#
```

Now exit the container (type `exit`) and we are going to modify the basic command a bit.
The purpose of this tutorial is to re-build the Django/Celery web application.
So instead of sharing the existing `devops-toolkit` directory, we're going to give the development environment a different path.

From inside the `devops-toolkit` directory, create a new directory called `source`, and a directory inside it called `django`:

```bash
mkdir -p source/django
```

Now we can use a slightly modified version of the standard development environment docker command:

```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/source/django:/src \
  --name local_dev \
  --rm \
  devops \
  /bin/bash
```

If you get an error message like:

```
docker: Error response from daemon: Conflict. The container name "/local_dev" is already in use by ...
```

remove the existing container with:

```bash
docker rm local_dev
```

and then run the `docker run` command again.

### Create a Django project

So now we are running inside the development environment, with an empty working directory.
You should see an empty working directory, like:

```
root@452f6c62c2ad:/src# ls
root@452f6c62c2ad:/src#
```

Now we are finally going to start building a Django application.
First we need to install the Django libary with [`pip`](https://www.w3schools.com/python/python_pip.asp):

```bash
pip install Django==2.2.2
```

(We could simply use `pip install django` and it would work, but I want to match the version currently used in the current code repository, so I'm giving `pip` that specific version.)

We're going to use a Python [requirements file](https://www.idkrtm.com/what-is-the-python-requirements-txt/).
The purpose of `requirements.txt` is to record our specific python dependencies and lock in version numbers. 
So along the way, as we add new dependencies, we will export them to the file with:

```bash
pip freeze > /src/requirements.txt
```

Now that Django is installed, we can create a [new Django project](https://docs.djangoproject.com/en/2.2/intro/tutorial01/#creating-a-project), with:

```bash
django-admin startproject stockpicker
```

Let’s look at what `startproject` created:

```
stockpicker/
    manage.py
    stockpicker/
        __init__.py
        settings.py
        urls.py
        wsgi.py
```

Our django project needs an app, called `tickers`, and we can [create it with](https://docs.djangoproject.com/en/2.2/intro/tutorial01/#creating-the-polls-app):

```bash
cd stockpicker
python manage.py startapp tickers
```

That’ll create a directory called `tickers`, which is laid out like this:

```
tickers/
    __init__.py
    admin.py
    apps.py
    migrations/
        __init__.py
    models.py
    tests.py
    views.py
```

You'll have to add the line `'tickers',` to `INSTALLED_APPS` in `stockpicker/stockpicker/settings.py` so the project will find it.

### Django database setting

Django is compatible with a number of different [databases](https://docs.djangoproject.com/en/2.2/ref/databases/).
For this tutorial we are going to use the default [SQLite](https://sqlite.org/index.html) database.
It should not be used in production but can be useful for development and code-testing, and provides conceptual simplicity at this stage of the tutorial.
The [PostgreSQL microservices tutorial](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/local-development-environment.md) adds a Postgres database to the development stack.

### Build and test models

We're going to add the following code to `stockpicker/tickers/models.py`, and it will serve as the foundation of the `stockpicker` application:

```python
from django.db import models
from django.utils.timezone import now
from django.conf import settings


class Ticker(models.Model):
    created = models.DateTimeField(default=now)

    symbol = models.CharField(max_length=10, db_index=True)

    def latest_quote_date(self):
        if self.quote_set.count() > 0:
            return self.quote_set.order_by('-date').first().date
        return None

    def __str__(self):
        return self.symbol


class Quote(models.Model):
    created = models.DateTimeField(default=now)

    ticker = models.ForeignKey(Ticker, on_delete=models.PROTECT)

    date = models.DateField(db_index=True)

    high = models.FloatField(default=0)
    low = models.FloatField(default=0)
    open = models.FloatField(default=0)
    close = models.FloatField(default=0)
    volume = models.FloatField(default=0)
    adj_close = models.FloatField(default=0)

    index_adj_close = models.FloatField(default=0)
    scaled_adj_close = models.FloatField(default=0)
    sac_moving_average = models.FloatField(default=0)
    sac_to_sacma_ratio = models.FloatField(default=0)
    quotes_in_moving_average = models.IntegerField(default=0)

    def __str__(self):
        return '{0}-{1}'.format(self.ticker.symbol, self.date)

    def serialize(self):
        return {
            'symbol': self.ticker.symbol,
            'date': self.date.strftime('%Y-%m-%d'),
            'ac': round(self.adj_close, settings.DECIMAL_DIGITS),
            'iac': round(self.index_adj_close, settings.DECIMAL_DIGITS),
            'sac': round(self.scaled_adj_close, settings.DECIMAL_DIGITS),
            'sac_ma': round(self.sac_moving_average, settings.DECIMAL_DIGITS),
            'ratio': round(self.sac_to_sacma_ratio, settings.DECIMAL_DIGITS)
        }

```

These two models will be used to create corresponding database tables, and manage data.
Both models have `__str__` [magic methods](https://www.python-course.eu/python3_magic_methods.php) that provides the string representation of the object (row from the corresponding database table).

The `Ticker` model will be used to represent stock market tickers for specific companies, and all the `Quotes` for that `Ticker` will be properly organized via the `ticker` foreign-key property on the `Quote` model.
Each `Ticker` object has easy access to all its child `Quotes` via the `quote_set` method, which is used in `Ticker.latest_quote_date` above.

Each `Quote` object represents a specific stock price quote (`high`, `low`, `open`, `close`, `volume`, and `adj_close`) for a specific `date`, along with some related analytical fields we'll talk about later.
The `Quote` object also has a `serialize` method that is used to easily convert the object to JSON.

### Django database migration

Now twe need to create our first [Django database migration](https://docs.djangoproject.com/en/2.2/topics/migrations/) with:

```bash
python manage.py makemigrations 
```

If you see `No changes detected` then you forgot to add `'tickers',` to `INSTALLED_APPS` above.

You should see:

```
root@d1fdee37d94d:/src/django/stockpicker# python manage.py makemigrations
Migrations for 'tickers':
  tickers/migrations/0001_initial.py
    - Create model Ticker
    - Create model Quote
```

This will create a file in `stockpicker/tickers/migrations` that will define the database tables we need.
We can create a local database using the default database provider [SQLite](https://sqlite.org/index.html), by simply running:

```bash
python manage.py migrate
```

You should see:

```
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions, tickers
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying auth.0010_alter_group_name_max_length... OK
  Applying auth.0011_update_proxy_permissions... OK
  Applying sessions.0001_initial... OK
  Applying tickers.0001_initial... OK
root@d1fdee37d94d:/src/stockpicker#
```

Now that we have some models, we can test them with some unit tests.
Add the following code to `stockpicker/tickers/tests.py`:

```python
import json

from django.utils.timezone import datetime
from django.test import TestCase
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
```

We also need to add this setting to `stockpicker/stockpicker/settings.py`:

```python
DECIMAL_DIGITS = 4
```

Now that we have some unit tests, we can run them with:

```bash
python manage.py test
```

You should see the following output:

```
root@d1fdee37d94d:/src/django/stockpicker# python manage.py test
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
...
----------------------------------------------------------------------
Ran 3 tests in 0.010s

OK
Destroying test database for alias 'default'...
```

We have models and unit tests! Now we need some data.


### Stock quote utility function

We're going to build code to populate our database. 
The first thing we will need is a utility function to gather the stock price data.
Don't get too caught up in the math that this code is doing; it will make more sense once you see the graphs of the data.
Create `stockpicker/tickers/utility.py` with the following contents:

```python
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

        # don't waste work
        if force_update or ticker.latest_quote_date() is None or ticker.latest_quote_date() < last_business_day:

            print('latest_quote_date: {0}, last_business_day: {1}'.format(ticker.latest_quote_date(),
                                                                          last_business_day))

            print('Updating: {0}'.format(ticker_symbol))

            today = datetime.now()
            start = today + timedelta(weeks=-settings.WEEKS_TO_DOWNLOAD)

            new_quotes = dict()
            yahoo_data = web.get_data_yahoo(ticker_symbol, start, today)
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

```

In order for this code to work, we will need to install some more python dependencies, with:

```bash
pip install fix-yahoo-finance==0.1.33
pip install pandas-datareader==0.7.0
```

And `pip freeze` again:


```bash
pip freeze > /src/requirements.txt
```

### Load data with Django management commands

Now we're going to create two new [Django management commands](https://docs.djangoproject.com/en/2.2/howto/custom-management-commands/).

Create new directories and empty files in `stockpicker/tickers` such that your layout looks like:

```
tickers/
    __init__.py
    management/
        __init__.py
        commands/
            __init__.py
            load_tickers.py
            update_ticker_quotes.py
    tests.py
    views.py
    ...
```

The contents of `load_tickers.py` should be:

```python
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

```

The contents of `update_ticker_quotes.py` should be:

```python
from django.core.management import BaseCommand
from django.conf import settings

from tickers.models import Ticker
from tickers.utility import update_ticker_data


class Command(BaseCommand):

    def handle(self, *args, **options):
        update_ticker_data(settings.INDEX_TICKER)
        for ticker in Ticker.objects.all():
            update_ticker_data(ticker.symbol)

```

This gives us new commands that we can use with `manage.py`.

We also need some default tickers, and a few other settings.
Add the following settings to `stockpicker/stockpicker/settings.py`:

```python
DECIMAL_DIGITS = 4
MOVING_AVERAGE_WEEKS = 86
WEEKS_TO_DOWNLOAD = 260

INDEX_TICKER = 'SPY'

DEFAULT_TICKERS = [
    'GOOG',
    'AMZN',
    'FB',
    'EBAY',
    'TWTR',
    'IBM',
    'AAPL',
    'MSFT',
    'TSLA',
]
```

Now let's load our tickers with:

```bash
python manage.py load_tickers
```

You should see:

```
root@d1fdee37d94d:/src/django/stockpicker# python manage.py load_tickers
SPY created
GOOG created
AMZN created
FB created
EBAY created
TWTR created
IBM created
AAPL created
MSFT created
TSLA created
```

And we can load our stock quotes data (this will take a couple minutes):

```bash
python manage.py update_ticker_quotes
```

This management command will take a few minutes to run. 
You should see this once it's done:

```
root@7f6fa6d500af:/src/django/stockpicker# python manage.py update_ticker_quotes
latest_quote_date: None, last_business_day: 2019-06-14
Updating: SPY
Found 1255 quotes for SPY from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: GOOG
Found 1255 quotes for GOOG from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: AMZN
Found 1255 quotes for AMZN from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: FB
Found 1255 quotes for FB from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: EBAY
Found 1255 quotes for EBAY from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: TWTR
Found 1255 quotes for TWTR from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: IBM
Found 1255 quotes for IBM from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: AAPL
Found 1255 quotes for AAPL from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: MSFT
Found 1255 quotes for MSFT from 2014-06-20 to 2019-06-14
latest_quote_date: None, last_business_day: 2019-06-14
Updating: TSLA
Found 1255 quotes for TSLA from 2014-06-20 to 2019-06-14
```

Now we have data! Next we need some views.

### Install Django REST Framework

Our API views will use the [Django REST Framework](), so we need to install it with:

```bash
pip install djangorestframework==3.9.3
pip freeze > /src/requirements.txt
```


We also need to add the following line to `INSTALLED_APPS` in `stockpicker/stockpicker/settings.py`:

```python
'rest_framework',
```

### Building API views, with tests

To build our API views, accompanying URLs, and unit tests, we will need to edit four files.

First, create `stockpicker/tickers/urls.py` with the following contents:

```python
from django.urls import path

from tickers.views import TickersLoadedView, SearchTickerDataView, GetRecommendationsView, AddTickerView

app_name = 'tickers'

urlpatterns = [

    path('tickerlist/', TickersLoadedView.as_view(), name='tickers_loaded'),

    path('tickerdata/', SearchTickerDataView.as_view(), name='search_ticker_data'),

    path('recommendations/', GetRecommendationsView.as_view(), name='get_recommendations'),

    path('addticker/', AddTickerView.as_view(), name='add_ticker'),

]

```

Now edit the existing `stockpicker/stockpicker/urls.py` file as:

```python
from django.contrib import admin
from django.urls import path, include

from tickers.views import PickerPageView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', PickerPageView.as_view(), name='picker_page'),
    path('tickers/', include('tickers.urls', namespace='tickers')),
]

```

Next edit the contents of `stockpicker/tickers/views` to match:

```python
from django.views.generic import TemplateView
from django.conf import settings

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_412_PRECONDITION_FAILED, HTTP_200_OK
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import AllowAny

from tickers.models import Ticker, Quote
from tickers.utility import update_ticker_data


class PickerPageView(TemplateView):

    template_name = 'tickers/picker.html'


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

```

And finally we need to add unit tests for the views.
Edit the full contents of `stockpicker/tickers/tests.py` to:

```python
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
        response = self.client.get(reverse('tickers:tickers_loaded'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'tickers': []}))

    def test_ticker_exists(self):
        Ticker.objects.create(symbol='TEST')
        response = self.client.get(reverse('tickers:tickers_loaded'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'tickers': ["TEST"]}))


class SearchTickerDataViewTests(TestCase):

    def test_no_ticker(self):
        response = self.client.post(reverse('tickers:search_ticker_data'),
                                    content_type="application/json",
                                    data=json.dumps({'ticker': 'NOPE'}))
        self.assertEqual(response.status_code, 412)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': False,
                        'error': 'Ticker "NOPE" does not exist'}))

    def test_ticker_exists_but_no_data(self):
        Ticker.objects.create(symbol='TEST')
        response = self.client.post(reverse('tickers:search_ticker_data'),
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
        response = self.client.post(reverse('tickers:search_ticker_data'),
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
        response = self.client.get(reverse('tickers:get_recommendations'))
        self.assertEqual(response.status_code, 412)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': False,
                        'error': 'Ticker "{0}" does not exist'.format(settings.INDEX_TICKER)}))

    def test_no_quotes_available(self):
        Ticker.objects.create(symbol=settings.INDEX_TICKER)
        response = self.client.get(reverse('tickers:get_recommendations'))
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
        response = self.client.get(reverse('tickers:get_recommendations'))
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
        response = self.client.get(reverse('tickers:get_recommendations'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            json.dumps(response.data),
            json.dumps({'success': True,
                        'latest_data_date': quote.date.strftime('%Y-%m-%d'),
                        'sell_hits': [fake_quote_serialize(quote)],
                        'buy_hits': []}))

```

Now we can run the tests with `python manage.py test` again, and the output should look like:

```
root@d100b5105a84:/src/stockpicker# python manage.py test
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
............
----------------------------------------------------------------------
Ran 12 tests in 0.305s

OK
Destroying test database for alias 'default'...
```

### `INSTALLED_APPS` Django setting

We also need to set a Django setting for static files.
Add the following to `stockpicker/stockpicker/settings.py`:

```python
STATIC_ROOT = "/src/_static"
```

We will need to be sure that the `stockpicker` app itself has been added to `INSTALLED_APPS` in settings, so that the `staticfiles` app will find our static files.
So if needed, edit `stockpicker/stockpicker.settings.py` so that the `INSTALLED_APPS` setting matches:

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework',

    'stockpicker',
    'tickers',
]
```

### Front-end files

For our main app page we will need an HTML [Django Template](https://docs.djangoproject.com/en/2.2/topics/templates/).
So create `stockpicker/tickers/templates/tickers/picker.html` with the contents:

```html
{% load static %}
<!DOCTYPE html>
<html>
  <head>
    <title>{% block page_title %}Stock-Picker{% endblock %}</title>

    <link rel="shortcut icon" type="image/png" href="{% static 'favicon.ico' %}"/>

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">

    <link rel="stylesheet" type="text/css" href="{% static 'css/app.css' %}">

    <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
  </head>
  <body>

    <div class="jumbotron">
      <div class="container">
          <h2>Toy Stock-Picker</h2>
          <p>
              This app uses an 86-week moving average of scaled daily price (adjusted closing price divided by SPY index value), as a decision boundary for <em>buy</em> versus <em>sell</em> classifications.</h4>
          </p>
          <div id="error_message" style="display:none;" class="alert alert-danger">add ticker error</div>
          <div id="success_message" style="display:none;" class="alert alert-success">add ticker success</div>
      </div>
    </div>

    <div class='container'>

    <div class="row">
      <div class="col-xs-2">
          <form id="add_ticker_form">
            <input type="text" style="width:80%" class="form-control" id="add_ticker_text" placeholder="TICKER">
            <button type="submit" id="add_ticker_btn" style="width:80%" class="btn btn-default">
              Add Ticker
            </button>
          </form>
          <h4 style="margin-bottom: 5px;">Tickers Loaded</h4>
          <ul id="tickerlist"></ul>
      </div>
      <div class="col-xs-10">
          <h3 style="margin-top: 0;">Latest data date: <span id="latest_date"></span></h3>
          <div class="chart-cont">
            <div id="chart1stats" class="stats pull-right">*</div>
            <div id='chart1' class="chart"></div>
            <div class='marker' style="display:none;"></div>
            <div style="clear:both;"></div>
          </div>
          <button class="unzoom btn btn-default">
            Reset Zoom
          </button>
          <div class="chart-cont">
            <div id="chart2stats" class="stats pull-right">*</div>
            <div id='chart2' class="chart"></div>
            <div class='marker' style="display:none;"></div>
            <div style="clear:both;"></div>
          </div>
          <hr>
          <div>Filter: <span id="filter_rec"></span></div>
        <div class="row">
          <div class="col-xs-5">
            <h3>Buy (<span id="buy_count"></span>)</h3>
            <table class="table">
              <thead>
                <tr>
                  <th>sym (gf)</th>
                  <th>ac</th>
                  <th>sac</th>
                  <th>sacma</th>
                  <th>ratio</th>
                </tr>
              </thead>
            </table>
          </div>
          <div class="col-xs-5">
            <h3>Sell (<span id="sell_count"></span>)</h3>
            <table class="table">
              <thead>
                <tr>
                  <th>sym (gf)</th>
                  <th>ac</th>
                  <th>sac</th>
                  <th>sacma</th>
                  <th>ratio</th>
                </tr>
              </thead>
            </table>
          </div>
        </div>
        <div class="row" style="height: 500px; overflow:auto;">
          <div class="col-xs-5">
            <table class="table">
              <tbody id="buy_table"></tbody>
            </table>
          </div>
          <div class="col-xs-5">
            <table class="table">
              <tbody id="sell_table"></tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    </div>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

    <script type="text/javascript" src="{% static 'js/lib/jquery.flot.min.js' %}"></script>
    <script type="text/javascript" src="{% static 'js/lib/jquery.flot.selection.js' %}"></script>
    <script type="text/javascript" src="{% static 'js/picker.js' %}"></script>

  </body>
</html>
```

We also need some static files for the front-end, and now we're going to cheat a little bit, and just copy some code files over from the existing `devops-toolkit` source.
Feel free to explore these files as you like (try not to judge my JavaScript; I know there are better ways, I just haven't gotten that far yet), but I'm not going to reproduce them here.

From your host OS, in the `devops-toolkit` directory, run (the equivalent of):

```bash
cp -R django/stockpicker/stockpicker/static/ source/django/stockpicker/stockpicker/static/
```

You should now see a file structure that looks like:

```
stockpicker/
    stockpicker/
        static/
            css/
                app.css
            js/
                lib/
                    jquery.flot.min.js
                    jquery.flot.selection.js
                picker.js
            favicon.ico
    tickers/
    ...
```

### Port-forwarding from the development environment

Now we are ready to run the [Django development server](https://docs.djangoproject.com/en/2.2/intro/tutorial01/#the-development-server), but since we are running in a Docker container we will not be able to access the running application from the host OS.

To get around this, we need to modify our development environment command to forward the appropriate port.
We can do this with:

```bash
docker run -it \
  -p 8000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/source/django:/src \
  --name local_dev \
  --rm \
  devops \
  /bin/bash
```

But now, since we recycled our dev environment, we have to install our `pip` requirements again, so run:

```bash
pip install -r requirements.txt
```

Now run the [`collectstatic` management command](https://stackoverflow.com/questions/34586114/whats-the-point-of-djangos-collectstatic):

```bash
python manage.py collectstatic
```

You should see:

```
root@ce3ebad4094b:/src/stockpicker# python manage.py collectstatic

119 static files copied to '/src/_static'.
```


Now, we can finally run our development server, with:

```bash
cd /src/stockpicker
python manage.py runserver 0.0.0.0:8000
```

Now you should be able to go to `localhost:8000` in your favorite browser from your host OS, and see the same thing that you see live at [stockpicker.sloanahrens.com](https://stockpicker.sloanahrens.com).

You can stop the development server with `ctl-c`.