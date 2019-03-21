[![](https://images.microbadger.com/badges/image/fjudith/jenkins.svg)](https://microbadger.com/images/fjudith/jenkins "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/fjudith/docker-jenkins.svg?branch=master)](https://travis-ci.org/fjudith/docker-jenkins)

# Introduction

The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.

# Quick start
Run the Jenkins image

`docker run --name='jenkins' -it --rm -p 8080:8080 -p 50000:50000 fjudith/jenkins`

# Docker-Compose
In production environment, it recommended to pair Jenkins with a Nginx fronted webserver.

```yaml
version: '3'
volumes:
  jenkins-data:
networks:
  traefik_proxy:
    external:
      name: traefik_proxy
  jenkins:
    driver: bridge
services:
  jenkins:
    image: fjudith/jenkins:latest
    container_name: jenkins
    networks:
      - jenkins
    ports:
      - 8080/tcp
      - 50000/tcp
    environment:
      JAVA_OPTS: "-Xmx512m"
    volumes:
    - jenkins-data:/var/jenkins_home
  nginx:
    image: fjudith/jenkins:nginx
    container_name: nginx
    depends_on:
      - jenkins
    networks:
      - jenkins
      - traefik_proxy
    ports:
      - 80/tcp
```

# Reference

* http://engineering.riotgames.com/news/putting-jenkins-docker-container