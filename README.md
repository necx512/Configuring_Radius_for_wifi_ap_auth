# Configuring_Radius_for_wifi_ap_auth

# Quick test without hostapd
1. Start freeradius : `freeradis -X`
2. From another terminal run `eapol_test -c eapol_test.conf -a 127.0.0.1 -s un_vrai_secret_ici`. Or `hostapd -d /etc/hostapd/hostapd.conf`

# Quick test with hostapd
1. Start freeradius : `freeradius -X`
2. `hostapd -d /etc/hostapd/hostapd.conf`

In this case, hostapd can looks like:

```ini
# --- Interface ---
interface=wlan0
driver=nl80211
ssid=testwifi
hw_mode=a # 2.4GhZ
channel=36
country_code=FR

# --- 802.11n/ac ---
ieee80211n=1
ieee80211ac=1
wmm_enabled=1

# --- WPA-EAP ---
wpa=2
wpa_key_mgmt=WPA-EAP
wpa_pairwise=CCMP
rsn_pairwise=CCMP

# --- 802.1X / RADIUS ---
ieee8021x=1
auth_algs=1
own_ip_addr=192.168.1.1 # AP IP

auth_server_addr=127.0.0.1      # FreeRADIUS IP if on the same server
auth_server_port=1812
auth_server_shared_secret=secretpass

acct_server_addr=127.0.0.1
acct_server_port=1813
acct_server_shared_secret=secretpass

# --- PMKSA for quick reconnect ---
disable_pmksa_caching=0
okc=1
```

---

# Complete Path (wifi client + hostapd + radius).
Once radius and hostapd is working properly. One can connect to the wifi

## Linux
`/etc/wpa_supplicant/wpa_supplicant.conf` :

```text
network={
    ssid="testwifi"
    key_mgmt=WPA-EAP
    eap=TLS
    identity="laptop-seb"
    ca_cert="/etc/ssl/wifi/ca.pem"
    client_cert="/etc/ssl/wifi/client-laptop.pem"
    private_key="/etc/ssl/wifi/client-laptop.key"
    private_key_passwd=""
}
```

## Android/iOS
- import the `.p12` and ca.pem file
- select EAP-TLS

# OCSP
openssl.cnf has to be copied in /etc/freeradius/certs

# TODO
- deploy CRL or OCSP for client revocation
- use `check_cert_cn`
- use SAE (WPA3) with `wpa_key_mgmt=WPA-EAP WPA-EAP-SHA256` for 802.11w (PMF)
