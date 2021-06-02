#!/bin/bash

base64var() {
    printf "$1" | base64stream
}

base64stream() {
    base64 | tr '/+' '_-' | tr -d '=\n'
}

valid_for_sec="${3:-3600}"
private_key=$(echo $KEY_FILE_CONTENT | base64 -d | jq -r .private_key)
sa_email=$(echo $KEY_FILE_CONTENT | base64 -d | jq -r .client_email)

header='{"alg":"RS256","typ":"JWT"}'
claim=$(cat <<EOF | jq -c
  {
    "iss": "$sa_email",
    "scope": "$SCOPE",
    "aud": "https://www.googleapis.com/oauth2/v4/token",
    "exp": $(($(date +%s) + $valid_for_sec)),
    "iat": $(date +%s)
  }
EOF
)
request_body="$(base64var "$header").$(base64var "$claim")"
signature=$(openssl dgst -sha256 -sign <(echo "$private_key") <(printf "$request_body") | base64stream)

JWT="$request_body.$signature"

curl -s -X POST https://www.googleapis.com/oauth2/v4/token \
    --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
    --data-urlencode "assertion=$JWT" \
    | jq -r .access_token
