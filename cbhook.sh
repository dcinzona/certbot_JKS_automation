#!/bin/bash
JSONDATA="{ \"input\" : \"$CERTBOT_VALIDATION\" }"
RESPONSE=$(curl -s \
    -X PUT "https://$CERTBOT_DOMAIN/services/apexrest/Certbot/v1/updateValidation" \
    -H "Content-Type: application/json" \
    -d "$JSONDATA" )