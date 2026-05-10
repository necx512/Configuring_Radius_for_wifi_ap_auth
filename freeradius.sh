#!/bin/bash
apt-get update -y
apt-get install -y build-essential linux-headers-$(uname -r) xinit i3 terminator vim usbutils screen iw freeradius freeradius-utils libssl-dev libdbus-1-dev libnl-3-dev libnl-genl-3-dev pkg-config libnl-route-3-dev
systemctl disable freeradius



echo 'eap {
    default_eap_type = tls
    timer_expire = 60
    ignore_unknown_eap_types = no
    cisco_accounting_username_bug = no
    max_sessions = ${max_requests}

    tls-config tls-common {
        private_key_password =
        private_key_file = /etc/freeradius/certs/server.key
        certificate_file = /etc/freeradius/certs/server.pem
        ca_file = /etc/freeradius/certs/ca.pem
        dh_file = /etc/freeradius/certs/dh.pem
        #ca_path = ${cadir}

        # Versions TLS minimales
        tls_min_version = "1.2"
        tls_max_version = "1.3"

        cipher_list = "HIGH:!aNULL:!MD5:!RC4"

        # Check client certificat
        check_cert_cn = "%{User-Name}"

        # CRL
        # check_crl = yes
        # ca_path_reload_interval = 300
    }

    tls {
        tls = tls-common
    }
}' > /etc/freeradius/3.0/mods-enabled/eap


echo "server default {
    listen {
        type = auth
        ipaddr = *
        port = 1812
    }

    listen {
        type = acct
        ipaddr = *
        port = 1813
    }

    authorize {
        filter_username
        eap {
            ok = return
        }
    }

    authenticate {
        eap
    }

    post-auth {
        Post-Auth-Type REJECT {
            attr_filter.access_reject
        }
    }
}" > /etc/freeradius/3.0/sites-enabled/default


echo "client ap-wifi {
    ipaddr = 192.168.2.254        # IP of AP if different of radius
    secret = un_vrai_secret_ici  # shared secret RADIUS
    require_message_authenticator = yes
    shortname = ap-wifi
}
client localhost-test {
    ipaddr = 127.0.0.1 # IP of AP if it is the same as radius
    secret = un_vrai_secret_ici
    shortname = test
}

" > /etc/freeradius/3.0/clients.conf

# The following eapol_test.conf is just for testing. Do NOT create it in production

echo "compiling wpasupplicant with eapol_test" > /root/state
mkdir /root/wpasupplicantsrc
cd /root/wpasupplicantsrc
apt source wpasupplicant
cd wpa-*/wpa_supplicant
cp defconfig .config
echo "CONFIG_EAPOL_TEST=y" >> .config
make eapol_test
cp eapol_test /usr/local/bin/

echo 'network={
    ssid="test"
    key_mgmt=WPA-EAP
    eap=TLS
    identity="laptop-seb"
    ca_cert="/etc/freeradius/certs/ca.pem"
    client_cert="/etc/freeradius/certs/client-laptop.pem"
    private_key="/etc/freeradius/certs/client-laptop.key"
    private_key_passwd=""
}' > /root/eapol_test.conf


echo "store server.key, server.pem, ca.pem, dh.pem in /etc/freeradius/certs"
echo "FOR TESTING ONLY : copy client-laptop.key and client-laptop.pem in /etc/freeradius/certs/"
echo "When copy is done, press any key"
read -r presskey

chmod g+r /etc/freeradius/certs/server.key
ip addr add 192.168.2.252/24 dev enp0s9
ip link set enp0s9 up
