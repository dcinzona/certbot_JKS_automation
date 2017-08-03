#!/bin/bash

sleep 5
echo "CERTBOT_DOMAIN = $CERTBOT_DOMAIN"
echo "RENEWED_LINEAGE = $RENEWED_LINEAGE"
CERTPATH="$RENEWED_LINEAGE"
if [ -z $CERTPATH ]; then
echo "CERTPATH was blank"
exit 1
fi
if [ -d $CERTPATH ]; then
    echo "Creating JKS file..."
    echo "CERTPATH=$CERTPATH"

    FULLCHAIN=$CERTPATH"/fullchain.pem"
    KEY=$CERTPATH"/privKey.pem"
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
