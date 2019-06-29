# Part 4: Automate App Builds with CircleCI

In this exercise we will take what we've built so far and automate it into a continuous-integration pipeline.
The deliverables of this pipeline will be our application docker images, automatically pushed to a private Docker repository under our control.
We will need to set up some configuration to hook all the pieces together and get the pipeline working.
In later exercises we will build out more CI modules.

### Sign up for stuff

A consequence of doing a concrete, step-by-step tutorial is that some concrete decisions have to be made about service providers.

I'm going to ask you to sign up for accounts with [GitHub](https://github.com/), [CircleCI](https://circleci.com/), and [Amazon Web Services](https://aws.amazon.com/).

There are--as is often the case in DevOps--suitable alternatives to all these choices.
You could use [Bitbucket](https://bitbucket.org/product/) instead of GitHub.
You could use [Jenkins](https://jenkins.io/) instead of CircleCI, either [hosted](https://duckduckgo.com/?q=hosted+jenkins) or self-maintained, or any of countless other [CI tools](https://duckduckgo.com/?q=top+continuous+integration+tools).
You could use [Azure](https://azure.microsoft.com/en-us/) or [Rackspace](https://www.rackspace.com/) instead of AWS.
It would be a worthy exercise to pick some different providers and rebuild portions of this tutorial with those instead of my choices.

Building anything real requires making some concrete choices.
I made the choices that I believe are the most sensible defaults.
But it means that to follow along you will have to commit to signing up for a few things.
 
### Warning: AWS costs $$$

Be careful with your AWS usage.
I'll bring this point up again, but Amazon will happily bill you for all your cloud infrastructure use, so pay attention to it.

I won't ask you to anything that will cost more than a few dollars a month, if that--at least until we get around to deploying [Kubernetes](https://kubernetes.io/).

### Complete Parts 1-3

Make sure you've completed the first three parts of the tutorial.

I'll assume that you still have all the files in place from the previous three exercises, contained in your `source` directory at the top level of your local clone of the `devops-toolkit` [repostitory](https://github.com/sloanahrens/devops-toolkit).

Your `source` directory should have at least:

```
devops-toolkit/
    ...
    source/
        container_environments/
            test-stack.yaml
        django/
            stockpicker/
            requirements.txt
        docker/
            baseimage/
                Dockerfile
            scripts/ 
                initialize-webapp-dev.sh
                wait-for-it.sh
            docker-compose-local-dev-django.html
            docker-compose-local-dev-django-celery.html
            docker-compose-local-dev-django.html-celery-beat.html
    ...
```

### `devops` Development Environment

In this exercise we'll use the `devops` development environment (rather than the `baseimage` dev env from Parts 2 and 3), so make sure you can run it as described [here](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/0-local-dev-env-devops.md).

Make sure you have built the `devops` Docker image, by running the following command from your `devops-toolkit` directory:

```bash
docker build -t devops -f docker/devops/Dockerfile .
```

Go to your `source` directory now, and and start the development environment Docker container with:

```bash
docker run -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:/src \
    --rm \
    --name \
    local_devops \
    devops \
    /bin/bash
```

Run `ls` from inside the container and should see the files you created in the `source` directory:

```
root@1bc94b877039:/src# ls
container_environments	django	docker
```

### `webapp` and `celery` images

Thus far we've been able to do what we needed with just our `baseimage`, attached to the code-base via a Docker volume.
Now we're going to need to take our new DevOps setup a bit further.
The first thing we'll do is implement our production images.
The `webapp` and `celery` images will ultimately be pushed to a private image repository, and used to (continuously-)deploy our production stack to Kubernetes.
But I'm getting ahead of myself.

Create the following three files:

1) `docker/celery/Dockerfile`:

```dockerfile
FROM baseimage

ENV C_FORCE_ROOT true

WORKDIR /src

COPY ./django/stockpicker/stockpicker /src/stockpicker
COPY ./django/stockpicker/tickers /src/tickers
COPY ./django/stockpicker/manage.py /src/manage.py
```

The `celery` image will be used for both Celery workers, and the Celery Beat scheduler.
This image inherits from `baseimage`, sets the `C_FORCE_ROOT` environment variable (needed by Celery when running in a container), sets the working directory to `/src`, and copies into the container all the Django files needed to run the application.

2) `docker/webapp/Dockerfile`:

```dockerfile
FROM baseimage

EXPOSE 8001

WORKDIR /src

COPY ./django/stockpicker/stockpicker /src/stockpicker
COPY ./django/stockpicker/tickers /src/tickers
COPY ./django/stockpicker/manage.py /src/manage.py

COPY ./docker/scripts/initialize-webapp-prod.sh /src/entrypoint.sh
RUN chmod 755 /src/entrypoint.sh
ENTRYPOINT ["/src/entrypoint.sh"]
```

The `webapp` image will be used to run the Django web application.
This image is similar to the `celery` image, but also exposes port `8001` (where the web app will be listening for requests), and uses an `ENTRYPOINT` to run the application via a Bash script.
The entrypoint script is copied into the image, given proper executable permissions, then defined as the application entrypoint.

3) `docker/scripts/initialize-webapp-prod.sh`:

```bash
#!/bin/bash
set -e

echo "------------------"

echo "Waiting for dependencies..."
wait-for-it.sh -t 60 $REDIS_HOST:$REDIS_PORT
wait-for-it.sh -t 60 $RABBITMQ_HOST:$RABBITMQ_PORT
wait-for-it.sh -t 180 $POSTGRES_HOST:$POSTGRES_PORT

echo "Sleeping for 10 seconds..."
sleep 10

echo "Migrating databases..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Create default Tickers..."
python manage.py load_tickers

echo "Start Quotes Update Task..."
echo "from tickers.tasks import chained_ticker_updates; chained_ticker_updates.delay()" | python manage.py shell

echo "Start uWSGI..."
uwsgi --module stockpicker.wsgi:application --http 0.0.0.0:8001 --static-map /static=/srv/_static
```

This Bash script will serve as the entrypoint for the web application Docker image.
The script first uses `wait-for-it.sh` to wait for service dependencies to be initialized and ready, then waits ten seconds.
Next the script initializes the app by running database migrations, collecting static files, and loading the default `Ticker`s via the Django management command we defined in [Part 1](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/1-1-microservices-django.md).
The script then queues up the `chained_ticker_updates` Celery task, so that `Quote`s will get updated as soon as a Celery worker is available.
The final step is to start the [uWSGI server](https://uwsgi-docs.readthedocs.io/en/latest/), which we will use as our application server.
The `uwsgi` command runs the application at `0.0.0.0:8001` (accessible at `localhost:8001` from the host OS), and uses the `--static-map` flag to serve our static assets (an improvement would be to use [nginx](https://www.nginx.com/) instead, but it adds some comlexity).

### Install `uWSGI`

Next we need to update `requirements.txt` again, to install `uWSGI`.
This can be done a number of ways.
One is to simply edit `django/requirements.txt` to match:

```
amqp==2.4.2
billiard==3.6.0.0
celery==4.3.0
certifi==2019.3.9
chardet==3.0.4
Django==2.2.2
django-redis-cache==2.0.0
djangorestframework==3.9.3
entrypoints==0.3
fix-yahoo-finance==0.1.33
flake8==3.7.7
idna==2.7
kombu==4.5.0
lxml==4.3.3
mccabe==0.6.1
multitasking==0.0.8
numpy==1.16.3
pandas==0.24.2
pandas-datareader==0.7.0
psycopg2==2.8.2
pycodestyle==2.5.0
pyflakes==2.1.1
python-dateutil==2.8.0
pytz==2019.1
redis==3.2.1
requests>=2.20.0
six==1.12.0
sqlparse==0.3.0
urllib3>=1.24.2
uWSGI==2.0.18
vine==1.3.0
wrapt==1.11.1

```

_Note:_ the entry `urllib3>=1.24.2` silences a security complaint from GitHub, and doesn't affect the application, other than producing a warning.

### Unit tests with Docker-Compose

Now that we have all that in place, we can build our production images, and run our unit tests against the `webapp` image.
These steps will be added into CI shortly.

So create:

`docker/docker-compose-unit-test.yaml`:

```yaml
version: '3.4'
services:

  unit-test:
    image: webapp
    container_name: stockpicker_webapp_unit_test
    links:
      - postgres
    depends_on:
      - postgres
    env_file:
     - ../container_environments/test-stack.yaml
    working_dir: /src
    entrypoint: bash -c "wait-for-it.sh postgres:5432 -- python manage.py test"

  postgres:
    image: postgres:9.4
    container_name: stockpicker_postgres
    env_file:
     - ../container_environments/test-stack.yaml
```

Now, from the `devops` development environment, build the `baseimage` image with:

```bash
docker build -t baseimage -f docker/baseimage/Dockerfile .
```

Build the `webapp` image with:

```bash
docker build -t webapp -f docker/webapp/Dockerfile .
```

And build the `celery` image (we don't need it yet but we will later) with:

```bash
docker build -t celery -f docker/celery/Dockerfile .
```

Now we can run the Django unit tests from Part 1 with this Docker-Compose command:

```bash
docker-compose -f docker/docker-compose-unit-test.yaml run unit-test
```

You should see output similar to:

```
root@f2f32c4db846:/src# docker-compose -f docker/docker-compose-unit-test.yaml run unit-test
Creating network "docker_default" with the default driver
Creating stockpicker_postgres ... done
wait-for-it.sh: waiting 15 seconds for postgres:5432
wait-for-it.sh: postgres:5432 is available after 1 seconds
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
............
----------------------------------------------------------------------
Ran 12 tests in 0.194s

OK
Destroying test database for alias 'default'...
```

Now we need to remove the `postgres` container used by the unit tests with:

```bash
docker-compose -f docker/docker-compose-unit-test.yaml down
```

### Local image Docker-Compose stack

We can now run a full local "stack" using our production images.

Create:

`docker/docker-compose-local-image-stack.yaml`:

```yaml
version: '3.4'
services:

  redis:
    image: redis
    container_name: stockpicker_redis
    env_file:
     - ../container_environments/test-stack.yaml

  rabbitmq:
    image: rabbitmq:3.6
    container_name: stockpicker_rabbitmq
    env_file:
     - ../container_environments/test-stack.yaml

  postgres:
    image: postgres:9.4
    container_name: stockpicker_postgres
    env_file:
     - ../container_environments/test-stack.yaml

  webapp:
    image: webapp
    container_name: stockpicker_webapp
    ports:
     - 8080:8001
    links:
      - postgres
      - rabbitmq
      - redis
    depends_on:
      - postgres
      - rabbitmq
      - redis
    env_file:
     - ../container_environments/test-stack.yaml

  worker1:
    image: celery
    container_name: stockpicker_worker1
    links:
      - postgres
      - rabbitmq
      - redis
    depends_on:
      - postgres
      - rabbitmq
      - redis
    env_file:
     - ../container_environments/test-stack.yaml
    command: bash -c "celery worker -O fair -c 1 --app=stockpicker.celery --loglevel=info"

  worker2:
    image: celery
    container_name: stockpicker_worker2
    links:
      - postgres
      - rabbitmq
      - redis
    depends_on:
      - postgres
      - rabbitmq
      - redis
    env_file:
     - ../container_environments/test-stack.yaml
    command: bash -c "celery worker -O fair -c 1 --app=stockpicker.celery --loglevel=info"

  beat:
    image: celery
    container_name: stockpicker_beat
    links:
      - postgres
      - rabbitmq
      - redis
    depends_on:
      - postgres
      - rabbitmq
      - redis
    env_file:
     - ../container_environments/test-stack.yaml
    command: bash -c "sleep 30 && celery beat --app=stockpicker.celery --loglevel=info"
```

This file will create our Redis, RabbitMQ and PostgreSQL dependencies, a single webapp instance, two worker instances, and an instance of the Celery Beat scheduler.
This stack does not use a Docker volume, and so our data will not persist between stack instances.
This is by design, because we will use this file for our integration tests, and we want to test full database initialization.

We can run the local image stack with:

```bash
docker-compose -f docker/docker-compose-local-image-stack.yaml up
```

If you watch the log output you will see the stack initialize, and after a bit you will see the data update tasks (that we originally saw in Part 1) running.

Destroy the stack by hitting `ctl-c` then running:

```bash
docker-compose -f docker/docker-compose-local-image-stack.yaml down
```

### Integration test harness

Now that we can run a full local "production" stack instance, we are ready to run some basic [integration tests](https://en.wikipedia.org/wiki/Integration_testing) against it.
There are many, many ways to do integration testing.
The method I'll present is a very simple one, requiring little more than some [Bash](https://www.gnu.org/software/bash/) skills.

To get started we need to create yet more files.
Create these two files:

1) `docker/stacktest/Dockerfile`:

```dockerfile
FROM yikaus/alpine-bash

WORKDIR /usr/src

RUN apk update && apk upgrade && apk add curl jq

COPY ./docker/stacktest/integration-tests.sh .
RUN chmod 755 /usr/src/integration-tests.sh
```

This Dockerfile starts with the [`yikaus/alpine-bash` image](https://github.com/yikaus/docker-alpine-bash), adds a couple more dependencies, and sets up our integration tests script.

2) `docker/stacktest/integration-tests.sh`:

```bash
#!/bin/bash


function wait_for_and_test_endpoint {
    period=10
    limit=24
    looper=${limit}
    # wait for the app to be all hooked up and working
    url="$1"
    res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Cache-Control: no-cache')
    status=$(echo ${res} | jq '.status' || echo 'nada')
    while [[ "$status" != '"healthy"' ]]; do
        echo "url: $url; res: $res; status: $status"
        if [[ $(($looper+0)) == 0 ]]; then
            echo "URL: \"$url\" Response: \"$res\""
            echo "Timeout waiting for health of \"$url\" after $(($limit * $period)) seconds!"
            exit 1
        fi
        looper=$(($looper-1))
        echo "URL: \"$url\" Response: \"$res\" | Sleeping $period seconds [$(($limit-$looper))/$limit]"
        sleep ${period}
        res=$(curl -XGET -s ${url} -H 'Content-Type: application/json' -H 'Cache-Control: no-cache')
        status=$(echo ${res} | jq '.status' || echo 'nada')
    done
    echo "url: $url; res: $res; status: $status"
    if [[ ${status} == 'nada' || ${status} != '"healthy"' ]]; then
      echo "Test Fail: $url; Expected:'"healthy"'; Actual:$status"
      exit 1
    else
      echo "Test Pass: $1"
    fi
}


echo "SERVICE: $SERVICE"

wait_for_and_test_endpoint "$SERVICE/health/database/"

wait_for_and_test_endpoint "$SERVICE/health/celery/"

wait_for_and_test_endpoint "$SERVICE/health/tickers-loaded/"

```

This script defines a [bash function](https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php) which takes and endpoint argument, waits for the endpoint to become available, then tests for the expected JSON output containing `"status": "healthy"`.
The function is then used to test three health check endpoints.

We have not yet defined these endpoints, so we need to set them up in the application code, and rebuild our images.

### Django app health-checks

We need to edit two of our pre-existing Django files to add the health check urls and views to the application.

Edit `django/stockpicker/stockpicker/views.py` to match:

```python
from django.db.utils import ProgrammingError
from django.utils.timezone import now
from django.conf import settings

from celery.exceptions import TimeoutError

from rest_framework.status import HTTP_412_PRECONDITION_FAILED
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import AllowAny

from tickers.models import Ticker
from stockpicker.tasks import celery_worker_health_check


class AppHealthCheckView(APIView):

    def get(self, request, *args, **kwargs):
        return Response({'status': 'healthy'})


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
            # this will tell k8s the webapp isn't ready yet
            Response(data={'status': 'unhealthy',
                           'reason': 'database query failed (ProgrammingError)',
                           'exception': str(e)},
                     status=HTTP_412_PRECONDITION_FAILED)


class CeleryHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        current_datetime = now().strftime('%c')
        task = celery_worker_health_check.delay(current_datetime)
        try:
            #  Trigger a health check job (run db query from the worker).
            result = task.get(timeout=6)
        except TimeoutError as e:
            return Response(data={
                'status': 'unhealthy',
                'reason': 'celery job failed (TimeoutError)',
                'exception': str(e)},
                status=HTTP_412_PRECONDITION_FAILED)
        try:
            assert result == current_datetime
        except AssertionError as e:
            return Response(data={
                'status': 'unhealthy',
                'reason': 'celery job failed (AssertionError)',
                'exception': str(e)},
                status=HTTP_412_PRECONDITION_FAILED)

        return Response({'status': 'healthy'})


class TickersLoadedHealthCheckView(APIView):
    authentication_classes = (SessionAuthentication,)
    permission_classes = (AllowAny,)

    def get(self, request, *args, **kwargs):
        try:
            assert Ticker.objects.filter(symbol=settings.INDEX_TICKER).exists()
            for ticker in settings.DEFAULT_TICKERS:
                assert Ticker.objects.filter(symbol=ticker).exists()
            return Response({'status': 'healthy', 'ticker_count': Ticker.objects.all().count()})
        except AssertionError as e:
            return Response(data={
                'status': 'unhealthy',
                'reason': 'tickers not loaded (AssertionError)',
                'exception': str(e)},
                status=HTTP_412_PRECONDITION_FAILED)
        except ProgrammingError as e:
            Response(data={'status': 'unhealthy',
                           'reason': 'database query failed (ProgrammingError)',
                           'exception': str(e)},
                     status=HTTP_412_PRECONDITION_FAILED)

```




[Prev: Part 3](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/1-3-microservices-celery.md)
[Next: Part 5]()