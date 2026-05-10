#!/bin/bash
apt-get update -y
apt-get install -y build-essential linux-headers-$(uname -r) xinit i3 terminator vim usbutils screen hostapd dnsmasq iw

################################# CONFIG WIFI
echo "mac80211_hwsim" > /etc/modules-load.d/hwsim.conf
echo "options mac80211_hwsim radios=1" > /etc/modprobe.d/hwsim.conf



mkdir -p /etc/hostapd

echo "interface=wlan0
hw_mode=g # a for 2.4 GHz
channel=10 # or 36
ieee80211d=1
country_code=FR
ieee80211n=1
wmm_enabled=1
ssid=test
auth_algs=1
wpa=2
rsn_pairwise=CCMP
wpa_key_mgmt=WPA-EAP
ieee8021x=1
own_ip_addr=192.168.2.254 # IP of access point
auth_server_addr=127.0.0.1 # IP of radius server
auth_server_port=1812
auth_server_shared_secret=un_vrai_secret_ici
ignore_broadcast_ssid=0" > /etc/hostapd/hostapd_eap.conf

chown root:root /etc/hostapd/hostapd.conf
chmod 700 /etc/hostapd/hostapd.conf

systemctl unmask hostapd
systemctl enable hostapd


############################### CONFIG DHCP
echo "interface=wlan0" >> /etc/dnsmasq.conf
    echo "dhcp-range=10.20.30.100,10.20.30.200,12h" >> /etc/dnsmasq.conf
echo >> /etc/dnsmasq.conf

##################
        
ip addr add 10.20.30.254/24 dev wlan0
ip addr add 192.168.2.254/24 dev enp0s9
ip link set enp0s9 up
mkdir /mnt/shared
mount -t vboxsf shared /mnt/shared
python3 /mnt/shared/hwsim_relay.py --peer 192.168.2.253
