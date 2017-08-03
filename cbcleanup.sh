#!/bin/bash

CERTBOT_DOMAIN="$CERTBOT_DOMAIN" RENEWED_LINEAGE="./config/live/$CERTBOT_DOMAIN" ./makeJKS.sh > /dev/null 2>&1 &