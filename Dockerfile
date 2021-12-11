FROM nginx:1.21.4-alpine

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
 apk add  --update certbot tzdata openssl py3-pip && \
 rm -rf /var/cache/apk/*

#RUN pip3 install --upgrade pip
RUN pip3 install \
    certbot-dns-cloudflare \
    certbot-dns-cloudxns \
    certbot-dns-digitalocean \
    certbot-dns-dnsimple \
    certbot-dns-dnsmadeeasy \
    certbot-dns-google \
    certbot-dns-linode \
    certbot-dns-luadns \
    certbot-dns-nsone \
    certbot-dns-ovh \
    certbot-dns-rfc2136 \
    certbot-dns-route53

VOLUME ["/etc/letsencrypt"]

CMD ["/entrypoint.sh"]
