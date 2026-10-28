#!/usr/bin/env bash
# Sposta la finestra attiva nello scratchpad DMS.
# Se la finestra è già nello scratchpad, la riporta fuori.

ws="$(hyprctl activewindow -j 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit()
print((d.get("workspace") or {}).get("name") or "")
' 2>/dev/null)"

case "$ws" in
    special|special:special)
        dms ipc call scratchpad restore
        ;;
    "")
        exit 0
        ;;
    *)
        dms ipc call scratchpad move special
        ;;
esac
