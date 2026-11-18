#!/usr/bin/env bash
# Abre en UFW los puertos que necesita RustDesk Server (hbbs/hbbr).
# Ejecutar en siscom_vps con sudo:  sudo bash firewall-ufw.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta con sudo." >&2
  exit 1
fi

ufw allow 21115:21117/tcp comment 'RustDesk hbbs/hbbr'
ufw allow 21116/udp       comment 'RustDesk hbbs (ID/heartbeat)'
# WebSocket solo para Traefik (red docker "proxy"), no desde Internet.
PROXY_SUBNET="$(docker network inspect proxy --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}')"
ufw allow from "$PROXY_SUBNET" to any port 21118:21119 proto tcp comment 'RustDesk WS via Traefik'
ufw reload
ufw status verbose | grep -E '2111[5-9]' || true

echo
echo "Si el VPS tiene además firewall en el panel de Hostinger, abre ahí los mismos puertos:"
echo "  TCP 21115-21117  y  UDP 21116   (21118-21119 NO: solo los usa Traefik desde dentro)"
