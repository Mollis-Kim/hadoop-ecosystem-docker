

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
RUN apt install x11-apps -y
RUN apt install firefox -y
RUN apt install -y wget unzip 
RUN wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip -P /root
RUN sudo unzip -d /usr/share/fonts/d2coding /root/D2Coding-Ver1.3.2-20180524.zip

RUN echo "root:root" | chpasswd 
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd
RUN echo "ubuntu  ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN echo "ubuntu  ALL=NOPASSWD: ALL" >> /etc/sudoers

USER ubuntu
RUN ssh-keygen -q -t rsa -N '' -f /home/ubuntu/.ssh/id_rsa
RUN cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
RUN chmod 0600 /home/ubuntu/.ssh/authorized_keys
RUN sudo mkdir /mollis
RUN sudo chown ubuntu:ubuntu /mollis
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install Hadoop

RUN sudo wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -P /mollis
RUN sudo tar -zxvf /mollis/hadoop-3.3.3.tar.gz -C /mollis
RUN sudo rm /mollis/hadoop-3.3.3.tar.gz
RUN sudo mv /mollis/hadoop-3.3.3 /mollis/hadoop3
ENV PATH ${PATH}:/mollis/hadoop3/bin:/mollis/hadoop3/sbin

RUN sudo mkdir -p /mollis/hadoop3/logs
RUN sudo mkdir -p /mollis/hadoop3/pids
COPY conf/hadoop-env.sh /mollis/hadoop3/etc/hadoop
COPY conf/core-site.xml /mollis/hadoop3/etc/hadoop
COPY conf/hdfs-site.xml /mollis/hadoop3/etc/hadoop
COPY conf/mapred-site.xml /mollis/hadoop3/etc/hadoop
COPY conf/yarn-site.xml /mollis/hadoop3/etc/hadoop
COPY conf/capacity-scheduler.xml /mollis/hadoop3/etc/hadoop
COPY conf/workers /mollis/hadoop3/etc/hadoop


# Install Hive

RUN sudo wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz -P /mollis
RUN sudo tar -zxvf /mollis/apache-hive-3.1.3-bin.tar.gz -C /mollis
RUN sudo rm /mollis/apache-hive-3.1.3-bin.tar.gz
RUN sudo mv /mollis/apache-hive-3.1.3-bin /mollis/hive
ENV PATH ${PATH}:/mollis/hive/bin

COPY conf/hive-env.sh /mollis/hive/conf
COPY conf/hive-site.xml /mollis/hive/conf

RUN sudo rm -f /mollis/hive/lib/guava-*
RUN sudo cp /mollis/hadoop3/share/hadoop/common/lib/guava-27.0-jre.jar /mollis/hive/lib/

RUN sudo wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-8.0.30.tar.gz -P /mollis/hive
RUN sudo tar -zxvf /mollis/hive/mysql-connector-java-8.0.30.tar.gz -C /mollis/hive
RUN sudo mv /mollis/hive/mysql-connector-java-8.0.30/mysql-connector-java-8.0.30.jar /mollis/hive/lib/
RUN sudo rm -r /mollis/hive/mysql-connector-java-8.0.30*

# Install Tez

RUN sudo wget https://dlcdn.apache.org/tez/0.9.2/apache-tez-0.9.2-bin.tar.gz -P /mollis
RUN sudo tar -zxvf /mollis/apache-tez-0.9.2-bin.tar.gz -C /mollis
RUN sudo rm /mollis/apache-tez-0.9.2-bin.tar.gz
RUN sudo mv /mollis/apache-tez-0.9.2-bin /mollis/tez

COPY conf/tez-site.xml /mollis/tez/conf

RUN sudo cp /mollis/hadoop3/share/hadoop/common/lib/guava-27.0-jre.jar /mollis/tez/lib/
RUN sudo rm -f /mollis/tez/lib/guava-11.0.2.jar

# Install Spark

RUN sudo wget https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz -P /mollis
RUN sudo tar -zxvf /mollis/spark-3.2.1-bin-hadoop3.2.tgz -C /mollis
RUN sudo rm /mollis/spark-3.2.1-bin-hadoop3.2.tgz
RUN sudo mv /mollis/spark-3.2.1-bin-hadoop3.2 /mollis/spark

COPY conf/spark-env.sh /mollis/spark/conf
COPY conf/spark-defaults.conf /mollis/spark/conf
COPY conf/workers /mollis/spark/conf
RUN sudo mkdir -p /mollis/spark/history


# Install Zeppelin
RUN sudo wget https://archive.apache.org/dist/zeppelin/zeppelin-0.10.1/zeppelin-0.10.1-bin-all.tgz -P /mollis
RUN sudo tar -zxvf /mollis/zeppelin-0.10.1-bin-all.tgz -C /mollis
RUN sudo mv /mollis/zeppelin-0.10.1-bin-all /mollis/zeppelin
RUN sudo rm -f /mollis/zeppelin-0.10.1-bin-all.tgz

RUN sudo cp /mollis/zeppelin/conf/zeppelin-site.xml.template /mollis/zeppelin/conf/zeppelin-site.xml
RUN sudo sed -i 's/<value>127.0.0.1<\/value>/<value>0.0.0.0<\/value>/g' /mollis/zeppelin/conf/zeppelin-site.xml
RUN sudo sed -i 's/<value>8080<\/value>/<value>9090<\/value>/g' /mollis/zeppelin/conf/zeppelin-site.xml

RUN sudo chown ubuntu:ubuntu /mollis/hadoop3
RUN sudo chown ubuntu:ubuntu /mollis/hive
RUN sudo chown ubuntu:ubuntu /mollis/spark
RUN sudo chown ubuntu:ubuntu /mollis/tez
RUN sudo chown -R ubuntu:ubuntu /mollis/hadoop3/etc/hadoop
RUN sudo chown -R ubuntu:ubuntu /mollis/hadoop3/pids
RUN sudo chown -R ubuntu:ubuntu /mollis/hadoop3/logs
RUN sudo chown -R ubuntu:ubuntu /mollis/hive/conf
RUN sudo chown -R ubuntu:ubuntu /mollis/spark/conf
RUN sudo chown -R ubuntu:ubuntu /mollis/tez/conf
RUN sudo "firefox > /dev/null 2>&1 &" > /mollis/firefox.sh
RUN sudo chmod +x /mollis/firefox.sh


ENTRYPOINT sudo service ssh restart && bash
WORKDIR /mollis
