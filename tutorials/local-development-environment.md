# Local Docker Development Environment

The Docker image defined in the [`devops` Dockerfile](https://github.com/sloanahrens/devops-toolkit/blob/master/docker/devops/Dockerfile) is used as the base image for CircleCI jobs for this project, and can also be used for local development.

The image can also be pulled from [DockerHub](https://cloud.docker.com/u/sloanahrens/repository/docker/sloanahrens/devops-toolkit-ci-dev-env), if you wish.

In what follows we will build and tag the image locally.

### Install Docker

If you do not have Docker installed on your system, vist the [download page]() and choose the appropriate installer.

You can check that Docker is working by running:

```bash
docker ps
```

It probably won't show you anything, because we haven't started any processes yet, but you should see this at least:

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### Set up `git` and GitHub

If you do not already have `git` installed on your system, you will need to install it. 
We're going to use a running docker container as our development environment, with code in a docker volume acting as a sort of "shared folder", which is a directory shared by the host and the guest VM. 
This accomplishes a couple of things. 
One, it makes it a lot easier to use a text editor of your choice from your host OS.
Two, it means that if we build a bunch of code inside the dev environment and then delete the docker container, we haven't lost our work.

You will also need a [GitHub](https://github.com) account set up, with a working SSH key if you want to use one (setup instructions can be found [here](https://help.github.com/en/articles/set-up-git)). 
I prefer authenticating with an SSH key but it doesn't matter that much. 

Once you have `git` installed, you will need to get it [configured with your name and email](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup).

### Clone `devops-toolkit` repository

With `git` installed and configured, and your Github account set up, you can run:

```bash
git clone git@github.com:sloanahrens/devops-toolkit.git  # SSH
```

or

```bash
git clone https://github.com/sloanahrens/devops-toolkit.git  # HTTP auth
```

and then

`cd devops-toolkit`


### Development Environment

First we need to build and tag the `devops` image, with:

```bash
docker build -t devops -f docker/devops/Dockerfile .
```

Then we can run it with:

```bash
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src --rm --name local_dev devops /bin/bash
```

Here is an annotated version of that last command:

```bash
# if needed replace $PWD with full path to local devops-toolkit folder
docker run -it \  # using -it creates an interactive session
  -v /var/run/docker.sock:/var/run/docker.sock \  # use host's docker engine inside container
  -v $PWD:/src \  # share local directory on host and container
  --rm \  # remove the container when finished (upon exit)
  --name local_dev \  # name the container for ease of use 
  devops \  # devops image should be built and tagged
  /bin/bash  # start a bash terminal
```

Once you run the command, you should see a prompt like (the ID will be different):

```
root@13e70f76d2b8:/src#
```

Type `docker ps` and hit enter and you should see something like:

```
root@13e70f76d2b8:/src# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
13e70f76d2b8        devops              "/bin/bash"         52 seconds ago      Up 51 seconds                           local_dev
```

Which is to say, you should see the container inside of which we are running, from the container itself! 

Type `ls` and you should see the contents of the `devops-toolkit` `git` repo:

```
root@ae87cc98313a:/src# ls
README.md  ci_scripts  container_environments  django  docker  kubernetes  tutorials
```

To start a second session (in another terminal tab or screen, perhaps) into the already-running container, you can run:

```bash
docker exec -it local_dev /bin/bash
```

To exit the environment, just type `exit`.