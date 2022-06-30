################################################################################ MYSQL <
/usr/bin/mysql_install_db --datadir="/var/lib/mysql/"
chown -R mysql:mysql /var/lib/mysql
cd '/usr' ; /usr/bin/mysqld_safe --user=mysql --datadir='/var/lib/mysql/' < /root/wordpress.sql &
################################################################################ MYSQL >

################################################################################ WordPress <

# Get wordpress and install it
cd /www/ \
&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /bin/wp

wp core download --path=/www/wordpress --allow-root --locale=en_US --force
wp core config --path=/www/wordpress --allow-root --dbhost=localhost --dbname=prefix_db --dbuser=mysql --dbpass=password
chmod 644 wp-config.php
wp core install --path=/www/wordpress --allow-root --url=url.42 --title="Title" --admin_name=wordpress_admin --admin_password=paswd
################################################################################ WordPress >

export PROMPT="%m@%n:%~ $ "
/bin/zsh
