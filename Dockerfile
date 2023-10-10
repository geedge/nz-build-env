FROM centos:7

###############################################
## install jdk
###############################################
ARG JAVA_FILE=openjdk-21_linux-x64_bin.tar.gz

COPY ./depends/${JAVA_FILE} /tmp/openjdk-21_linux-x64_bin.tar.gz

RUN mkdir -p /usr/local/java
RUN tar -zxf /tmp/openjdk-21_linux-x64_bin.tar.gz --strip-components 1 -C /usr/local/java
ENV JAVA_HOME /usr/local/java
ENV PATH $PATH:$JAVA_HOME/bin

RUN rm -f /tmp/openjdk-21_linux-x64_bin.tar.gz;
RUN java -version

###############################################
## install maven
###############################################
ARG MAVEN_FILE=apache-maven-3.8.5-bin.tar.gz

COPY ./depends/${MAVEN_FILE} /tmp/apache-maven.tar.gz
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
# COPY ./depends/maven-setting.xml /usr/share/maven/conf/settings.xml
RUN rm -rf /tmp/apache-maven.tar.gz
ENV MAVEN_HOME /usr/share/maven
RUN mvn -v

###############################################
## install node
###############################################
COPY ./depends/node-v14.18.2-linux-x64.tar.gz /tmp/node.tar.gz
RUN mkdir -p /usr/bin/node
RUN tar -zxf /tmp/node.tar.gz --strip-components 1 -C /usr/bin/node

ENV PATH "/usr/bin/node/bin:${PATH}"
RUN npm install -g cnpm --registry=https://registry.npmmirror.com
RUN rm -rf /tmp/node.tar.gz

RUN node -v
RUN npm -v
RUN cnpm -v

###############################################
## install fpm
###############################################

ENV FPM_VERSION 1.14.0
RUN yum install -y centos-release-scl

RUN yum install -y rh-ruby26 rh-ruby26-rubygems rh-ruby26-ruby-devel gcc make rpm-build
RUN echo '/opt/rh/rh-ruby26/root/usr/lib64' > /etc/ld.so.conf.d/rh-ruby.conf
RUN ldconfig
RUN ln -s /opt/rh/rh-ruby26/root/bin/ruby /usr/bin/ruby \
  && ln -s /opt/rh/rh-ruby26/root/bin/gem /usr/bin/gem

RUN ruby -v

RUN gem sources --add http://mirrors.aliyun.com/rubygems/ \
  && gem sources --remove https://rubygems.org/ \
  && gem install fpm -v ${FPM_VERSION} \
  && ln -s /opt/rh/rh-ruby26/root/usr/local/bin/fpm /usr/bin/fpm

RUN fpm -v

###############################################
## install git
###############################################

RUN yum install -y git
RUN git --version

###############################################
## install go
###############################################

RUN yum install -y epel-release
RUN yum clean all && rm -rf /var/cache/yum/*
RUN yum install -y go
RUN go version

###############################################
## install minio client
###############################################
COPY ./depends/mc /usr/bin/
RUN chmod +x /usr/bin/mc

###############################################
## install mysql client
###############################################
COPY ./depends/mariadb /usr/bin/mysql
COPY ./depends/mariadb-dump /usr/bin/mysqldump
RUN chmod +x /usr/bin/mysql /usr/bin/mysqldump

COPY ./depends/maven-setting.xml /usr/share/maven/conf/settings.xml

RUN yum -y clean all && rm -rf /var/cache/yum/*
