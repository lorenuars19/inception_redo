
/usr/bin/mariadb_install_db --datadir="/var/lib/mysql/" --skip-test-db
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

sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

/usr/bin/mysqld --datadir="/var/lib/mysql/" --user mysql
