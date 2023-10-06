FROM golang:latest as huproxy
RUN mkdir -p /huproxy
WORKDIR /huproxy
COPY huproxy/ .
RUN mkdir /app
# RUN go get -d -v .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o /app ./cmd/huproxy
RUN CGO_ENABLED=0 GOOS=linux go build -a -o /app ./cmd/huproxyclient

FROM ubuntu:22.04

RUN apt-get update -y \
    && apt-get install -y wget curl screen git dnsutils iputils-ping traceroute nano nginx net-tools strace tini dropbear apache2-utils

COPY --from=huproxy /app/ /usr/local/bin/
COPY layers/ /

RUN sed -i -e 's/80 d/8080 d/g' /etc/nginx/sites-available/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir -p /var/lib/nginx /var/run/tailscale

USER root

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
