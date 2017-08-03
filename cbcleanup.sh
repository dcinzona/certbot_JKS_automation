#!/bin/bash

CERTBOT_DOMAIN="$CERTBOT_DOMAIN" \
    RENEWED_LINEAGE="./config/live/$CERTBOT_DOMAIN" \
    ./makeJKS.sh > ./$CERTBOT_DOMAIN.jks.log 2>&1 &