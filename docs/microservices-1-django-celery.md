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

#### Vagrant and VirtualBox

We will use a development environment I have set up for this project. To follow along, you will need to install [Vagrant](https://www.vagrantup.com/). 
Vagrant makes it easy to spin up a local virtual machine.
Vagrant requires a provider, and for most situations [VirtualBox](https://www.virtualbox.org/) is the best.

Both Vagrant and VirtualBox will need to be installed to use the development environment. Installation varies by OS; here are some [instructions for Mac OSX](https://www.slashroot.in/how-install-vagrant-mac-os-x-step-step-procedure) (it's a bit dated but should still work).

While installing Vagrant and VirtualBox is perhaps a slight annoyance, it's far simpler than installing all the various _other_ dependencies we will need. Using the development environment will mean everyone is "on the same page": literally on the same OS (Ubuntu) with the same versions of dependencies installed, and so on. 
Always trim the entropy tree whenever you can.

#### Set up `git`, clone repo, start Vagrant VM

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

Now that you have a local copy of the repository, we want to start up the Vagrant dev-environment with:

```bash
cd devops-toolkit/vagrant
vagrant up
```

The Vagrant box will take some time to finish provisioning. Once it's done, you can open a terminal session into the box with:

```bash
vagrant ssh
```

You should see this prompt:

```bash
ubuntu@ubuntu-xenial:~$
```

Type `ls` and you'll see the contents of the home directory, including `devops-toolkit/`.


#### Create `virtualenv`

Python comes in a lot of different [versions](https://www.python.org/doc/versions/), which can create problems of compatibility, especially when combined with a large set of python library dependencies used by an application. And I quote: 
> [`virtualenv`](https://virtualenv.pypa.io/en/stable/) is a tool to create isolated Python environments.

It's generally a good idea to use `virtualenv`s for local python development (unless you are using [Docker](https://stackoverflow.com/questions/48561981/activate-python-virtualenv-in-dockerfile)), and we will set one up inside our virtual machine. 
While it's arguable that it's a bit redundant, I think the benefits of having it for local development outweigh the benefit of not using it.

From the command prompt inside the Vagrant Ubuntu virtual machine, create a Python 3.6 `virtualenv` with:
```bash
python3.6 -m venv venv
```

Now if you `ls` you will see that a directory `venv` has been created, containing our new virtualenv. We can can activate it with:
```bash
source venv/bin/activate
```
Now your prompt should look like this:
```
(venv) ubuntu@ubuntu-xenial:~$
```

Check the version of Python running in your virtualenv with:

```
(venv) ubuntu@ubuntu-xenial:~$ python --version
Python 3.6.8
```

(Notice that you don't have to use `python3.6`, because we are running in a virtualenv.)


#### Create a Django project

First we need to install the Django libary with [`pip`](https://www.w3schools.com/python/python_pip.asp):

```bash
pip install Django==2.2.2
```

(We could use `pip install django` and it would work, but I want to match the version currently used in the current code repository, so I'm giving `pip` that specific version.)

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
cd stockpicker
python manage.py makemigrations 
```

This will create a file in `stockpicker/tickers/migrations` that will define the database tables we need.
We can create a local database using the default database provider [SQLite](https://sqlite.org/index.html), by simply running:

```bash
python manage.py migrate
```

Now that we have some models, we can test them with some unit tests.
Add the following code to `stockpicker/tickers/tests.py`:

```python

```

Now that we have some unit tests, we can run them with:

```bash
python manage.py test
```

You should see the following output:

```

```

well shit. vagrant screwed me so gotta redo a bunch of this.

gonna do this instead: 
https://www.calazan.com/using-docker-and-docker-compose-for-local-django-development-replacing-virtualenv/