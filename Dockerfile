FROM jenkins/jenkins:lts

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

# Set default options
# http://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html
ENV JAVA_OPTS="-Xmx8192m"
# http://winstone.sourceforge.net/#commandLine
ENV JENKINS_OPTS="--handlerCountMax=300"
#ENV JENKINS_OPTS="--handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log"

# Enable access log
ENV JENKINS_ACCESSLOG="--accessLoggerClassName=winstone.accesslog.SimpleAccessLogger --simpleAccessLogger.format=combined --simpleAccessLogger.file=/var/log/jenkins/access.log"

# Create Jenkins Log Folder
USER root
RUN mkdir -p /var/log/jenkins
RUN chown -R jenkins:jenkins /var/log/jenkins

USER jenkins

VOLUME /var/jenkins_home
VOLUME /var/log/jenkins