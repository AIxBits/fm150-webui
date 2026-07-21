#!/bin/bash
# Standalone installer for Fibocom FM150-AE/NA-01.  It does not use, update,
# or require Quectel WebUI, Entware, lighttpd, or OPKG.
set -eu

BASE_URL=${FM150_WEBUI_BASE_URL:-https://raw.githubusercontent.com/AIxBits/fm150-webui/main}
PREFIX=${FM150_WEBUI_PREFIX:-/usrdata/fm150-webui}
WEB_ROOT="$PREFIX/www"
BRIDGE=/usrdata/socat-at-bridge
UNIT_DIR=/etc/systemd/system

[ "$(id -u)" = 0 ] || { echo 'Run as root.' >&2; exit 1; }

download() {
    local source="$1" target="$2" temp="${target}.new"
    mkdir -p "$(dirname "$target")"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$BASE_URL/$source" -o "$temp"
    else
        wget -qO "$temp" "$BASE_URL/$source"
    fi
    [ -s "$temp" ] || { echo "Empty download: $source" >&2; exit 1; }
    mv "$temp" "$target"
}

echo 'Installing FM150 WebUI files…'
for page in index network scanner settings sms fm150 deviceinfo; do
    download "simpleadmin/www/$page.html" "$WEB_ROOT/$page.html"
done
for asset in css/bootstrap.min.css css/styles.css js/bootstrap.bundle.min.js js/alpinejs.min.js js/dark-mode.js js/i18n/en.js js/i18n/zh.js js/i18n/language-manager.js favicon.ico; do
    download "simpleadmin/www/$asset" "$WEB_ROOT/$asset"
done
for cgi in fm150_at get_atcommand get_uptime send_sms; do
    download "simpleadmin/www/cgi-bin/$cgi" "$WEB_ROOT/cgi-bin/$cgi"
done
chmod 0755 "$WEB_ROOT/cgi-bin"/*
chmod 0644 "$WEB_ROOT"/*.html "$WEB_ROOT"/css/* "$WEB_ROOT"/js/*.js "$WEB_ROOT"/js/i18n/*.js "$WEB_ROOT/favicon.ico"

echo 'Installing FM150 smd9 AT bridge…'
download socat-at-bridge/atcmd11 "$BRIDGE/atcmd11"
download socat-at-bridge/socat-armel-static "$BRIDGE/socat-armel-static"
chmod 0755 "$BRIDGE/atcmd11" "$BRIDGE/socat-armel-static"
for unit in socat-smd9.service socat-smd9-to-ttyIN.service socat-smd9-from-ttyIN.service; do
    download "socat-at-bridge/systemd_units/$unit" "$UNIT_DIR/$unit"
done

download deploy/start-httpd "$PREFIX/bin/start-httpd"
download deploy/systemd/fm150-webui.service "$UNIT_DIR/fm150-webui.service"
chmod 0755 "$PREFIX/bin/start-httpd"

systemctl daemon-reload
systemctl enable socat-smd9.service socat-smd9-to-ttyIN.service socat-smd9-from-ttyIN.service fm150-webui.service
systemctl restart socat-smd9.service
sleep 2
systemctl restart socat-smd9-to-ttyIN.service socat-smd9-from-ttyIN.service fm150-webui.service

IP=$(ip -4 addr show bridge0 2>/dev/null | awk '/inet / {sub(/\/.*/, "", $2); print $2; exit}')
[ -n "$IP" ] || IP='<module-ip>'
echo "Installed. Open: http://$IP:8080/"
echo "AT test: $BRIDGE/atcmd11 'AT+CPIN?'"
