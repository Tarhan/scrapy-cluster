#!/bin/bash

set -e

# Build Dockerfiles for Scrapy Cluster
sudo docker build --rm=true --file docker/kafka-monitor/Dockerfile --tag=istresearch/scrapy-cluster:kafka-monitor-test .
sudo docker build --rm=true --file docker/redis-monitor/Dockerfile --tag=istresearch/scrapy-cluster:redis-monitor-test .
sudo docker build --rm=true --file docker/crawler/Dockerfile --tag=istresearch/scrapy-cluster:crawler-test .

# run docker compose up for docker tests
sudo docker-compose -f travis/docker-compose.test.yml up -d

# cat kafka logs to check things are working
sudo docker-compose ps
sudo docker-compose logs kafka_monitor
sudo docker-compose logs kafka


# run docker unit and integration tests for each component
sudo docker exec -it travis_kafka_monitor_1 env TERM=xterm /bin/bash -c "./run_docker_tests.sh"
sudo docker exec -it travis_redis_monitor_1 env TERM=xterm /bin/bash -c "./run_docker_tests.sh"
sudo docker exec -it travis_crawler_1 env TERM=xterm /bin/bash -c "./run_docker_tests.sh"

# spin down compose
sudo docker-compose -f travis/docker-compose.test.yml down
