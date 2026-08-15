#!/bin/bash
# SENSI — Create SSH Account (SlowDNS + UDP Custom + WireGuard info)
# No set -e: a failed optional lookup must never abort account creation.
# FIX: removed the old unconditional pkill/restart of sldns that used to
#      disrupt the running tunnel on every account creation.

MYIP=$(wget -qO- ipv4.icanhazip.com 2>/dev/null)
echo "Checking VPS"
clear

cekray=$(cat /root/log-install.txt 2>/dev/null | grep -ow "XRAY" | sort | uniq)
if [ "$cekray" = "XRAY" ]; then
    domen=$(cat /etc/xray/domain 2>/dev/null)
else
    domen=$(cat /etc/v2ray/domain 2>/dev/null)
fi
[ -z "$domen" ] && domen=$(cat /etc/xray/domain 2>/dev/null)

portsshws=$(cat ~/log-install.txt 2>/dev/null | grep -w "SSH Websocket" | cut -d: -f2 | awk '{print $1}')
wsssl=$(cat ~/log-install.txt 2>/dev/null | grep -w "SSH SSL Websocket" | cut -d: -f2 | awk '{print $1}')

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          SENSI SSH Account            \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -p "Username : " Login
read -p "Password : " Pass
read -p "Expired (hari): " masaaktif

IP=$(curl -sS ifconfig.me 2>/dev/null)
opensh=$(cat ~/log-install.txt 2>/dev/null | grep -w "OpenSSH" | cut -f2 -d: | awk '{print $1}')
db=$(cat ~/log-install.txt 2>/dev/null | grep -w "Dropbear" | cut -f2 -d: | awk '{print $1,$2}')
ssl=$(cat ~/log-install.txt 2>/dev/null | grep -w "Stunnel4" | cut -d: -f2)

sleep 1
clear
useradd -e "$(date -d "$masaaktif days" +"%Y-%m-%d")" -s /bin/false -M "$Login" 2>/dev/null
exp=$(chage -l "$Login" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
echo -e "$Pass\n$Pass\n" | passwd "$Login" &> /dev/null

# ── Online connections for this account ──────────────
online_count=$(ps aux | grep -iE "sshd.*$Login|dropbear.*$Login" | grep -v grep | wc -l)

# ── SlowDNS (only if installed) ──────────────────────
ns_domain=$(cat /root/nsdomain 2>/dev/null)
sl_pubkey=$(cat /etc/slowdns/server.pub 2>/dev/null)
sl_ports="2222, 2269"

# ── UDP Custom (only if installed) ───────────────────
udp_listen=$(cat /root/udp/config.json 2>/dev/null | grep -oE '"listen"[[:space:]]*:[[:space:]]*":[0-9]+"' | grep -oE '[0-9]+')
udp_port=${udp_listen:-7200}
udp_str="$domen:$udp_port@$Login:$Pass"

# ── WireGuard (only if installed) ────────────────────
wg_port=$(cat /root/wg-info.conf 2>/dev/null | grep SERVER_PORT | cut -d= -f2)
wg_pub=$(cat /root/wg-info.conf 2>/dev/null | grep SERVER_PUBLIC_KEY | cut -d= -f2)
wg_psk=$(cat /root/wg-info.conf 2>/dev/null | grep PRESHARED_KEY | cut -d= -f2)

{
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          SENSI SSH Account            \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Username    : $Login"
echo -e "Password    : $Pass"
echo -e "Expired On  : $exp"
echo -e "Online Now  : $online_count connection(s)"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "IP          : $IP"
echo -e "Host        : $domen"
echo -e "OpenSSH     : $opensh"
echo -e "SSH WS      : $portsshws"
echo -e "SSH SSL WS  : $wsssl"
echo -e "SSL/TLS     : $ssl"
echo -e "Dropbear    : $db"
echo -e "UDPGW       : 7100-7900"

if [ -n "$ns_domain" ]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          SLOWDNS TUNNEL              \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Nameserver  : $ns_domain"
    echo -e "DNS Ports   : $sl_ports"
    echo -e "PubKey      : $sl_pubkey"
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          UDP CUSTOM (HTTP CUSTOM)     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "UDP Port    : $udp_port"
echo -e "Config      : $udp_str"

if [ -n "$wg_port" ]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[0;41;36m          WIREGUARD VPN                \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "Endpoint    : $IP:$wg_port/udp"
    echo -e "Public Key  : $wg_pub"
    echo -e "Preshared   : $wg_psk"
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[0;41;36m          PAYLOAD TEMPLATES            \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Payload WSS"
echo -e "GET wss://isi_bug_disini HTTP/1.1[crlf]Host: ${domen}[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Payload WS"
echo -e "GET / HTTP/1.1[crlf]Host: $domen[crlf]Upgrade: websocket[crlf][crlf]"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
} | tee -a /etc/log-create-ssh.log

echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-sshovpn
