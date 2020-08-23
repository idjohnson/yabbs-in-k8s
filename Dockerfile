FROM nginx:1.10

RUN umask 0002

RUN apt-get clean && apt-get update && apt-get install -y nano spawn-fcgi fcgiwrap wget curl

RUN sed -i 's/www-data/nginx/g' /etc/init.d/fcgiwrap
RUN chown nginx:nginx /etc/init.d/fcgiwrap
ADD ./vhost.conf /etc/nginx/conf.d/default.conf

COPY . /var/www

RUN mkdir -p /tmp/bbinstall
COPY ./bin/YaBB_2.6.11.tar.gz /tmp/bbinstall

WORKDIR /tmp/bbinstall
RUN umask 0002 && tar -xzf YaBB_2.6.11.tar.gz
RUN chown -R nginx:nginx YaBB_2.6.11
RUN find . -type f -name \*.pl -exec chmod 755 {} \;
RUN mv YaBB_2.6.11/cgi-bin /var/www
RUN mv YaBB_2.6.11/public_html/yabbfiles /var/www

RUN mkdir -p /var/log/nginx/web

WORKDIR /var/www

RUN mkdir -p /var/wwwbase
RUN cp -vnpr /var/www/* /var/wwwbase

#ENTRYPOINT [ "sh", "-c", "sleep 500000" ]
CMD cp -vnpr /var/wwwbase/* /var/www && /etc/init.d/fcgiwrap start && nginx -g 'daemon off;'

