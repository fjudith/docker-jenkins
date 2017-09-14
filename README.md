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
version: '2'
services:
  jenkins:
    image: fjudith/jenkins
    ports:
    - 32731:8080/tcp
    - 32732:50000/tcp
    volumes:
    - jenkins-data:/var/jenkins_home
    - jenkins-log:/var/log/jenkins

  jenkins-nginx:
    image: fjudith/jenkins:nginx
    ports:
    - 32733:80/tcp
    links:
    - jenkins:jenkins-master
    volumes:
    - jenkins-nginx-log:/var/log/nginx
```

# Reference

* http://engineering.riotgames.com/news/putting-jenkins-docker-container