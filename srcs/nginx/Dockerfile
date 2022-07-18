FROM alpine:3.15

RUN apk -U upgrade && apk add nginx openssl

# Add user www and set permissions
RUN adduser -D -g 'www' www \
	&& chown -R www:www /var/lib/nginx \
	&& mkdir /www \
	&& mkdir /www/wordpress \
	&& chown -R www:www /www \
	&& chown -R www:www /www/wordpress

# Generate Self-signed certificates with openssl
RUN mkdir -p /nginx/ && mkdir -p /etc/nginx/ssl \
&& openssl req -x509 -subj="/C=BE/ST=Brussels/L=s19/O=19/CN=s19" -nodes \
	-days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/self.key \
	-out /etc/nginx/ssl/self.csr \
&& openssl x509 -days 365 -in /etc/nginx/ssl/self.csr \
	-signkey /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.crt

COPY ./nginx.conf /etc/nginx/http.d/default.conf

RUN ln -s /www/wordpress /etc/nginx/sites-enabled/

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
