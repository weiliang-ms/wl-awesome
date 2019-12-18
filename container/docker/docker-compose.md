## docker-compose

创建目录

	mkdir -p /docker-compose

创建docker-compose.yaml

	cat >> /docker-compose/docker-compose.yaml <<EOF
	version: "3.7"
	services:
	  nginx:
	    image: nginx
	    network_mode: "host"
	    ports:
	      - "80"
	EOF

启动

	docker-compose up -d

访问

	curl 127.0.0.1:80

11/18/2019 8:44:26 PM 