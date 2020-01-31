FROM nginx:1.17.8-alpine

ENV TZ UTC
ENV DNS false
ENV DNS_PROPAGATION 60

ADD nginx.conf /etc/nginx/nginx.conf
ADD entrypoint.sh /entrypoint.sh
ADD le.sh /le.sh

RUN \
 rm /etc/nginx/conf.d/default.conf && \
 chmod +x /entrypoint.sh && \
 chmod +x /le.sh && \
 apk add  --update certbot tzdata openssl && \
 rm -rf /var/cache/apk/*

RUN pip3 install --upgrade pip
RUN pip3 install \
    certbot-dns-cloudflare==0.35.1 \
    certbot-dns-cloudxns==0.35.1 \
    certbot-dns-digitalocean==0.35.1 \
    certbot-dns-dnsimple==0.35.1 \
    certbot-dns-dnsmadeeasy==0.35.1 \
    certbot-dns-google==0.35.1 \
    certbot-dns-linode==0.35.1 \
    certbot-dns-luadns==0.35.1 \
    certbot-dns-nsone==0.35.1 \
    certbot-dns-ovh==0.35.1 \
    certbot-dns-rfc2136==0.35.1 \
    certbot-dns-route53==0.35.1

VOLUME ["/etc/letsencrypt"]

CMD ["/entrypoint.sh"]
