FROM alpine

ARG NGINX
ARG GEOIP_MOD

RUN apk add --no-cache \
    libmaxminddb-dev \
    pcre-dev \
    zlib-dev \
    g++ \
    make

RUN wget https://github.com/leev/ngx_http_geoip2_module/archive/$GEOIP_MOD.tar.gz \
    && wget http://nginx.org/download/nginx-$NGINX.tar.gz

RUN tar zxvf $GEOIP_MOD.tar.gz \
    && tar zxvf nginx-$NGINX.tar.gz

RUN  cd nginx-$NGINX && ./configure \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid \
    --add-module=/ngx_http_geoip2_module-$GEOIP_MOD \
    && make && make install

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY database/GeoIP2-Country.mmdb /etc/nginx/geoip/countries.mmdb

CMD ["nginx", "-g", "daemon off;"]