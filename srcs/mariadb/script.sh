#!/bin/bash

if [ ! -d "/run/mysqld" ]; then
	echo "Directory '/run/mysqld' doesn't exist"
	echo "Creating '/run/mysqld' directory"
	mkdir -p "/run/mysqld"
	chown -R mysql:mysql /run/mysqld
else
	echo "Directory '/run/mysqld' already exists"
fi

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PWD" ]; then
    echo "Error: Database environment variables are not set."
    exit 1
fi

echo "FLUSH PRIVILEGES;" > init.sql
echo "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" >> init.sql
echo "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PWD';" >> init.sql
echo "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';" >> init.sql
echo "FLUSH PRIVILEGES;" >> init.sql

# 서비스 시작
service mariadb start
sleep 0.1

# SQL 시작하기
mysql < init.sql

# 서비스 종료
service mariadb stop
sleep 0.1

# 포그라운드 실행
exec mysqld_safe