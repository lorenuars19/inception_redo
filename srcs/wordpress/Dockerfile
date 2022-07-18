FROM alpine:3.15

# Setup PHP
RUN apk -U update && apk add php8 php8-common php8-session php8-iconv \
php8-json php8-gd php8-curl php8-xml php8-mysqli php8-imap php8-cgi php8-fpm fcgi \
php8-pdo php8-pdo_mysql php8-soap php8-posix php8-pecl-mcrypt \
php8-gettext php8-ldap php8-ctype php8-dom php8-simplexml php8-phar \
curl mysql-client

WORKDIR /www/

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /bin/wp

RUN adduser -D -g 'www' www \
	&& chown -R www:www /var/lib/nginx \
	&& mkdir /www \
	&& mkdir /www/wordpress \
	&& chown -R www:www /www \
	&& chown -R www:www /www/wordpress

RUN wp core download --path=/www/wordpress --allow-root --locale=en_US

COPY ./wp_setup.sh /setup.sh
COPY ./www.conf /etc/php8/php-fpm.d/www.conf

ENTRYPOINT ["/bin/sh", "/setup.sh"]
