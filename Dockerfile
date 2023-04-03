FROM alpine as builder

WORKDIR /app

RUN apk add --no-cache \
	mercurial \
	gcc \
	pcre-dev zlib-dev build-base openssl-dev

RUN hg clone -b stable-1.22 https://hg.nginx.org/nginx 

WORKDIR /app/nginx
COPY configure .
RUN ./configure --with-stream_ssl_preread_module --with-stream --with-stream_ssl_module --prefix=/etc/nginx --sbin-path=/usr/local/sbin/nginx
RUN make

USER root
RUN make install

FROM alpine
RUN apk add --no-cache pcre
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/local/sbin/nginx /usr/local/sbin/nginx

ENTRYPOINT [ "nginx", "-g", "daemon off;"]
