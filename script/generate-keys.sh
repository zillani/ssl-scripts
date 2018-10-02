 #!/bin/bash

#Create Server key (keystore)
keytool -genkey -v -alias tomcat -keyalg RSA -validity 3650 -keystore tomcat.keystore -dname "CN=flicsdb.com, OU=Developer, O=Flicsdb, L=Hyderabad, ST=Telengana, C=IN" -storepass changeit -keypass changeit

#Create Client key
keytool -genkey -v -alias clientkey -keyalg RSA -storetype PKCS12 -keystore client.p12 -dname "CN=flicsdb.com, OU=Developer, O=Flicsdb, L=Hyderabad, ST=Telengana, C=IN" -storepass changeit -keypass changeit

#Export Client to Server keystore
keytool -export -alias clientkey -keystore client.p12 -storetype PKCS12 -storepass changeit -rfc -file client.cer

keytool -import -v -file client.cer -keystore tomcat.keystore -storepass changeit -alias clientkey

#Convert Client key to pem format (Single file)
openssl pkcs12 -in client.p12 -out client.pem

#Convert Client key to pem format (Seperate key & cert)
openssl pkcs12 -in client.p12 -out client-cert.pem -clcerts -nokeys

openssl pkcs12 -in client.p12 -out client-key.pem -nocerts -nodes

#Convert PEM to PKCS8 format
openssl pkcs8 -in client-key.pem -topk8 -nocrypt -out client-key.pk8

#Remove Passphrase from key
openssl rsa -in client-key.pem -out client-nokey.pem

#Encode pem key to base64 string
openssl base64 -in client.pem -out client-base64.pem

#Decode base64 stringhttps://packages.debian.org/jessie/amd64/libavutil54/download
echo "MIIjXc..." |base64 --decode

#Convert JKS to PKCS12 format
keytool -importkeystore -srckeystore tomcat.keystore -destkeystore tomcat.p12 -srcstoretype jks -deststoretype pkcs12

#Convert JKS to Cer format
keytool -exportcert -rfc -alias mycert -file mycert.cer -keystore tomcat.jks -storepass changeit

#Convert PKCS12 TO PEM format
openssl pkcs12 -in tomcat.p12 -out tomcat.pem

#Convert cer to PEM format
openssl x509 -in certificate.cer -out certificate.pem

#Tomcat config Server.xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
     maxThreads="150" scheme="https" secure="true"
     keystoreFile="/opt/tomcat/conf/keys/tomcat.keystore" keystorePass="changeit"
     truststoreFile="/opt/tomcat/conf/keys/tomcat.keystore" truststorePass="changeit"
     clientAuth="true" sslProtocol="TLS" />
#Tomcat config tomcat-user.xml
<user username="CN=flicsdb.com, OU=Developer, O=Flicsdb, L=Hyderabad, S=Telengana, C=IN" password="null" roles="admin" />

#Curl with cert & key
curl -vk https://flicsdb.com:8443 -E ./client-cert.pem --key ./client-key.pem

#Curl skipping server validation
curl -vk https://flicsdb.com:8443 --cert client.pem

#Curl with server validation
curl -v https://flicsdb.com:8443 -E ./client-cert.pem --key ./client-key.pem --cacert tomcat.pem

#view commonname in cert
openssl x509 -noout -subject -in tomcat.pem


