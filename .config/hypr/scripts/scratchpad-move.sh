#!/usr/bin/env bash
# Sposta la finestra attiva dentro/fuori dallo scratchpad "special".
# Versione senza DMS: usa solo hyprctl e ricorda il workspace di provenienza
# in $XDG_RUNTIME_DIR, così il ripristino torna dove era la finestra.
#
# Nota Hyprland >= 0.55 (config Lua): "hyprctl dispatch" accetta solo
# espressioni Lua (hl.dsp.*); la vecchia sintassi testuale
# "hyprctl dispatch movetoworkspacesilent special:special,address:..."
# viene rigettata con un errore di parsing e la finestra non si sposta.

set -u

win="$(hyprctl activewindow -j 2>/dev/null)"
# "activewindow" risponde {} quando il focus e' su una superficie layer-shell
# (es. launcher di Noctalia): nessuna finestra attiva, esci senza fare nulla.
[ -n "$win" ] || exit 0
case "$win" in *address*) ;; *) exit 0 ;; esac

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
        # Il nome finisce dentro una stringa Lua: via virgolette e backslash.
        target="${target//[\"\\]/}"
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$target\", follow = false, window = \"address:$addr\" })"
        rm -f "$state"
        ;;
    "")
        exit 0
        ;;
    *)
        printf '%s' "$ws" > "$state"
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:special\", follow = false, window = \"address:$addr\" })"
        ;;
esac
