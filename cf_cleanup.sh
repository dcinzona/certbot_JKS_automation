#!/bin/bash

source cf_config.sh
API_KEY=$CF_API_KEY
EMAIL=$CF_EMAIL

CFAPI="https://api.cloudflare.com/client/v4/zones"

if [ -f tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID ]; then
        ZONE_ID=$(cat tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID)
fi

if [ -f tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID ]; then
        RECORD_ID=$(cat tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID)
fi

if [ -d tmp/CERTBOT_$CERTBOT_DOMAIN ]; then
        rm -rf tmp/CERTBOT_$CERTBOT_DOMAIN
fi

# Remove the challenge TXT record from the zone
if [ -n "${ZONE_ID}" ]; then
    if [ -n "${RECORD_ID}" ]; then
        curl -s -X DELETE "$CFAPI/$ZONE_ID/dns_records/$RECORD_ID" \
                -H "X-Auth-Email: $EMAIL" \
                -H "X-Auth-Key: $API_KEY" \
                -H "Content-Type: application/json"
    fi
fi

CERTBOT_DOMAIN="$CERTBOT_DOMAIN" RENEWED_LINEAGE="./config/live/$CERTBOT_DOMAIN" ./makeJKS.sh > /dev/null 2>&1 &