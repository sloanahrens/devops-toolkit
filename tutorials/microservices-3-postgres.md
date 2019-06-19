# A Toy Stock-Picker Application, Part 3: PostgreSQL

### Development environment

Make sure you have the [development environment](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/local-development-environment.md) up and running, and run:

```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/src \
  --name local_dev \
  --rm \
  devops \
  /bin/bash
```

Once you run the command, you should see a prompt like (the ID will be different):

```
root@13e70f76d2b8:/src#
```

### `pip` install
To use PostgreSQL we will need to install the `psycopg2` `pip` package (and update the requirements file).
So, from inside the development environment docker container, run:

```bash
pip install psycopg2==2.8.2
pip freeze > /src/django/requirements.txt
```

### Django database setting

We also need to add our database settings to `stockpicker/stockpicker/settings.py`:

```python
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

