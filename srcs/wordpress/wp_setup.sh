echo =========================================================================== WP DOWNLOAD
mkdir -p /www/wordpress
wp core download --path=/www/wordpress --allow-root --locale=en_US

echo =========================================================================== WP CONFIG
wp core config --path=/www/wordpress --allow-root --url=localhost --dbhost=mysql --dbname=wordpress --dbuser=${WP_DB_USER} --dbpass=${WP_DB_PSWD}
chmod 744 ./wordpress/wp-config.php
echo =========================================================================== WP INSTALL
wp core install --path=/www/wordpress --allow-root --url=lorenuar.42.fr --title="Title" --admin_name=lorenuar --admin_password=${WP_ADMIN_PSWD} --admin_email=lorenuar@lorenuar.42.fr

wp user create --path=/www/wordpress --allow-root editor editor@lorenuar.42.fr --role='editor' --user_pass=${WP_EDIT_PSWD}

sed -i "/s/listen = .*/listen = 9000/g" /etc/php8/php-fpm.d/www.conf

/usr/sbin/php-fpm8 --nodaemonize
