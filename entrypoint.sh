#!/bin/sh
echo "start nginx"

#set TZ
cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
echo ${TZ} > /etc/timezone && \

mkdir -p /etc/nginx/conf.d
mkdir -p /etc/nginx/ssl

#collect services
SERVICES=$(find "/etc/nginx/" -type f -maxdepth 1 -name "service*.conf")

#copy /etc/nginx/service*.conf if any of service*.conf mounted
if [ ${#SERVICES} -ne 0 ]; then
    cp -fv /etc/nginx/service*.conf /etc/nginx/conf.d/
fi

#replace SSL_KEY, SSL_CERT and SSL_CHAIN_CERT by actual keys
#sed -i "s|SSL_KEY|${SSL_KEY}|g" /etc/nginx/conf.d/*.conf
#sed -i "s|SSL_CERT|${SSL_CERT}|g" /etc/nginx/conf.d/*.conf
#sed -i "s|SSL_CHAIN_CERT|${SSL_CHAIN_CERT}|g" /etc/nginx/conf.d/*.conf

#replace LE_FQDN
#sed -i "s|LE_FQDN|${LE_FQDN}|g" /etc/nginx/conf.d/*.conf

#generate dhparams.pem
if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
    echo "make dhparams"
    cd /etc/nginx/ssl
    openssl dhparam -out dhparams.pem 2048
    chmod 600 dhparams.pem
fi

#disable ssl configuration and let it run without SSL
mv -v /etc/nginx/conf.d /etc/nginx/conf.d.disabled

(
 sleep 5 #give nginx time to start
 echo "start letsencrypt updater"
 while :
 do
    echo "trying to update letsencrypt ..."
    /le.sh
    rm -f /etc/nginx/conf.d/default.conf 2>/dev/null #on the first run remove default config, conflicting on 80
    mv -v /etc/nginx/conf.d.disabled /etc/nginx/conf.d 2>/dev/null #on the first run enable config back
    echo "reload nginx with ssl"
    nginx -s reload
    sleep 1d
 done
) &

nginx -g "daemon off;"
