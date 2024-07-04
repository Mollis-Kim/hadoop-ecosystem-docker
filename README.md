 hadoop-ecosystem docker

# Hadoop Hive Spark DockerFile
1. 도커파일 빌드 및 브릿지 네트워크 생성
```sh
docker build -t himuchik/hadoop-hive-spark-base:latest .
docker network create -d bridge mynet
```


2. 컨테이너 실행 (포트포워딩 없이 Web UI 사용하려면 WSL에서 docker run 권장)

    wsl의 DISPLAY환경변수 공유 시 X11-unix 패키지 사용으로 도커 내에서 GUI사용 가능


```sh
#마스터 실행
docker run -itd -h master --privileged --network mynet --name master -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY himuchik/hadoop-hive-spark-base:latest
```
```sh
# 워커1~워커3 실행
docker run -itd -h worker1 --privileged --network mynet --name worker1 himuchik/hadoop-hive-spark-base:latest
docker run -itd -h worker2 --privileged --network mynet --name worker2 himuchik/hadoop-hive-spark-base:latest
docker run -itd -h worker3 --privileged --network mynet --name worker3 himuchik/hadoop-hive-spark-base:latest
```

※ Hive Warehouse 사용 시, 메타스토어DB를 위한 mysql

```sh
docker run -d -h mysql --name mysql -e TZ=UTC -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root --network mynet mysql:5.7
docker exec -it mysql mysql -u root -proot -e "CREATE DATABASE hive; CREATE USER 'hive'@'%' identified by 'hive'; GRANT ALL PRIVILEGES ON hive.* to 'hive'@'%'; FLUSH PRIVILEGES;"
```