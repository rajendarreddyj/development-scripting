#! /bin/bash
# a key generator for https,

basename=server
key_algorithm=RSA
password_key=123456
password_store=123456
country=US

# clean - pre
rm "${basename}.jks"

# generate server side
keytool -genkeypair -alias "${basename}cert" -keyalg $key_algorithm -dname "CN=Web Server,OU=Unit,O=Organization,L=City,S=State,C=${country}" -keypass $password_key -keystore "${basename}.jks" -storepass $password_store
