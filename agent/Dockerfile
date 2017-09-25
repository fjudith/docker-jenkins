FROM jenkins/jnlp-slave

LABEL maintainer="Florian JUDITH <florian.judith.b@gmail.com>"

USER root
RUN apt-get update -yqq && apt-get install -yqq \
    maven \
    ruby \
    ant \
    gradle \
    make \
    xmlstarlet \
    crudini \
    git

USER jenkins



