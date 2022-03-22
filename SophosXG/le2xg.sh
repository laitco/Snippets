#!/bin/bash
#Copy from https://github.com/mmccarn/sophos
# router address and port as seen from the system running Letsencrypt
ROUTER=IP-ADRESS:4444

# the system where the LetsEncrypt is running
#
# 1. the 'admin' account has full api access,
#    or you can create a dedicated api user
# 2. 'api' access must be enabled at
#    Administration -> Backup & Firmware -> API
#      - Enable 'API Configuration'
#      - enter the IP addresses that should be allowed to access the API
APIUSER=api-acme
APIPLAINPASS=PASSWORD

# Complete path to xgxml.txt
XML=./xgxml.txt

# Letsencrypt domain
# look in /etc/letsencrypt/live
LEDOMAIN=DOMAIN.de

# Letsencrypt CertificateAuthority
# CA will be created in Sophos as ${LECertAuth}-yyyymmdd
LECertAuth=LetsEncrypt-CA

# cert date
CERTDATE=$(find /root/.acme.sh/${LEDOMAIN}_ecc/${LEDOMAIN}.key -printf "%CY%Cm%Cd\n")

# XG Operation
#     add: this must be used once to initiate the certificate on the XG
#  update: this is used for updating the cert once it has been created
OPERATION=${1:-add}

# Overview -
# 1. copy & rename letsencrypt 'privkey.pem' to 'privkey.key'
# 2. replace placeholder variables in 'xgxml.txt' with values above
# 3. feed the result to curl
#    - listing the 3 files to be uploaded in the order they occur in the input
# 4. Delete the copy of privkey.pem that was created

cp /root/.acme.sh/${LEDOMAIN}_ecc/${LEDOMAIN}.key ./privkey.key
cp /root/.acme.sh/${LEDOMAIN}_ecc/ca.cer ./chain.pem
cp /root/.acme.sh/${LEDOMAIN}_ecc/fullchain.cer ./fullchain.pem


sed \
  -e "s/APIUSER/$APIUSER/" \
  -e "s/APIPLAINPASS/$APIPLAINPASS/" \
  -e "s/OPERATION/$OPERATION/" \
  -e "s/LEDOMAIN/$LEDOMAIN-$CERTDATE/" \
  -e "s/LECertAuth/$LECertAuth-$CERTDATE/" /root/.le/xgxml.txt \
| curl -k -F "reqxml=<-" \
  -F file=@./chain.pem \
  -F file=@./fullchain.pem \
  -F file=@./privkey.key \
  "https://$ROUTER/webconsole/APIController?"

 rm ./privkey.key
 rm ./chain.pem
 rm ./fullchain.pem
