################################################################################ MYSQL <
/usr/bin/mysql_install_db --datadir="/var/lib/mysql/"
chown -R mysql:mysql /var/lib/mysql
cd '/usr' ; /usr/bin/mysqld_safe --user=mysql --datadir='/var/lib/mysql/' < /root/wordpress.sql &
################################################################################ MYSQL >

################################################################################ WordPress <

# Configure WordPress
echo $(pwd)
echo ================================================================= WP CONFIG
wp core config --path=/www/wordpress --allow-root --dbhost=localhost --dbname=prefix_db --dbuser=wordpress --dbpass=password
chmod 744 wp-config.php
echo ================================================================= WP INSTALL
wp core install --path=/www/wordpress --allow-root --url=url.42 --title="Title" --admin_name=wordpress_admin --admin_password=paswd
################################################################################ WordPress >

export PROMPT="%m@%n:%~ $ "
/bin/zsh
