FROM alpine

## Install required dependencies
RUN apk add --no-cache \
    libmaxminddb-dev \
    pcre-dev \
    zlib-dev \
    g++ \
    make

ARG NGINX=1.19.5
ARG GEOIP_MOD=3.3
ARG GEOIPUPDATE=4.5.0
## Download required packages
RUN wget https://github.com/leev/ngx_http_geoip2_module/archive/${GEOIP_MOD}.tar.gz \
    && wget https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE}/geoipupdate_${GEOIPUPDATE}_linux_amd64.tar.gz \
    && wget http://nginx.org/download/nginx-${NGINX}.tar.gz

## Unpack all the downloaded tarballs files
RUN tar zxvf ${GEOIP_MOD}.tar.gz \
    && tar zxvf nginx-${NGINX}.tar.gz \
    && tar zxvf geoipupdate_${GEOIPUPDATE}_linux_amd64.tar.gz \
    && cp /geoipupdate_${GEOIPUPDATE}_linux_amd64/geoipupdate /usr/local/bin/ \
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

## Clean up to reduce image size
RUN apk del zlib-dev g++ make \
    && rm -rf geoipupdate_${GEOIPUPDATE}_linux_amd64 \
    && rm -rf nginx-${NGINX} \
    && rm -rf ngx_http_geoip2_module-${GEOIP_MOD}

COPY nginx.conf /etc/nginx/nginx.conf
COPY endpoints /etc/nginx/endpoints.d
COPY start /start

CMD /start
