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
RUN rm -rf /tmp/apache-maven.tar.gz
ENV MAVEN_HOME /usr/share/maven
RUN mvn -v

###############################################
## install node
###############################################
COPY ./depends/nodejs-16.14.0-2.el7.x86_64.rpm /tmp/nodejs.rpm
COPY ./depends/openssl11-1.1.1k-2.el7.x86_64.rpm /tmp/
COPY ./depends/brotli-1.0.7-5.el7.x86_64.rpm /tmp/
COPY ./depends/libuv-1.43.0-2.el7.x86_64.rpm /tmp/
COPY ./depends/nodejs-libs-16.14.0-2.el7.x86_64.rpm /tmp/
COPY ./depends/openssl11-libs-1.1.1k-2.el7.x86_64.rpm /tmp/
COPY ./depends/npm-8.3.1-1.16.14.0.2.el7.x86_64.rpm /tmp/npm.rpm

RUN yum -y install /tmp/*.rpm
RUN rm -rf /tmp/*.rpm

RUN node -v
RUN npm -v

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
RUN yum install -y go
RUN go version

RUN yum -y clean all
