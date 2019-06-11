# A Toy Stock-Picker Application, Built with Django and Celery

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

There are also plenty of DevOps dependencies we will need. The very first one is Vagrant.

### Vagrant and VirtualBox

We will use a development environment I have set up for this project. To follow along, you will need to install [Vagrant](https://www.vagrantup.com/). Vagrant makes it easy to spin up a local virtual machine.
Vagrant requires a provider, and for most situations [VirtualBox](https://www.virtualbox.org/) is the best.

Both Vagrant and VirtualBox will need to be installed to use the development environment. Installation varies by OS; here are some [instructions for Mac OSX](https://www.slashroot.in/how-install-vagrant-mac-os-x-step-step-procedure) (it's a bit dated but should still work).

While installing Vagrant and VirtualBox is perhaps a slight annoyance, it's far simpler than installing all the various _other_ dependencies we will need. Using the development environment will mean everyone is "on the same page": literally on the same OS (Ubuntu) with the same versions of dependencies installed, and so on. Always trim the entropy tree whenever you can.

