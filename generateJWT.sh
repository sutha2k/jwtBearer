#!/bin/bash
echo "First input is header: $1"
echo "Second input is payload: $2"
echo "Third input is expiration from now in sec: $3"
echo "Fourth input is the private key: $4"

sed -i "s/.*\"exp\":.*/$(date --date $3' sec' '+  \"exp\": \"%s\"')/g" $2
cat $1 | sed 's/[[:space:]]//g' | tr -d '\n' | tr -d '\r' | base64 | sed s/\+/-/ | sed -E s/=+$// | tr -d '\n' | tr -d '\r' > header.b64
cat $2 | sed 's/[[:space:]]//g' | tr -d '\n' | tr -d '\r' | base64 | sed s/\+/-/ | sed -E s/=+$// | tr -d '\n' | tr -d '\r' > payload.b64
printf "%s" "$(<header.b64)" "." "$(<payload.b64)" | tr -d '\n' | tr -d '\r' > unsigned.b64
rm header.b64
rm payload.b64
cat unsigned.b64 | openssl dgst -sha256 -binary -sign $4 | base64 | tr -d '\n=' | tr -- '+/' '-_' > sig.b64
echo "Here's your JWT assertion: "
printf "%s" "$(<unsigned.b64)" "." "$(<sig.b64)" | tr -d '\n' | tr -d '\r'
rm unsigned.b64
rm sig.b64
