# docker build -t himuchik/hadoop-hive-spark-base:latest .
# docker network create -d bridge mynet
# docker run -d -h mysql --name mysql -e TZ=UTC -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root --network mynet ubuntu/mysql:latest
# docker exec -it mysql mysql -u root -proot -e "CREATE DATABASE hive; CREATE USER 'hive'@'%' identified by 'hive'; GRANT ALL PRIVILEGES ON hive.* to 'hive'@'%'; FLUSH PRIVILEGES;"
# docker run -itd -h namenode --privileged --network mynet --name namenode -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY himuchik/hadoop-hive-spark-base:latest
# docker run -itd -h namenode --privileged --network mynet --name namenode -p 9870:9870 -p 9864:9864 -p 8088:8088 -p 8042:8042 -p 8080:8080 -p 4040:4040 -p 10002:10002 -p 9090:9090 himuchik/hadoop-hive-spark-base:latest
# docker run -itd -h datanode1 --privileged --network mynet --name datanode1 himuchik/hadoop-hive-spark-base:latest
# docker run -itd -h datanode2 --privileged --network mynet --name datanode2 himuchik/hadoop-hive-spark-base:latest
# docker run -itd -h datanode3 --privileged --network mynet --name datanode3 himuchik/hadoop-hive-spark-base:latest

FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
RUN sed -i 's/security.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list 
RUN sed -i 's/extras.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list 
RUN apt update -y 
RUN apt install vim -y 
RUN apt install openjdk-8-jdk -y
RUN apt install openssh-server -y
RUN apt install sudo -y 
RUN apt install acl
RUN apt install x11-apps -y
RUN apt install firefox -y
RUN apt install unzip -y
RUN wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip -P /root
RUN sudo unzip -d /usr/share/fonts/d2coding /root/D2Coding-Ver1.3.2-20180524.zip

RUN echo "root:root" | chpasswd 
RUN useradd -m -s /bin/bash hadoop && echo "hadoop:hadoop" | chpasswd
RUN echo "hadoop  ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN echo "hadoop  ALL=NOPASSWD: ALL" >> /etc/sudoers

USER hadoop
RUN ssh-keygen -q -t rsa -N '' -f /home/hadoop/.ssh/id_rsa
RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
RUN chmod 0600 /home/hadoop/.ssh/authorized_keys
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Hadoop

RUN sudo wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -P /opt
RUN sudo tar -zxvf /opt/hadoop-3.3.3.tar.gz -C /opt
RUN sudo rm /opt/hadoop-3.3.3.tar.gz
RUN sudo mv /opt/hadoop-3.3.3 /opt/hadoop
RUN sudo setfacl -m user:hadoop:rwx /opt/hadoop
ENV PATH ${PATH}:/opt/hadoop/bin:/opt/hadoop/sbin

RUN sudo mkdir -p /opt/hadoop/logs
RUN sudo setfacl -m user:hadoop:rwx /opt/hadoop/logs
COPY conf/hadoop-env.sh /opt/hadoop/etc/hadoop
COPY conf/core-site.xml /opt/hadoop/etc/hadoop
COPY conf/hdfs-site.xml /opt/hadoop/etc/hadoop
COPY conf/mapred-site.xml /opt/hadoop/etc/hadoop
COPY conf/yarn-site.xml /opt/hadoop/etc/hadoop
COPY conf/capacity-scheduler.xml /opt/hadoop/etc/hadoop
COPY conf/workers /opt/hadoop/etc/hadoop
RUN sudo setfacl -m user:hadoop:rwx /opt/hadoop/etc/hadoop/*


# Install Hive

RUN sudo wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz -P /opt
RUN sudo tar -zxvf /opt/apache-hive-3.1.3-bin.tar.gz -C /opt
RUN sudo rm /opt/apache-hive-3.1.3-bin.tar.gz
RUN sudo mv /opt/apache-hive-3.1.3-bin /opt/hive
RUN sudo setfacl -m user:hadoop:rwx /opt/hive
ENV PATH ${PATH}:/opt/hive/bin

COPY conf/hive-env.sh /opt/hive/conf
COPY conf/hive-site.xml /opt/hive/conf
RUN sudo setfacl -m user:hadoop:rwx /opt/hive/conf*

RUN sudo rm -f /opt/hive/lib/guava-*
RUN sudo cp /opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /opt/hive/lib/

RUN sudo wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-8.0.30.tar.gz -P /opt/hive
RUN sudo tar -zxvf /opt/hive/mysql-connector-java-8.0.30.tar.gz -C /opt/hive
RUN sudo mv /opt/hive/mysql-connector-java-8.0.30/mysql-connector-java-8.0.30.jar /opt/hive/lib/
RUN sudo rm -r /opt/hive/mysql-connector-java-8.0.30*
RUN sudo setfacl -m user:hadoop:rwx /opt/hive/conf/*

# Install Tez

RUN sudo wget https://dlcdn.apache.org/tez/0.9.2/apache-tez-0.9.2-bin.tar.gz -P /opt
RUN sudo tar -zxvf /opt/apache-tez-0.9.2-bin.tar.gz -C /opt
RUN sudo rm /opt/apache-tez-0.9.2-bin.tar.gz
RUN sudo mv /opt/apache-tez-0.9.2-bin /opt/tez
RUN sudo setfacl -m user:hadoop:rwx /opt/tez
ENV PATH ${PATH}:/opt/tez/bin

COPY conf/tez-site.xml /opt/tez/conf
RUN sudo setfacl -m user:hadoop:rwx /opt/tez/conf*

RUN sudo cp /opt/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar /opt/tez/lib/
RUN sudo rm -f /opt/tez/lib/guava-11.0.2.jar
RUN sudo setfacl -m user:hadoop:rwx /opt/tez/conf/*

# Install Spark

RUN sudo wget https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz -P /opt
RUN sudo tar -zxvf /opt/spark-3.2.1-bin-hadoop3.2.tgz -C /opt
RUN sudo rm /opt/spark-3.2.1-bin-hadoop3.2.tgz
RUN sudo mv /opt/spark-3.2.1-bin-hadoop3.2 /opt/spark
RUN sudo setfacl -m user:hadoop:rwx /opt/spark

COPY conf/spark-env.sh /opt/spark/conf
COPY conf/spark-defaults.conf /opt/spark/conf
COPY conf/workers /opt/spark/conf
RUN sudo setfacl -m user:hadoop:rwx /opt/spark/conf*
RUN mkdir -p /opt/spark/history


# Install Zeppelin
RUN sudo wget https://archive.apache.org/dist/zeppelin/zeppelin-0.10.1/zeppelin-0.10.1-bin-all.tgz -P /opt
RUN sudo tar -zxvf /opt/zeppelin-0.10.1-bin-all.tgz -C /opt
RUN sudo rm -f zeppelin-0.10.1-bin-all.tgz
RUN sudo mv /opt/zeppelin-0.10.1-bin-all /opt/zeppelin
RUN sudo cp /opt/zeppelin/conf/zeppelin-site.xml.template /opt/zeppelin/conf/zeppelin-site.xml
RUN sudo sed -i 's/<value>127.0.0.1<\/value>/<value>0.0.0.0<\/value>/g' /opt/zeppelin/conf/zeppelin-site.xml
RUN sudo sed -i 's/<value>8080<\/value>/<value>9090<\/value>/g' /opt/zeppelin/conf/zeppelin-site.xml
RUN sudo setfacl -m user:hadoop:rwx /opt/zeppelin/conf/*
RUN sudo setfacl -m user:hadoop:rwx /opt/zeppelin



ENTRYPOINT sudo service ssh restart && bash
WORKDIR /home/hadoop
