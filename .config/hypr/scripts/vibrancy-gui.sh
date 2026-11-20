#!/usr/bin/env bash
# Slider grafico per la saturazione dello shader vibrancy.
# Legge e modifica SAT in ~/.config/hypr/shaders/vibrancy.frag e applica
# con un reload. Cancel non tocca nulla.
#
# Bind consigliato (binds-user.lua):
#   hl.bind("SUPER + B", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/vibrancy-gui.sh"), ...)
set -euo pipefail

SHADER="$HOME/.config/hypr/shaders/vibrancy.frag"

cur=$(sed -n 's/^const float SAT   = \([0-9.]*\);.*/\1/p' "$SHADER" | head -1)
cur=${cur:-1.00}
cur100=$(awk -v v="$cur" 'BEGIN{printf "%d", int(v*100+0.5)}')

val=$(zenity --scale \
    --title="Vibrancy — saturazione" \
    --text="100 = neutro · attuale: ×${cur}" \
    --min-value=100 --max-value=170 --step=2 --value="$cur100") || exit 0

sat=$(awk -v v="$val" 'BEGIN{printf "%.2f", v/100}')
sed -i "s/^const float SAT   = [0-9.]\+;/const float SAT   = ${sat};/" "$SHADER"
hyprctl reload >/dev/null
