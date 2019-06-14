# A Toy Stock-Picker Application, Built with Django and Celery

#### Intro
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

There are also plenty of DevOps dependencies we will need. 
The very first one is Vagrant.

#### Set up `git`, clone repo

If you do not already have `git` installed on your system, you will need to install it. 
We're going to use the Vagrant VM as our development environment, with code in a "shared folder", which is a directory shared by the host and the guest VM. This accomplishes a couple of things. 
One, it makes it a lot easier to use a text editor of your choice from your host OS.
Two, it means that if we build a bunch of code inside the VM and then delete the VM, we haven't lost our work.

You will also need a [GitHub](https://github.com) account set up, with a working SSH key if you want to use one (setup instructions can be found [here](https://help.github.com/en/articles/set-up-git)). 
I prefer authenticating with an SSH key but it doesn't matter that much. 

Once you have `git` installed and [configured with your name and email](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup), pick a place you want to use as a work directory, and run:

```bash
git clone git@github.com:sloanahrens/devops-toolkit.git  # SSH
```

or

```bash
git clone https://github.com/sloanahrens/devops-toolkit.git  # HTTP auth
```

#### Install Docker

If you are not familiar with [Docker](https://www.docker.com/) yet, do not fear. 
We are going to using it enough that I think you will begin to get a feel for what it really is.

If you do not have Docker installed on your system, vist the [download page]() and choose the appropriate installer.

You can check that Docker is working by running:

```bash
docker ps
```

It probably won't show you anything, because we haven't started any processes yet, but you should see this at least:

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

#### Install Docker-Compose

We will use [Docker-Compose](https://docs.docker.com/compose/) for local development.
Doing development work this way meshes well with the systems we will be building.
It will also minimize the dependencies that have to be installed on your local system in order to use the `devops-toolkit` repository.

You can find a Docker-Compose installer for your system [here](https://docs.docker.com/compose/install/). 
You can verify the installation worked by running:

```
docker-compose --help
```

#### Create development environment

We're going to re-create part of the `devops-toolkit` code-base in this exercise.
To bootstrap the development environment we are going to use, we'll need to create a few files.

From inside the `devops-toolkit` directory where you cloned the repository, created a new folder called `source` with the following structure:

```
source/
    container_environments/
    docker/
        scripts/
        baseimage/
    django/
```

Now create the following six files:

`source/docker/scripts/wait-for-it.sh` with the contents from [https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh](https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh).

`source/docker/scripts/initialize-webapp-dev.sh`:

```bash
#!/bin/bash
set -e

echo "------------------"

echo "Waiting for postgres..."
wait-for-it.sh -t 60 $POSTGRES_HOST:$POSTGRES_PORT

echo "Run Infinite Loop..."
while true; do
    sleep 60
    echo "tick"
done
```

`source/docker/baseimage/Dockerfile`:

```dockerfile
FROM python:3.6-stretch

ENV PYTHONUNBUFFERED 1

WORKDIR /src

RUN apt-get update && apt-get install -y postgresql

COPY ./docker/scripts/wait-for-it.sh /usr/bin/wait-for-it.sh
RUN chmod 755 /usr/bin/wait-for-it.sh

COPY ./django/requirements.txt /src/requirements.txt

RUN pip --no-cache-dir install --progress-bar pretty -r requirements.txt
```

`source/docker/docker-compose-local-dev-django.yaml`:

```yaml
version: '3.4'

services:

  django:
    container_name: local_dev_django
    image: baseimage
    env_file:
     - ../container_environments/test-stack.yaml
    working_dir: /src
    volumes:
      - ../:/src
    ports:
      - "8000:8000"
    links:
      - postgres
    command: bash -c "./docker/scripts/initialize-webapp-dev.sh"

  postgres:
    image: postgres:9.4
    container_name: local_dev_postgres
    env_file:
     - ../container_environments/test-stack.yaml
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
    external: false

```

`source/container_environments/test-stack.yaml`:

```yaml
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USER=test_user
POSTGRES_PASSWORD=domicile-comanche-audible-bighorn
POSTGRES_DB=db
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_DEFAULT_USER=test_user
RABBITMQ_DEFAULT_PASS=rabbit_password
RABBITMQ_DEFAULT_VHOST=test_vhost
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_NAMESPACE=0
SUPERUSER_PASSWORD=column-hand-pith-baby
SUPERUSER_EMAIL=admin@nowhere.com
APP_DEBUG=True
```

`source/django/requirements.txt`: just an empty text file.

These files all mirror files in the `devops-toolkit` repo, so you can just copy them directly in some way if you like.

With these six files in place, from the `source` directory, you should be able to fire up the development environment with

```bash
docker build -f docker/baseimage/Dockerfile .
docker-compose -f docker/docker-compose-local-dev-django.yaml up
```

This will run the docker containers in attached mode, so you can see the log output.
You can stop the containers by hitting `ctl-c`, and remove them by running:

```bash
docker-compose -f docker/docker-compose-local-dev-django.yaml down
```

If you see this in your output:

```
local_dev_django | bash: ./docker/scripts/initialize-webapp-dev.sh: Permission denied
```

then you will need to give the file the right permissions, with:

```bash
chmod 744 docker/scripts/initialize-webapp-dev.sh
```

If all is well, you will see this at the bottom of the output:

```
local_dev_django | Run Infinite Loop...
```

#### Create a Django project

So we are going to be writing code on the host OS (which means you can use most any text editor you want), but executing the code from within a Docker container.

Thanks the the infinite loop in the initialize script, our container will continue to run until we stop it. 
We are going to "SSH" into the running docker container.
Open a new terminal tab (leaving our docker-compose command running in the first one), and type:

```bash
docker ps
```

and you should see (your container ids will be different):

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
9b2aa7689a3c        baseimage           "bash -c ./docker/..."   19 seconds ago      Up 18 seconds       0.0.0.0:8000->8000/tcp   local_dev_django
e76441c68a89        postgres:9.4        "docker-entrypoint..."   20 seconds ago      Up 19 seconds       5432/tcp                 local_dev_postgres
```

We can open a terminal session into the running `baseimage` container with:

```bash
docker exec -it local_dev_django /bin/bash
```

Now we are running inside the container, and you should see a prompt similar to:

```
root@1c80236a5992:/src#
```

Running `ls` will show the directories we just created earlier:

```
root@1c80236a5992:/src# ls
container_environments	django	docker
```

We want to be working in the `django` directory, so:

```bash
cd django
```

Now we are finally going to start building a Django application.
First we need to install the Django libary with [`pip`](https://www.w3schools.com/python/python_pip.asp):

```bash
pip install Django==2.2.2
```

(We could use `pip install django` and it would work, but I want to match the version currently used in the current code repository, so I'm giving `pip` that specific version.)

The purpose of `requirements.txt` is to record our specific python dependencies. 
So along the way, as we add new ones, we will export them to the file with:

```bash
pip freeze > /src/django/requirements.txt
```

Now that Django is installed, we can create a [new Django project](https://docs.djangoproject.com/en/2.2/intro/tutorial01/#creating-a-project).
From the root directory of the VM (at the same level as `devops-toolkit/`), run:

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

We need to add our database settings in `stockpicker/stockpicker/settings.py`:

```python
import os
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': os.getenv('POSTGRES_DB', 'local_db'),
        'USER': os.getenv('POSTGRES_USER', 'local_user'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'postgres-password'),
        'HOST': os.getenv('POSTGRES_HOST', 'localhost'),
        'PORT': os.getenv('POSTGRES_PORT', 5432),
    }
}
```

To use PostgreSQL we will also need the `psycopg2` `pip` package, so run:

```bash
pip install psycopg2==2.8.2
```

#### Build and test models

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

Now we need to create our first [Django database migration](https://docs.djangoproject.com/en/2.2/topics/migrations/) with:

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


#### Stock quote utility function

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
pip freeze > /src/django/requirements.txt
```

#### Load data with Django management commands

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

This will take a few minutes to run. You should see this once it's done:

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

#### Building API views, with tests