export PROMPT="%m@%n:%~ $ "
################################################################################ MYSQL <

set -x

WP_DB_NAME='wordpress'
MY_SQL_ROOT_PASWD='pswd'
WP_DB_PSWD='pswd'
WP_DB_USER='lorenuar'
WP_DB_HOST='localhost'

/usr/bin/mysql_install_db --datadir="/var/lib/mysql/" --skip-test-db
chown -R mysql:mysql /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

mysqld --user=mysql --bootstrap << EOF

USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MY_SQL_ROOT_PASWD}' ;
FLUSH PRIVILEGES;

CREATE USER '${WP_DB_USER}'@'${WP_DB_HOST}' IDENTIFIED BY '${WP_DB_PSWD}' ;

CREATE DATABASE IF NOT EXISTS ${WP_DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'${WP_DB_HOST}' ;

FLUSH PRIVILEGES;

EOF

# sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
# sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

(/usr/bin/mysqld --datadir="/var/lib/mysql/" --user mysql )&

sleep 4

ps aux

echo =========================================================================== MYSQL SHOW DATABASES
(mysql --user=${WP_DB_USER} --password=${WP_DB_PSWD} << EOF
SHOW DATABASES;
USE wordpress;
SHOW tables;
EOF
)
echo =========================================================================== MYSQL END DATABASES

################################################################################ MYSQL >

################################################################################ WordPress <

# Configure WordPress
echo PWD: \"$(pwd)\"

echo LS: $(ls -la)

echo =========================================================================== PING MYSQL root
mysqladmin -u root --password=${MY_SQL_ROOT_PASWD} ping
echo =========================================================================== PING MYSQL ${WP_DB_USER}
mysqladmin -u ${WP_DB_USER} --password=${WP_DB_PSWD} ping

echo =========================================================================== WP DOWNLOAD
if [[ ! -d /www/wordpress ]]; then
	wp core download --path=/www/wordpress --allow-root --locale=en_US
fi

echo =========================================================================== WP CONFIG
wp core config --path=/www/wordpress --allow-root --url=localhost --dbhost=localhost --dbname=wordpress --dbuser=${WP_DB_USER} --dbpass=${WP_DB_PSWD}
chmod 744 ./wordpress/wp-config.php
echo =========================================================================== WP INSTALL
wp core install --path=/www/wordpress --allow-root --url=lorenuar.42.fr --title="Title" --admin_name=wordpress_admin --admin_password=pswd --admin_email=admin@lorenuar.42.fr
################################################################################ WordPress >

################################################################################ NGINX <
/usr/sbin/nginx
################################################################################ NGINX >

URL=http://localhost:80
URLSSL=https://localhost:443

echo ${URL}
echo ${URLSSL}

curl ${URL}
curl ${URLSSL}

nginx -T > /www/.log.conf

ls -la /etc/nginx
ls -la /etc/nginx/http.d

/bin/zsh
