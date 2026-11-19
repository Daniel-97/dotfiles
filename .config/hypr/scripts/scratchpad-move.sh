#!/usr/bin/env bash
# Sposta la finestra attiva dentro/fuori dallo scratchpad "special".
# Versione senza DMS: usa solo hyprctl e ricorda il workspace di provenienza
# in $XDG_RUNTIME_DIR, così il ripristino torna dove era la finestra.

set -u

win="$(hyprctl activewindow -j 2>/dev/null)"
[ -n "$win" ] || exit 0

read -r addr ws < <(printf '%s' "$win" | python3 -c '
import json, sys
d = json.load(sys.stdin)
print(d.get("address", ""), (d.get("workspace") or {}).get("name", ""))
')

[ -n "$addr" ] || exit 0

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-scratchpad"
mkdir -p "$state_dir"
state="$state_dir/$addr"

case "$ws" in
    special|special:*)
        target="$(cat "$state" 2>/dev/null || echo "1")"
        hyprctl dispatch movetoworkspacesilent "$target,address:$addr"
        rm -f "$state"
        ;;
    "")
        exit 0
        ;;
    *)
        printf '%s' "$ws" > "$state"
        hyprctl dispatch movetoworkspacesilent "special:special,address:$addr"
        ;;
esac
