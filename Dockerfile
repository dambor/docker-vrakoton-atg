##- FROM ubuntu:14.04
##- MAINTAINER re-enter <admin@re-enter.com>
FROM jboss/base-jdk:7

USER root

RUN if [ ! -d "/opt" ]; then mkdir /opt; fi
RUN if [ ! -d "/tmp" ]; then mkdir /tmp; fi
RUN if [ ! -d "/srv/jboss/config" ]; then mkdir -p /srv/jboss/config; fi

# create jboss folders
RUN mkdir -p /var/log/jboss

# install Oracle JDK: you need to download it manually in the installers directory
##- ADD ./installers/jdk-7u71-linux-x64.tar.gz /opt/
##- ENV JAVA_HOME=/opt/jdk1.7.0_71
##- ENV PATH=${JAVA_HOME}/bin:${PATH}

# install jboss: you need to download JBOSS manually in the installers directory
ADD ./installers/jboss-eap-6.1.0.zip /tmp/
WORKDIR /opt/
##- RUN apt-get install unzip
RUN unzip /tmp/jboss-eap-6.1.0.zip > /dev/null 2>&1

ENV JBOSS_HOME=/opt/jboss-eap-6.1

# create jboss user
##- RUN useradd -s /bin/bash -d ${JBOSS_HOME} jboss && chown -R jboss:jboss ${JBOSS_HOME}

# distribute mysql lib
RUN if [ ! -d "${JBOSS_HOME}/modules/com/mysql/main" ]; then mkdir -p ${JBOSS_HOME}/modules/com/mysql/main; fi
##- ADD ./installers/mysql-connector-java-5.1.15-bin.jar ${JBOSS_HOME}/modules/com/mysql/main/
RUN curl -SL http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.15/mysql-connector-java-5.1.15.jar \
  -o ${JBOSS_HOME}/modules/com/mysql/main/mysql-connector-java-5.1.15-bin.jar
ADD ./config/modules/com/mysql/module.xml ${JBOSS_HOME}/modules/com/mysql/main/

# distrbute jboss standalone configuration
ADD ./config/configuration/standalone.xml ${JBOSS_HOME}/standalone/configuration/
ADD ./config/configuration/mgmt-users.properties ${JBOSS_HOME}/standalone/configuration/

# distribute scripts
RUN if [ ! -d "/opt/scripts" ]; then mkdir /opt/scripts; fi
ADD ./scripts/jboss.sh /opt/scripts/jboss.sh
RUN chmod -R u+x /opt/scripts/*.sh

# the JBOSS deployments folder is a mounted folder
RUN rm ${JBOSS_HOME}/standalone/deployments/*
VOLUME ["${JBOSS_HOME}/standalone/deployments", "/srv/jboss/config", "/var/log/jboss"]

# TODO: USER jboss

EXPOSE 8080 9990 9012

CMD ["/opt/scripts/jboss.sh", "start"]