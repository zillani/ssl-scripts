#!/bin/bash

keytool -genkey -v -alias tomcat -keyalg RSA -validity 36500 -keystore tomcat.keystore -dname "CN=localhost, OU=Developer, O=Flicsdb, L=Hyderabad, ST=Telengana, C=IN" -storepass changeit -keypass changeit


keytool -genkey -v -alias clientkey -keyalg RSA -storetype PKCS12 -keystore client.p12 -dname "CN=localhost, OU=Developer, O=Flicsdb, L=Hyderabad, ST=Telengana, C=IN" -storepass changeit -keypass changeit


keytool -export -alias clientkey -keystore client.p12 -storetype PKCS12 -storepass changeit -rfc -file client.cer

keytool -import -v -file client.cer -keystore tomcat.keystore -storepass changeit -alias clientkey


openssl pkcs12 -in client.p12 -out client.pem


openssl pkcs12 -in client.p12 -out client-cert.pem -clcerts -nokeys

openssl pkcs12 -in client.p12 -out client-key.pem -nocerts -nodes


openssl pkcs8 -in client-key.pem -topk8 -nocrypt -out client-key.pk8


openssl rsa -in client-key.pem -out client-nokey.pem



keytool -importkeystore -srckeystore tomcat.keystore -destkeystore tomcat.p12 -srcstoretype jks -deststoretype pkcs12


keytool -exportcert -rfc -alias mycert -file mycert.cer -keystore tomcat.jks -storepass changeit


openssl pkcs12 -in tomcat.p12 -out tomcat.pem


openssl x509 -in certificate.cer -out certificate.pem


openssl x509 -noout -subject -in tomcat.pem
