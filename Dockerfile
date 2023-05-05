# Hadoop Base Image
#
# Date: 2023.03.29
# Author: 남정현
# 

FROM centos:7

# yum 업데이트 및 필요 라이브러리 설치
RUN yum update -y \
    && yum install -y \
        wget \
        vim \
        openssh-server \
        openssh-clients \
        openssh-askpass \
        java-1.8.0-openjdk-devel.x86_64

# 패스워드 입력 없이 접속하기 위한 공개키 생성
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_dsa \
    && cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N "" \
    && ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -t ecdsa -N "" \
    && ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N ""

# 자바를 설치한 후 JAVA_HOME 변수 선언
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64

# ~/.bashrc 파일에 JAVA_HOME 환경 변수 설정
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ~/.bashrc

# Hadoop 디렉터리 생성
RUN mkdir /opt/hadoop

# Hadoop 설치를 위한 변수 선언
ENV HADOOP_DIR=/opt/hadoop
ENV HADOOP_VERSION=hadoop-2.7.7
ENV HADOOP_HOME=${HADOOP_DIR}/${HADOOP_VERSION}
ENV HADOOP_CONFIG_HOME=${HADOOP_HOME}/etc/hadoop

# Hadoop 설치
RUN wget -d https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz -P ${HADOOP_DIR} \
    && tar -xvzf ${HADOOP_DIR}/hadoop-2.7.7.tar.gz -C ${HADOOP_DIR} \
    && rm -rf ${HADOOP_DIR}/hadoop-2.7.7.tar.gz

# ~/.bashrc 파일에 하둡 환경변수 설정
RUN echo "export HADOOP_HOME=${HADOOP_HOME}" >> ~/.bashrc \
    && echo "export HADOOP_CONFIG_HOME=${HADOOP_CONFIG_HOME}" >> ~/.bashrc \
    && echo "export PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin" >> ~/.bashrc

RUN source ~/.bashrc

# Make namenode, datanode, temp directory
RUN mkdir ${HADOOP_DIR}/namenode \
    && mkdir ${HADOOP_DIR}/datanode \
    && mkdir ${HADOOP_DIR}/temp

# Add Hadoop Config File
ADD core-site.xml ${HADOOP_CONFIG_HOME}
ADD hdfs-site.xml ${HADOOP_CONFIG_HOME}
ADD mapred-site.xml ${HADOOP_CONFIG_HOME}

# Hadoop namenode format
RUN ${HADOOP_HOME}/bin/hadoop namenode -format

ADD entrypoint.sh ${HADOOP_DIR}
RUN chmod 755 ${HADOOP_DIR}/entrypoint.sh