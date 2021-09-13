#!/bin/bash

set -x 

WORKDIR='/app'

generate_password () {
    local pass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-12} | head -n 1`
    echo "$pass"
}

generate_certs () {
    # Create random password
    TLS_STORE_PASS=$(generate_password)

    # Generate root CA
    openssl genrsa -out $WORKDIR/rootCA.key 2048
    openssl req -x509 -new -nodes -key $WORKDIR/rootCA.key -sha256 -days 3650 -out $WORKDIR/rootCA.pem -config openssl.conf

    # jas tls
    openssl genrsa -out $WORKDIR/jas.key 2048
    openssl req -new -key $WORKDIR/jas.key -out $WORKDIR/jas.csr -config $WORKDIR/openssl-jas.conf
    openssl x509 -req -in $WORKDIR/jas.csr -CA $WORKDIR/rootCA.pem -CAkey $WORKDIR/rootCA.key -CAcreateserial -out $WORKDIR/jas.crt -days 3650 -sha256
    cat $WORKDIR/jas.key $WORKDIR/jas.crt > $WORKDIR/jas.pem

    keytool -genkeypair -keyalg RSA -alias jasnodekey -keystore $WORKDIR/jas-client-keystore.jks -storepass $TLS_STORE_PASS  -keypass $TLS_STORE_PASS -validity 3650 -keysize 2048 -dname "CN=jasnode, OU=jascluster, O=YourCompany, C=US"
    keytool -list -keystore $WORKDIR/jas-client-keystore.jks -storepass $TLS_STORE_PASS
    keytool -certreq -keystore $WORKDIR/jas-client-keystore.jks -alias jasnodekey  -file $WORKDIR/jasnodekey.csr  -keypass $TLS_STORE_PASS  -storepass $TLS_STORE_PASS -dname "CN=jasnode, OU=TestCluster, O=YourCompany, C=US"
    openssl x509 -req -CA $WORKDIR/rootCA.pem -CAkey $WORKDIR/rootCA.key -in $WORKDIR/jasnodekey.csr -out $WORKDIR/jasnodekey.crt_signed -days 3650 -CAcreateserial -passin pass:$TLS_STORE_PASS
    openssl verify -CAfile $WORKDIR/rootCA.pem $WORKDIR/jasnodekey.crt_signed

    keytool -importcert -keystore $WORKDIR/jas-client-keystore.jks -alias rootCa -file $WORKDIR/rootCA.pem -noprompt  -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS
    keytool -importcert -keystore $WORKDIR/jas-client-keystore.jks -alias $WORKDIR/jasnodekey -file $WORKDIR/jasnodekey.crt_signed -noprompt  -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS
    keytool -importcert -keystore $WORKDIR/jas-server-truststore.jks -alias rootCa -file $WORKDIR/rootCA.pem -noprompt -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS

    # jwt
    openssl genpkey -out $WORKDIR/jwtprivate.pem -algorithm RSA -pkeyopt rsa_keygen_bits:2048
    openssl rsa -in $WORKDIR/jwtprivate.pem -outform PEM -pubout -out $WORKDIR/jwtpublic.pem
    python3 convertPEMtoJson.py

    #signature
    generate_password > $WORKDIR/signaturesecret.txt
    echo 'TLS_STORE_PASS: ' $TLS_STORE_PASS

    # nginx / ingress
    openssl genrsa -out $WORKDIR/ingress-key.pem 2048
    openssl req -new -key $WORKDIR/ingress-key.pem -out $WORKDIR/ingress.csr -config $WORKDIR/openssl-ingress.conf
    openssl x509 -req -in $WORKDIR/ingress.csr -CA $WORKDIR/rootCA.pem -CAkey $WORKDIR/rootCA.key -CAcreateserial -out $WORKDIR/ingress-cert.pem -days 3650 -sha256

    # openidm-localhost
    openssl genrsa -out $WORKDIR/openidm-localhost.key 2048

    openssl req -new \
    -key $WORKDIR/openidm-localhost.key \
    -out $WORKDIR/openidm-localhost.csr \
    -config $WORKDIR/openssl-openidm.conf
    
    openssl x509 -req \
    -in $WORKDIR/openidm-localhost.csr \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -CAcreateserial \
    -out $WORKDIR/openidm-localhost.crt -days 3650 -sha256
    
    cat $WORKDIR/openidm-localhost.key \
    $WORKDIR/openidm-localhost.crt > $WORKDIR/openidm-localhost.pem

    keytool -genkeypair \
    -keyalg RSA -alias openidm-localhost \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storepass $TLS_STORE_PASS \
    -keypass $TLS_STORE_PASS \
    -storetype jceks \
    -validity 3650 \
    -keysize 2048 \
    -dname "CN=openidm, OU=openidmcluster, O=YourCompany, C=US"
    
    keytool -certreq \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -alias openidm-localhost \
    -file $WORKDIR/openidm-localhost.csr \
    -keypass $TLS_STORE_PASS \
    -storepass $TLS_STORE_PASS \
    -storetype jceks \
    -dname "CN=openidm, OU=openidmcluster, O=YourCompany, C=US"
    
    openssl x509 -req \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -in $WORKDIR/openidm-localhost.csr \
    -out $WORKDIR/openidm-localhost.crt_signed \
    -days 3650 \
    -CAcreateserial \
    -passin pass:$TLS_STORE_PASS
    
    openssl verify -CAfile $WORKDIR/rootCA.pem \
    $WORKDIR/openidm-localhost.crt_signed

    echo "selfservice"

    # selfservice
    openssl genrsa -out $WORKDIR/selfservice.key 2048
    
    openssl req -new \
    -key $WORKDIR/selfservice.key \
    -out $WORKDIR/selfservice.csr \
    -config $WORKDIR/openssl-selfservice.conf
    
    openssl x509 -req \
    -in $WORKDIR/selfservice.csr \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -CAcreateserial \
    -out $WORKDIR/selfservice.crt -days 3650 -sha256
    
    cat $WORKDIR/selfservice.key \
    $WORKDIR/selfservice.crt > $WORKDIR/selfservice.pem

    keytool -genkeypair \
    -keyalg RSA -alias selfservice \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storepass $TLS_STORE_PASS \
    -keypass $TLS_STORE_PASS \
    -validity 3650 \
    -keysize 2048 \
    -dname "CN=selfservice, OU=openidmcluster, O=YourCompany, C=US"
    
    keytool -certreq \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -alias selfservice \
    -file $WORKDIR/selfservice.csr \
    -keypass $TLS_STORE_PASS \
    -storepass $TLS_STORE_PASS \
    -dname "CN=selfservice, OU=openidmcluster, O=YourCompany, C=US"
    
    openssl x509 -req \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -in $WORKDIR/selfservice.csr \
    -out $WORKDIR/selfservice.crt_signed \
    -days 3650 \
    -CAcreateserial \
    -passin pass:$TLS_STORE_PASS
    
    openssl verify -CAfile $WORKDIR/rootCA.pem \
    $WORKDIR/selfservice.crt_signed

    echo "servercert"
    # servercert
    openssl genrsa -out $WORKDIR/servercert.key 2048

    openssl req -new \
    -key $WORKDIR/servercert.key \
    -out $WORKDIR/servercert.csr \
    -config $WORKDIR/openssl-servercert.conf
    
    openssl x509 -req \
    -in $WORKDIR/servercert.csr \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -CAcreateserial \
    -out $WORKDIR/servercert.crt -days 3650 -sha256
    
    cat $WORKDIR/servercert.key \
    $WORKDIR/servercert.crt > $WORKDIR/servercert.pem

    keytool -genkeypair \
    -keyalg RSA \
    -alias servercert \
    -storepass $TLS_STORE_PASS \
    -keypass $TLS_STORE_PASS \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -validity 3650 \
    -keysize 2048 \
    -dname "CN=servercert, OU=openidmcluster, O=YourCompany, C=US"
    
    keytool -certreq \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -alias servercert \
    -file $WORKDIR/servercert.csr \
    -keypass $TLS_STORE_PASS \
    -storepass $TLS_STORE_PASS \
    -dname "CN=servercert, OU=openidmcluster, O=YourCompany, C=US"
    
    openssl x509 -req \
    -CA $WORKDIR/rootCA.pem \
    -CAkey $WORKDIR/rootCA.key \
    -in $WORKDIR/servercert.csr \
    -out $WORKDIR/servercert.crt_signed \
    -days 3650 \
    -CAcreateserial \
    -passin pass:$TLS_STORE_PASS
    
    openssl verify -CAfile $WORKDIR/rootCA.pem \
    $WORKDIR/servercert.crt_signed

    # openidm-sym-default 
    keytool -genseckey \
    -alias openidm-sym-default \
    -storepass $TLS_STORE_PASS \
    -keypass $TLS_STORE_PASS \
    -keyalg AES \
    -keysize 128 \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storetype jceks

    # openidm-jwtsessionhmac-key
    keytool -genseckey \
    -alias openidm-jwtsessionhmac-key \
    -keyalg HmacSHA256 \
    -keypass $TLS_STORE_PASS \
    -keysize 256 \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storepass $TLS_STORE_PASS \
    -storetype jceks

    # openidm-selfservice-key
    keytool -genseckey \
    -alias openidm-selfservice-key \
    -keyalg AES \
    -keypass $TLS_STORE_PASS \
    -keysize 128 \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storepass $TLS_STORE_PASS \
    -storetype jceks

    keytool -importcert -keystore $WORKDIR/openidm-client-keystore.jks -alias openidm-localhost -file $WORKDIR/openidm-localhost.crt_signed -noprompt  -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS
    keytool -importcert -keystore $WORKDIR/openidm-client-keystore.jks -alias selfservice -file $WORKDIR/selfservice.crt_signed -noprompt  -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS
    keytool -importcert -keystore $WORKDIR/openidm-client-keystore.jks -alias servercert -file $WORKDIR/servercert.crt_signed -noprompt  -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS

    keytool -importcert -keystore $WORKDIR/openidm-server-truststore.jks -alias rootCa -file $WORKDIR/rootCA.pem -noprompt -keypass $TLS_STORE_PASS -storepass $TLS_STORE_PASS

    keytool -list \
    -keystore $WORKDIR/openidm-client-keystore.jks \
    -storepass $TLS_STORE_PASS
}

create_certs() {
    kubectl create secret generic iga-api-jas-certs \
    --from-file=$WORKDIR/rootCA.pem

    kubectl create secret generic jasnode-tls-certs \
    --from-file=$WORKDIR/jas-client-keystore.jks \
    --from-file=$WORKDIR/jas-server-truststore.jks

    kubectl create secret generic jasnode-signature \
    --from-file=$WORKDIR/signaturesecret.txt

    kubectl create secret generic api-jwt-certs \
    --from-file=$WORKDIR/jwtprivate.pem \
    --from-file=$WORKDIR/jwtpublic.pem \
    --from-file=$WORKDIR/verify-key.json

    kubectl create secret generic nginx-certs \
    --from-file=$WORKDIR/ingress-cert.pem \
    --from-file=$WORKDIR/ingress-key.pem

    kubectl create secret generic idm-secrets \
    --from-file=$WORKDIR/openidm-client-keystore.jks \
    --from-file=$WORKDIR/openidm-server-truststore.jks
}

generate_certs
create_certs


