#!/bin/bash
# Install the FM150 smd7/smd9 AT bridge.  Do not use the upstream
# update_socat-at-bridge.sh on FM150: it restores the old smd11 mapping.

set -eu

ACTION=${1:-install}
SOURCE=${FM150_BRIDGE_SOURCE:-https://raw.githubusercontent.com/AIxBits/fm150-webui/main}
BRIDGE_DIR=/usrdata/socat-at-bridge
UNIT_DIR=/lib/systemd/system
UNITS='socat-killsmd7bridge socat-smd7 socat-smd7-to-ttyIN2 socat-smd7-from-ttyIN2 socat-smd9 socat-smd9-to-ttyIN socat-smd9-from-ttyIN'

download() {
    local url="$1" destination="$2" tmp="${destination}.new"
    rm -f "$tmp"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$tmp"
    else
        wget -qO "$tmp" "$url"
    fi
    [ -s "$tmp" ] || { echo "ERROR: download failed: $url" >&2; exit 1; }
    mv "$tmp" "$destination"
}

require_root_and_nodes() {
    [ "$(id -u)" = 0 ] || { echo 'ERROR: run as root.' >&2; exit 1; }
    [ -c /dev/smd7 ] || { echo 'ERROR: /dev/smd7 is missing.' >&2; exit 1; }
    [ -c /dev/smd9 ] || { echo 'ERROR: /dev/smd9 is missing.' >&2; exit 1; }
}

stop_existing_bridge() {
    # Stop both the legacy Quectel naming and any partially installed FM150
    # services.  They are enabled again from the files installed below.
    systemctl stop at-telnet-daemon 2>/dev/null || true
    systemctl disable at-telnet-daemon 2>/dev/null || true
    for unit in socat-killsmd7bridge socat-smd7 socat-smd7-to-ttyIN2 socat-smd7-from-ttyIN2 socat-smd9 socat-smd9-to-ttyIN socat-smd9-from-ttyIN socat-smd11 socat-smd11-to-ttyIN socat-smd11-from-ttyIN; do
        systemctl stop "$unit" 2>/dev/null || true
        systemctl disable "$unit" 2>/dev/null || true
    done
    # Only remove the obsolete names.  The smd7/smd9 names are replaced in
    # place after the new service files have been downloaded.
    rm -f "$UNIT_DIR/socat-smd11.service" "$UNIT_DIR/socat-smd11-to-ttyIN.service" "$UNIT_DIR/socat-smd11-from-ttyIN.service"
}

install_bridge() {
    require_root_and_nodes
    mount -o remount,rw / 2>/dev/null || true
    mkdir -p "$BRIDGE_DIR/systemd_units"

    echo 'Installing FM150 AT bridge files...'
    for file in socat-armel-static killsmd7bridge atcmd atcmd11; do
        download "$SOURCE/socat-at-bridge/$file" "$BRIDGE_DIR/$file"
    done
    chmod 0755 "$BRIDGE_DIR/socat-armel-static" "$BRIDGE_DIR/killsmd7bridge" "$BRIDGE_DIR/atcmd" "$BRIDGE_DIR/atcmd11"
    ln -sf "$BRIDGE_DIR/atcmd" /bin/atcmd
    ln -sf "$BRIDGE_DIR/atcmd11" /bin/atcmd11

    stop_existing_bridge
    for unit in $UNITS; do
        download "$SOURCE/socat-at-bridge/systemd_units/$unit.service" "$BRIDGE_DIR/systemd_units/$unit.service"
        cp "$BRIDGE_DIR/systemd_units/$unit.service" "$UNIT_DIR/$unit.service"
    done

    systemctl daemon-reload
    for unit in $UNITS; do systemctl enable "$unit"; done
    systemctl start socat-killsmd7bridge
    systemctl start socat-smd7 socat-smd9
    sleep 2
    systemctl start socat-smd7-to-ttyIN2 socat-smd7-from-ttyIN2 socat-smd9-to-ttyIN socat-smd9-from-ttyIN

    echo 'FM150 AT bridge started:'
    systemctl --no-pager --full status socat-smd7 socat-smd9 2>/dev/null || true
    echo 'Test the primary channel with: atcmd ATI'
}

remove_bridge() {
    [ "$(id -u)" = 0 ] || { echo 'ERROR: run as root.' >&2; exit 1; }
    mount -o remount,rw / 2>/dev/null || true
    stop_existing_bridge
    for unit in $UNITS; do rm -f "$UNIT_DIR/$unit.service"; done
    for command in atcmd atcmd11; do
        if [ -L "/bin/$command" ] && [ "$(readlink "/bin/$command" 2>/dev/null || true)" = "$BRIDGE_DIR/$command" ]; then
            rm -f "/bin/$command"
        fi
    done
    rm -rf "$BRIDGE_DIR"
    systemctl daemon-reload
    echo 'FM150/legacy socat AT bridge removed. Simple Admin and Lighttpd were not changed.'
}

status_bridge() {
    echo 'Expected mapping: ttyOUT2 -> smd7; ttyOUT -> smd9'
    ls -l /dev/smd7 /dev/smd9 /dev/ttyOUT2 /dev/ttyOUT 2>/dev/null || true
    systemctl --no-pager --full status socat-smd7 socat-smd9 2>/dev/null || true
}

case "$ACTION" in
    install|update) install_bridge ;;
    uninstall) remove_bridge ;;
    status|check) status_bridge ;;
    *) echo "Usage: $0 [install|update|uninstall|status]" >&2; exit 2 ;;
esac
