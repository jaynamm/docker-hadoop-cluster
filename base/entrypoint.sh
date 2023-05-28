#!/bin/bash

function addProperty() {
    local path=$1
    local propertyName=$2
    local propertyValue=$3
    local propertyFinal=$4

    # 추가할 프로퍼티 라인 생성
    if [ -n "${propertyFinal}" ]; then
        local entry="<property> <name>${propertyName}</name> <value>${propertyValue}</value> <final>${propertyFinal}</final> </property>"
    else
        local entry="<property> <name>${propertyName}</name> <value>${propertyValue}</value> </property>"
    fi

    local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
    sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

# HDFS
addProperty ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml dfs.replication 2 true
addProperty ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml dfs.namenode.name.dir /opt/hadoop/namenode true
addProperty ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml dfs.datanode.data.dir /opt/hadoop/datanode true

# CORE
addProperty ${HADOOP_HOME}/etc/hadoop/core-site.xml hadoop.tmp.dir /opt/hadoop/temp
addProperty ${HADOOP_HOME}/etc/hadoop/core-site.xml fs.defaultFS hdfs://nn:9000

# MAPRED
cp ${HADOOP_HOME}/etc/hadoop/mapred-site.xml.template ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
addProperty ${HADOOP_HOME}/etc/hadoop/mapred-site.xml mapred.job.tracker nn:9001


exec $@