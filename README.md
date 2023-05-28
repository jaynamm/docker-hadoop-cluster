# 도커로 하둡 클러스터 만들기

### Dockerfile (hadoop-base)
각 서버의 Dockerfile 의 내용은 다음과 같습니다.  

### Build Hadoop Base Image
하둡 서버에서 공통적으로 사용되는 이미지 빌드
```
docker build -t hadoop-base ./base/
```

### Build Hadoop NameNode Image
하둡 네임노드 이미지 빌드
```
docker build -t hadoop-namenode ./namenode/
```

### Build Hadoop DataNode Image
하둡 데이터노드 이미지 빌드
```
docker build -t hadoop-datanode ./datanode/
```

### Run Hadoop Cluster
각 빌드된 이미지를 통해 컨테이너 생성
```
docker-compose up
```