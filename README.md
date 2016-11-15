# Introduction

The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.

# Quick start
Run the Jenkins image

`docker run --name='jenkins' -it --rm -p 8080:8080 -p 50000:50000 fjudith/jenkins`

# Build details

This image implements few customization to impove Jenkins performance and logging.

```
FROM jenkins:2.19.2

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

USER root

RUN mkdir -p /var/log/jenkins && \
	RUN chown -R  jenkins:jenkins /var/log/jenkins

ENV JAVA_OPTS="-Xmx8192m"
ENV JENKINS_OPTS="--handlerCountStartup=100 --handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log"


USER jenkins

VOLUME /var/jenkins_home
VOLUME /var/log/jenkins
```

# Docker-Compose
In production environment, it recommended to pair Jenkins with a Nginx fronted webserver.

```
jenkins-nginx:
  image: fjudith/jenkins-nginx
  ports:
  - 80:80/tcp
  links:
  - jenkins:jenkins-master
  volumes:
  - jenkins-nginx-config:/etc/nginx
  - jenkins-nginx-log:/var/log/nginx

jenkins:
  image: fjudith/jenkins
  ports:
  - 8080:8080/tcp
  - 50000:50000/tcp
  volumes:
  - jenkins-data:/var/jenkins_home
  - jenkins-log:/var/log/jenkins
```

# Reference

* http://engineering.riotgames.com/news/putting-jenkins-docker-container