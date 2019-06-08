# devops-toolkit
A basic but fully-functional DevOps system foundation. 

Very opinionated. Season to taste.

# Requirements:
- All the dependencies defined in the included `devops` [Dockerfile](https://github.com/sloanahrens/devops-toolkit/blob/master/docker/devops/Dockerfile)
- Or simply use the public image of that Dockerfile, available on [DockerHub](https://cloud.docker.com/u/sloanahrens/repository/docker/sloanahrens/devops-toolkit-ci-dev-env)
- A CircleCI account hooked up to your code repo.
- A valid AWS account, with keys for a CLI IAM user with at least the following permissions:
  - AmazonEC2FullAccess
  - IAMFullAccess
  - AmazonEC2ContainerRegistryFullAccess
  - AmazonS3FullAccess
  - AmazonDynamoDBFullAccess
  - AmazonVPCFullAccess
  - AmazonElasticFileSystemFullAccess 
  - AmazonRoute53FullAccess

# Components:
**Cloud:** All infrastructure in AWS. Supply your own AWS keys to use the repo. 

**Orchestration:** Kubernetes cluster in AWS, managed with Kops and Terraform.

**Continuous Integration:** A full CI/CD pipeline implemented with CircleCI, hooked to AWS. Uses a custom CI image, defined in this repo as well.

**Application Microservices:** A Django web application with Celery asynchronous task-processing, backed by PostgreSQL, Redis and RabbitMQ.

**Unit Tests:** Decent unit test coverage of the Django app. Could use more tests.

**Integration Tests:** Simple Bash-based scripted endpoint testing that works in various environments, including Docker-Compose and Kubernetes. Could use more of these tests, too.

**Containerization:** Dockerfiles for containerizing the application stack, built in CI and pushed to AWS ECR repository. 

**Docker-Compose Files:** Run local Docker stacks for local testing of the application Docker images.

**Kubernetes Application Specs:** Spec templates for deploying namespaced app-stacks to Kubernetes with only `kubectl`.

**Kubernetes Dependencies:** Specs for deploying cluster-level microservices that provide services to app stacks.

**Cluster Updates in CI:** Minimal cluster self-healing via CI. More work to do here, once I figure out how.

**Cluster-Building Instructions:** Step-by-step instructions for building a K8s cluster from the command-line.

**Continuous Deployment:** Successful execution of CI pipeline on `master` branch deploys current app images to Kubernetes, namespaced on the "production stack", accessible (when all is well) at [stockpicker.sloanahrens.com](https://stockpicker.sloanahrens.com).

**Cluster/App Monitoring:** Coming Soon.

**Centralized Logging:** Coming Soon.

