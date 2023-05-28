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


function wait_for_it()
{
    local serviceport=$1
    local service=${serviceport%%:*}  # serviceport 문자열을 ':'을 기준으로 나누어 첫 번째 요소를 service 변수에 저장
    local port=${serviceport#*:}  # serviceport 문자열을 ':'을 기준으로 나누어 두 번째 요소를 port 변수에 저장
    local retry_seconds=5  # 서비스를 다시 확인하기 전에 대기할 시간(초)
    local max_try=100  # 최대 시도 횟수
    let i=1  # 현재 시도 횟수를 나타내는 변수

    nc -z $service $port  # nc 명령어를 사용하여 서비스와 포트가 사용 가능한지 확인
    result=$?  # 명령어 실행 결과 저장 (0: 성공, 1: 실패)

    until [ $result -eq 0 ]; do  # 명령어 실행 결과가 성공(0)이 될 때까지 반복
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then  # 최대 시도 횟수에 도달한 경우
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1  # 스크립트 종료 (실패)
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"  # 시도 횟수 증가
      sleep $retry_seconds  # 대기

      nc -z $service $port  # 다시 한 번 nc 명령어를 사용하여 서비스와 포트가 사용 가능한지 확인
      result=$?  # 명령어 실행 결과 저장
    done
    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@