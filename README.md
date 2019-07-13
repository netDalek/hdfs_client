# HdfsClient

docker containers that can be used for tests
```
container without httpfs
docker run -p 22022:22 -p 8020:8020 -p 50010:50010 -p 50020:50020 -p 50070:50070 -p 50075:50075 -it mdouchement/hdfs
curl http://localhost:50070/webhdfs/v1/\?op\=LISTSTATUS
curl -i -X PUT http://localhost:50070/webhdfs/v1/tmp\?op\=CREATE

redirect to

curl -i -X PUT http://localhost:50075/webhdfs/v1/tmp\?op\=CREATE\&namenoderpcaddress\=localhost:8020\&overwrite\=false
curl http://localhost:50070/webhdfs/v1/\?op\=LISTSTATUS

container with httpfs
docker run -p 50070:50070 -p 14000:14000 -it ukwa/docker-hadoop
curl http://localhost:50070/webhdfs/v1/\?op\=LISTSTATUS
curl http://localhost:14000/webhdfs/v1/\?op\=LISTSTATUS
curl http://localhost:14000/webhdfs/v1/\?op\=LISTSTATUS\&user.name\=hadoop
```
