FROM alpine

ARG NGINX
ARG GEOIP_MOD
ARG GEOIPUPDATE
ARG MAXMIND_ACCOUNT
ARG MAXMIND_KEY
ARG MAXMIND_PRODUCTS
## By default it will try to update the database
## Every Tuesday, Thursday, and Sunday at 10:00.
ARG JOB_SCHEDULE="0 10 * * 2,4,7"

## Install required dependencies
RUN apk add --no-cache \
    libmaxminddb-dev \
    pcre-dev \
    zlib-dev \
    g++ \
    make

## Download required packages
RUN wget https://github.com/leev/ngx_http_geoip2_module/archive/${GEOIP_MOD}.tar.gz \
    && wget https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE}/geoipupdate_${GEOIPUPDATE}_linux_amd64.tar.gz \
    && wget http://nginx.org/download/nginx-${NGINX}.tar.gz

## Unpack all the downloaded tarballs files
RUN tar zxvf ${GEOIP_MOD}.tar.gz \
    && tar zxvf geoipupdate_${GEOIPUPDATE}_linux_amd64.tar.gz \
    && tar zxvf nginx-${NGINX}.tar.gz \
    && rm -rf *.tar.gz

## Compile and Install Nginx with GeoIP module.
RUN  cd nginx-${NGINX} && ./configure \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --add-module=/ngx_http_geoip2_module-${GEOIP_MOD} \
    && make && make install

## Download initial database and configure auto-updates.
RUN cp /geoipupdate_${GEOIPUPDATE}_linux_amd64/geoipupdate /usr/local/bin/ \
    && mkdir -p /usr/local/etc/ \
    && echo "AccountID ${MAXMIND_ACCOUNT}" > /usr/local/etc/GeoIP.conf \
    && echo "LicenseKey ${MAXMIND_KEY}" >> /usr/local/etc/GeoIP.conf \
    && echo "EditionIDs ${MAXMIND_PRODUCTS}" >> /usr/local/etc/GeoIP.conf \
    && echo "DatabaseDirectory /etc/nginx/geoip" >> /usr/local/etc/GeoIP.conf \
    && echo "${JOB_SCHEDULE} geoipupdate -v >> /var/log/cron.log 2>&1" >> /tmp/crontab.txt \
    && crontab /tmp/crontab.txt \
    && mkdir -p /etc/nginx/geoip && geoipupdate -v \
    && mv `ls /etc/nginx/geoip/*.mmdb | head -n 1` /etc/nginx/geoip/db.mmdb

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf

CMD crond && nginx -g "daemon off;"