FROM alpine AS builder

WORKDIR /app

RUN apk add --no-cache \
	git \
	gcc \
	pcre-dev zlib-dev build-base openssl-dev

RUN git clone -b stable-1.28 https://github.com/nginx/nginx

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

RUN mkdir /var/log/nginx

ENTRYPOINT [ "nginx", "-g", "daemon off;"]
