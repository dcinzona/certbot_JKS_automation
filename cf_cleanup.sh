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

echo "Creating JKS file..."

CERTPATH="./config/live/$CERTBOT_DOMAIN/"
if [ -d $CERTPATH ]; then
    
    echo "CERTPATH=$CERTPATH"

    FULLCHAIN=$CERTPATH"fullchain.pem"
    KEY=$CERTPATH"privKey.pem"
    if [ -z "$CERTBOT_TOKEN" ]; then
        CERTBOT_TOKEN=$(openssl rand -base64 32)
    fi

    echo "Creating pkcs12 store..."

    openssl pkcs12 -export \
        -in $FULLCHAIN \
        -inkey $KEY \
        -name "certbot_autogen" \
        -out $CERTBOT_DOMAIN.p12 \
        -password "pass:$CERTBOT_TOKEN"
    
    if [ -f $CERTBOT_DOMAIN.jks ]; then
        rm -f $CERTBOT_DOMAIN.jks
    fi

    echo "Creating JKS store..."
    keytool -noprompt \
        -importkeystore \
        -deststorepass $CERTBOT_TOKEN \
        -destkeystore $CERTBOT_DOMAIN.jks \
        -srckeystore $CERTBOT_DOMAIN.p12 \
        -srcstorepass $CERTBOT_TOKEN \
        -srcstoretype PKCS12 > /dev/null 2>&1

    if [ -f $CERTBOT_DOMAIN.p12 ]; then
        rm -f $CERTBOT_DOMAIN.p12
    fi

    echo "JKS PASSWORD=$CERTBOT_TOKEN"

else
    echo "ERROR - Certpath is invalid"
fi
