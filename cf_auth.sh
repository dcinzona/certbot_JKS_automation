#!/bin/bash
# requires (python or jq) and curl
# brew install jq
#https://certbot.eff.org/docs/using.html#pre-and-post-validation-hooks

# Get your API key from https://www.cloudflare.com/a/profile
API_KEY="your-cloudflare-api-key"
EMAIL="your-cloudflare-email"
CFAPI="https://api.cloudflare.com/client/v4/zones"

# Strip only the top domain to get the zone id
DOMAIN=$(expr "$CERTBOT_DOMAIN" : '.*\.\(.*\..*\)')

# Get the Cloudflare zone id
ZONE_EXTRA_PARAMS="status=active&page=1&per_page=20&order=status&direction=desc&match=all"
ZONE_ID=$(curl -s -X GET "$CFAPI?name=$DOMAIN&$ZONE_EXTRA_PARAMS" \
     -H     "X-Auth-Email: $EMAIL" \
     -H     "X-Auth-Key: $API_KEY" \
     -H     "Content-Type: application/json" \
            | python -c "import sys,json;print(json.load(sys.stdin)['result'][0]['id'])")
            # | jq -r '.result[].id')

# Create TXT record
CREATE_DOMAIN="_acme-challenge.$CERTBOT_DOMAIN"
JSONDATA=$(cat <<EOF
{
        "type":"TXT",
        "name":"$CREATE_DOMAIN",
        "content":"$CERTBOT_VALIDATION",
        "ttl":120
}
EOF
)
echo $JSONDATA
RECORD_ID=$(curl -s -X POST "$CFAPI/$ZONE_ID/dns_records" \
     -H     "X-Auth-Email: $EMAIL" \
     -H     "X-Auth-Key: $API_KEY" \
     -H     "Content-Type: application/json" \
     -d     "$JSONDATA" \
        | python -c "import sys,json;print(json.load(sys.stdin)['result']['id'])")

# Save info for cleanup
if [ ! -d tmp ];then
        mkdir -m 0700 tmp
fi
if [ ! -d tmp/CERTBOT_$CERTBOT_DOMAIN ];then
        mkdir -m 0700 tmp/CERTBOT_$CERTBOT_DOMAIN
fi
echo $ZONE_ID > tmp/CERTBOT_$CERTBOT_DOMAIN/ZONE_ID
echo $RECORD_ID > tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID

# Sleep to make sure the change has time to propagate over to DNS
sleep 25