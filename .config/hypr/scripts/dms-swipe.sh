#!/usr/bin/env bash
# Swipe 3 dita: gesture dinamiche per le overlay DMS.
# up   -> chiude le notifiche se aperte, altrimenti toggle overview
# down -> chiude l'overview se aperto, altrimenti toggle scratchpad

dir="${1:-}"
layers="$(hyprctl layers -j)"

has_layer() { grep -q "\"$1\"" <<<"$layers"; }

case "$dir" in
    up)
        if has_layer "dms:notification-center-modal"; then
            dms ipc call notifications close
        else
            dms ipc call hypr toggleOverview
        fi
        ;;
    down)
        if has_layer "dms:workspace-overview"; then
            dms ipc call hypr closeOverview
        else
            dms ipc call scratchpad toggle special
        fi
        ;;
    *)
        echo "uso: $0 up|down" >&2
        exit 1
        ;;
esac
