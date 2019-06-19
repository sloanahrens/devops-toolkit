# A Toy Stock-Picker Application, Part 2: Celery

### Complete Part 1

Make sure you have completed [Part 1](https://github.com/sloanahrens/devops-toolkit/blob/master/tutorials/microservices-1.md) of the Microservices Tutorial.

### Development environment

As in Part 1, we'll use the development environment with the local version of the code in the `source` directory:

```bash
mkdir -p source/django
```

```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/source/django:/src \
  --name local_dev \
  --rm \
  devops \
  /bin/bash
```

I'll assume that you have all the files from Part 1 still in place in the `devops-toolkit/source/django` directory.

### Install Celery