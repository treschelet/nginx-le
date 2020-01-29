#!/bin/sh

# scripts is trying to renew certificate only if close (30 days) to expiration

if [ "$LETSENCRYPT" != "true" ]; then
    echo "letsencrypt disabled"
    return 1
fi

# 30 days
renew_before=2592000

# Support multiple fqdn
while read -r fqdn; do
  eval LE_FQDN="\$$fqdn"
  FIRST_FQDN=$(echo "${LE_FQDN}" | cut -d"," -f1)
  echo "Adding fqdn ${FIRST_FQDN}"

  target_cert=/etc/letsencrypt/live/${FIRST_FQDN}/fullchain.pem

  # redirection to /dev/null to remove "Certificate will not expire" output
  if [ -f ${target_cert} ] && openssl x509 -checkend ${renew_before} -noout -in ${target_cert} > /dev/null ; then
      # egrep to remove leading whitespaces
      CERT_FQDNS=$(openssl x509 -in ${target_cert} -text -noout | egrep -o 'DNS.*')
      # run and catch exit code separately because couldn't embed $@ into `if` line properly
      set -- $(echo ${LE_FQDN} | tr ',' '\n'); for element in "$@"; do echo ${CERT_FQDNS} | grep -q $element ; done
      CHECK_RESULT=$?
      if [ ${CHECK_RESULT} -eq 0 ] ; then
          echo "letsencrypt certificate ${target_cert} still valid"
          continue
      else
          echo "letsencrypt certificate ${target_cert} is present, but doesn't contain expected domains"
          echo "expected: ${LE_FQDN}"
          echo "found:    ${CERT_FQDNS}"
      fi
  fi

  echo "letsencrypt certificate will expire soon or missing, renewing..."
  if [ ${DNS} != "true" ]; then
    certbot certonly -t -n --agree-tos --renew-by-default --email "${LE_EMAIL}" --webroot -w /usr/share/nginx/html -d ${LE_FQDN}
  else
    certbot certonly -t -n --agree-tos --renew-by-default \
      --server https://acme-v02.api.letsencrypt.org/directory \
      --email "${LE_EMAIL}" \
      --dns-${DNS_PROVIDER} \
      --dns-${DNS_PROVIDER}-credentials ${DNS_CREDENTIALS} \
      --dns-${DNS_PROVIDER}-propagation-seconds ${DNS_PROPAGATION} \
      -d ${LE_FQDN}
  fi
  le_result=$?
  if [ ${le_result} -ne 0 ]; then
      echo "failed to run certbot for ${LE_FQDN}"
      continue
  fi
done <<EOF
$(env | grep "LE_FQDN_" | sed 's/^\(LE_FQDN_[a-zA-Z0-9]*\)=.*/\1/')
EOF

return 0
