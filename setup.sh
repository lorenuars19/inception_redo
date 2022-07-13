export PROMPT="%m@%n:%~ $ "
################################################################################ MYSQL <

set -x

WP_DB_NAME='wordpress'
MY_SQL_ROOT_PASWD='pswd'
MY_SQL_PASWD='pswd'
WP_DB_USER='wordpress'@'localhost'

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

CREATE DATABASE ${WP_DB_NAME};
CREATE USER ${WP_DB_USER} IDENTIFIED BY '${MY_SQL_PASWD}' ;
GRANT ALL PRIVILEGES ON ${WP_DB_NAME} TO ${WP_DB_USER} ;

FLUSH PRIVILEGES;

EOF

if [[ $? -ne 0 ]] ; then
	exit
fi

# sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
# sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

(/usr/bin/mysqld --datadir="/var/lib/mysql/" --user mysql)&

sleep 4

ps aux


echo =========================================================================== MYSQL SHOW DATABASES
(mysql -uroot -p${MY_SQL_ROOT_PASWD} << EOF
SHOW DATABASES;
EOF
)

################################################################################ MYSQL >

################################################################################ WordPress <

# Configure WordPress
echo PWD: \"$(pwd)\"

echo LS: $(ls -laR)

echo =========================================================================== PING MYSQL root
mysqladmin -u root --password=${MY_SQL_ROOT_PASWD} ping
echo =========================================================================== PING MYSQL wordpress
mysqladmin -u wordpress --password=${MY_SQL_PASWD} ping

echo =========================================================================== WP DOWNLOAD
if [[ ! -d /www/wordpress ]]; then
	wp core download --path=/www/wordpress --allow-root --locale=en_US
fi

echo =========================================================================== WP CONFIG
wp core config --path=/www/wordpress --allow-root --url=localhost --dbhost=localhost --dbname=wordpress --dbuser=wordpress --dbpass=${MY_SQL_PASWD}
chmod 744 ./wordpress/wp-config.php
echo =========================================================================== WP INSTALL
wp core install --path=/www/wordpress --allow-root --url=url.42 --title="Title" --admin_name=wordpress_admin --admin_password=pswd
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

/bin/zsh
