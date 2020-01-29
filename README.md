# NGINX-LE - Nginx with autorenew Let's Encrypt certs
Nginx image (alpine based) with integrated Let's Encrypt support.

## Usage
Sample `docker-compose.yml`

```yml
version: '3'

services:
  nginx:
    image: treschelet/nginx-le:latest
    volumes:
      - ./etc/ssl:/etc/nginx/ssl
      - ./etc/service-1.conf:/etc/nginx/service.conf
      # more services, should be service*.conf
      # - ./etc/service-2.conf:/etc/nginx/service2.conf
    ports:
      - "80:80"
      - "443:443"
    environment:
      - TZ=UTC
      - LETSENCRYPT=true
      - LE_EMAIL=name@example.com
      - LE_FQDN_XMPL=www.example.com
      # Multiple certificates
      #- LE_FQDN_TEST=test.example.com
```

## Environment variables
- TZ - TimeZone
- LETSENCRYPT - if `true` enables Let's Encrypt automatic certificate install and renewal
- LE_EMAIL - email for domains
- LE_FQDN_label - domain, for multiple FQDNs you can pass comma-separated list `a.example.com,b.example.com`
- DNS - if `true` uses DNS validation for Let`s Encrypt
- DNS_PROPAGATION - timeout for check DNS txt records
- DNS_PROVIDER - supported provides `cloudflare|cloudxns|digitalocean|dnsimple|dnsmadeeasy|google|linode|luadns|nsone|ovh|rfc2136|route53`
- DNS_CREDENTIALS - path to provider credentials file
