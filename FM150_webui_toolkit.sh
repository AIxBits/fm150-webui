#!/bin/bash
# FM150 Simple Admin installer and optional smd7/smd9 AT bridge installer.

set -u

ACTION=${1:-install}
BASE_URL=${FM150_WEBUI_BASE_URL:-}
REPO_ROOT=${FM150_REPO_ROOT:-${BASE_URL%/simpleadmin/www}}
WEB_ROOT=/usrdata/simpleadmin/www
CGI_ROOT="$WEB_ROOT/cgi-bin"
INDEX="$WEB_ROOT/index.html"

usage() {
    cat <<'EOF'
Usage:
  FM150_WEBUI_BASE_URL=https://raw.githubusercontent.com/<user>/<repo>/<branch>/simpleadmin/www ./FM150_webui_toolkit.sh [install|update|bridge-install|bridge-uninstall|full-install|uninstall|check]

The source URL must contain fm150.html and cgi-bin/fm150_at.
bridge-install configures ttyOUT2 -> smd7 and ttyOUT -> smd9.
EOF
}

download() {
    local url="$1" destination="$2" tmp="${destination}.new"
    rm -f "$tmp"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$tmp" "$url"
    else
        echo 'ERROR: curl or wget is required.' >&2
        return 1
    fi
    [ -s "$tmp" ] || { echo "ERROR: empty download: $url" >&2; return 1; }
    mv "$tmp" "$destination"
}

restart_web() {
    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet lighttpd 2>/dev/null; then
        systemctl restart lighttpd
    fi
}

check() {
    local bridge=${FM150_AT_BRIDGE:-/usrdata/socat-at-bridge/atcmd}
    echo "Web root: $WEB_ROOT"
    echo "FM150 page: $([ -f "$WEB_ROOT/fm150.html" ] && echo installed || echo missing)"
    echo "FM150 CGI: $([ -x "$CGI_ROOT/fm150_at" ] && echo installed || echo missing)"
    echo "AT bridge: $([ -x "$bridge" ] && echo "$bridge" || echo missing)"
    if command -v systemctl >/dev/null 2>&1; then
        echo "Lighttpd: $(systemctl is-active lighttpd 2>/dev/null || true)"
    fi
}

install() {
    [ "$(id -u)" = 0 ] || { echo 'ERROR: run as root.' >&2; exit 1; }
    [ -n "$BASE_URL" ] || { usage >&2; exit 1; }
    [ -d "$WEB_ROOT" ] || { echo "ERROR: $WEB_ROOT is absent. Install Simple Admin first." >&2; exit 1; }

    mkdir -p "$CGI_ROOT"
    if [ -f "$INDEX" ] && [ ! -f "${INDEX}.fm150.bak" ]; then
        cp "$INDEX" "${INDEX}.fm150.bak"
    fi

    echo 'Downloading FM150 web files...'
    download "$BASE_URL/fm150.html" "$WEB_ROOT/fm150.html"
    download "$BASE_URL/cgi-bin/fm150_at" "$CGI_ROOT/fm150_at"
    chmod 0755 "$CGI_ROOT/fm150_at"

    # The FM150 page works directly at /fm150.html. Add a navigation entry if
    # this is the stock Simple Admin page and no entry exists yet.
    if [ -f "$INDEX" ] && ! grep -q 'href="/fm150.html"' "$INDEX"; then
        sed -i '/href="\/settings.html"/a\                <li class="nav-item"><a class="nav-link" href="/fm150.html">FM150 AT</a></li>' "$INDEX"
    fi

    restart_web
    echo 'FM150 Web AT overlay installed. Open: https://<module-ip>/fm150.html'
    check
}

bridge_install() {
    [ -n "$REPO_ROOT" ] || { usage >&2; exit 1; }
    local installer=/tmp/FM150_socat_bridge_install.sh
    download "$REPO_ROOT/FM150_socat_bridge_install.sh" "$installer"
    chmod 0755 "$installer"
    FM150_BRIDGE_SOURCE="$REPO_ROOT" "$installer" install
}

bridge_uninstall() {
    [ -n "$REPO_ROOT" ] || { usage >&2; exit 1; }
    local installer=/tmp/FM150_socat_bridge_install.sh
    download "$REPO_ROOT/FM150_socat_bridge_install.sh" "$installer"
    chmod 0755 "$installer"
    FM150_BRIDGE_SOURCE="$REPO_ROOT" "$installer" uninstall
}

uninstall() {
    [ "$(id -u)" = 0 ] || { echo 'ERROR: run as root.' >&2; exit 1; }
    rm -f "$WEB_ROOT/fm150.html" "$CGI_ROOT/fm150_at"
    if [ -f "${INDEX}.fm150.bak" ]; then
        mv "${INDEX}.fm150.bak" "$INDEX"
    fi
    restart_web
    echo 'FM150 Web AT overlay removed.'
}

case "$ACTION" in
    install|update) install ;;
    bridge-install) bridge_install ;;
    bridge-uninstall) bridge_uninstall ;;
    full-install) bridge_install; install ;;
    uninstall) uninstall ;;
    check) check ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
esac
