#!/bin/bash

echo "WARNING. This script generates keys and certificates for CA, the server(FreeRadius) and the client. This is only for testing. In real world,
each keys have to be generated separately"


# --- CA ---
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -subj "/C=FR/ST=Cantal/O=HomeLab/CN=WiFi-CA" \
  -out ca.pem

# --- Certificat serveur (FreeRADIUS) ---
openssl genrsa -out server.key 2048
openssl req -new -key server.key \
  -subj "/C=FR/ST=Cantal/O=HomeLab/CN=radius.local" \
  -out server.csr
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key \
  -CAcreateserial -sha256 -days 1825 \
  -out server.pem

# --- Diffie-Hellman (requis par FreeRADIUS) ---
openssl dhparam -out dh.pem 2048

# --- Certificat client (1 par device) ---
openssl genrsa -out client-laptop.key 2048
openssl req -new -key client-laptop.key \
  -subj "/C=FR/ST=Cantal/O=HomeLab/CN=laptop-seb" \
  -out client-laptop.csr
openssl x509 -req -in client-laptop.csr -CA ca.pem -CAkey ca.key \
  -CAcreateserial -sha256 -days 730 \
  -out client-laptop.pem

# Optionnel : bundle PKCS#12 pour import facile sur les clients
openssl pkcs12 -export -out client-laptop.p12 \
  -inkey client-laptop.key -in client-laptop.pem -certfile ca.pem \
  -passout pass:changeme
