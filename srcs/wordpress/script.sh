#!/bin/sh
mkdir -p /var/www/html

cd /var/www/html

rm -rf *

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# 파일 권한 설정 및 이동
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# 워드프레스 다운로드 & wp-config 만들기
if [ ! -e wp-config.php ]; then
	wp core download	--path=/var/www/html	\
						--locale=en_US      \
						--version=6.4.3     \
                        --allow-root
	wp config create	--force 			\
						--skip-check 		\
						--dbhost=mariadb	\
						--dbuser=$DB_USER	\
						--dbpass=$DB_PWD	\
						--dbname=$DB_NAME   \
                        --allow-root
fi

# 워드프레스 설치 & user 만들기
if ! wp core is-installed --allow-root; then
	wp core install --locale=en_US 						\
					--url=${DOMAIN_NAME}			    \
					--title=Inception					\
					--admin_user=${WP_ADMIN_USER}	    \
					--admin_email=${WP_ADMIN_EMAIL}		\
					--admin_password=${WP_ADMIN_PWD}    \
                    --allow-root
	wp user create	${WP_USER}					\
					${WP_USER_EMAIL} 			\
					--user_pass=${WP_USER_PWD}  \
                    --allow-root
fi

wp theme install astra --activate --allow-root

wp core update-db --allow-root

sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

mkdir -p /run/php

echo "clear_env = no" >> /etc/php/7.4/fpm/pool.d/www.conf

exec /usr/sbin/php-fpm7.4 -F
