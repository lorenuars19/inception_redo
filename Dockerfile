FROM alpine:3.16

################################################################################ NGINX <
# ZSH REMOVE BEFORE CORR
RUN apk -U upgrade && apk add zsh vim

# NGINX
RUN apk -U upgrade && apk add nginx

# Add user www and set permissions
RUN adduser -D -g 'www' www \
	&& chown -R www:www /var/lib/nginx \
	&& mkdir /www \
	&& chown -R www:www /www

# Generate Self-signed certificates with openssl
RUN apk -U upgrade && apk add openssl
RUN mkdir -p /nginx/ && mkdir -p /etc/nginx/ssl \
&& openssl req -x509 -subj="/C=BE/ST=Brussels/L=s19/O=19/CN=s19" -nodes \
	-days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/self.key \
	-out /etc/nginx/ssl/self.csr \
&& openssl x509 -days 365 -in /etc/nginx/ssl/self.csr \
	-signkey /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.crt

COPY ./nginx.conf /etc/nginx/http.d/default.conf
COPY ./index.html /www/index.html

EXPOSE 443

################################################################################ NGINX >

################################################################################ MYSQL <

RUN apk -U update && apk add mariadb mariadb-client

################################################################################ MYSQL >

################################################################################ WordPress <
# Setup PHP
RUN apk -U update && apk add php8 php8-common php8-session php8-iconv \
php8-json php8-gd php8-curl php8-xml php8-mysqli php8-imap php8-cgi php8-fpm fcgi \
php8-pdo php8-pdo_mysql php8-soap php8-posix php8-pecl-mcrypt \
php8-gettext php8-ldap php8-ctype php8-dom php8-simplexml php8-phar \
curl

COPY ./wordpress.sql /wordpress.sql
WORKDIR /www/

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv wp-cli.phar /bin/wp

RUN wp core download --path=/www/wordpress --allow-root --locale=en_US

################################################################################ WordPress >

COPY ./setup.sh /setup.sh

ENTRYPOINT [ "/bin/sh", "/setup.sh" ]
