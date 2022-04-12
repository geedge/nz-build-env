FROM centos:7

###############################################
## install jdk
###############################################
ARG JAVA_FILE=jdk-8u321-linux-x64.rpm

COPY ./depends/${JAVA_FILE} /tmp/jdk-8-linux-x64.rpm
RUN yum -y install /tmp/jdk-8-linux-x64.rpm
# JDK stripping
RUN rm -f /usr/java/jdk1.8.0_321-amd64/src.zip /usr/java/jdk1.8.0_321-amd64/javafx-src.zip
RUN rm -rf /usr/java/jdk1.8.0_321-amd64/lib/missioncontrol/ /usr/java/jdk1.8.0_321-amd64/lib/visualvm/ /usr/java/jdk1.8.0_321-amd64/db/
RUN alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 1
ENV JAVA_HOME /usr/java/latest
RUN rm -f /tmp/jdk-8-linux-x64.rpm;
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

RUN yum install -y rh-ruby25 rh-ruby25-rubygems rh-ruby25-ruby-devel gcc make rpm-build
RUN echo '/opt/rh/rh-ruby25/root/usr/lib64' > /etc/ld.so.conf.d/rh-ruby.conf
RUN ldconfig
RUN ln -s /opt/rh/rh-ruby25/root/bin/ruby /usr/bin/ruby \
  && ln -s /opt/rh/rh-ruby25/root/bin/gem /usr/bin/gem

RUN ruby -v

RUN gem sources --add http://mirrors.aliyun.com/rubygems/ \
  && gem sources --remove https://rubygems.org/ \
  && gem install fpm -v ${FPM_VERSION} \
  && ln -s /opt/rh/rh-ruby25/root/usr/local/bin/fpm /usr/bin/fpm

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

COPY ./depends/maven-setting.xml /usr/share/maven/conf/settings.xml

RUN yum -y clean all && rm -rf /var/cache/yum/*