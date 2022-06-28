FROM alpine:3.16

# ZSH REMOVE BEFORE CORR
RUN apk -U upgrade && apk add --no-cache nginx zsh

# NGINX
RUN apk -U upgrade && apk add --no-cache nginx

# Add user www and set permissions
RUN adduser -D -g 'www' www \
	&& chown -R www:www /var/lib/nginx \
	&& mkdir /www \
	&& chown -R www:www /www

# Generate Self-signed certificates with openssl
RUN mkdir -p /nginx/ && mkdir -p /etc/nginx/ssl \
&& openssl req -x509 -subj="/C=BE/ST=Brussels/L=s19/O=19/CN=s19" -nodes \
	-days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/self.key \
	-out /etc/nginx/ssl/self.csr \
&& openssl x509 -days 365 -in /etc/nginx/ssl/self.csr \
	-signkey /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.crt

COPY ./nginx.conf /etc/nginx/conf.d/wordpress.conf
COPY ./index.html /www/index.html

# Setup PHP
RUN apk -U update && apk add --no-cache php7-common php7-session php7-iconv \
php7-json php7-gd php7-curl php7-xml php7-mysqli php7-imap php7-cgi fcgi \
php7-pdo php7-pdo_mysql php7-soap php7-xmlrpc php7-posix php7-mcrypt \
php7-gettext php7-ldap php7-ctype php7-dom php7-simplexml \
wget php5-mysql mysql mysql-client php5-zlib

# Get wordpress and install it
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
&& chmod +x wp-cli.phar \
&& mv zp-cli.phar /bin/wp

WORKDIR /www/

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
