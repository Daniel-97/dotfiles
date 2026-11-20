#!/usr/bin/env bash
# Pannello colore: saturazione, contrasto, temperatura (shader vibrancy) e
# color management (preset cm + curva SDR/EOTF).
#
# Pannello persistente: "Apply" applica e la finestra si riapre subito con
# i valori aggiornati (zenity e' a richiesta-risposta, quindi la "persistenza"
# e' un ciclo di riapertura). "Close" chiude. Ogni campo parte su
# "mantieni": lasciare cosi' non tocca quel parametro.
#
# Bind: SUPER+SHIFT+B (binds-user.lua). Slider rapido di saturazione:
# SUPER+B (vibrancy-gui.sh).
set -uo pipefail

# Evita doppie istanze del pannello.
for pid in $(pgrep -f color-panel.sh); do
    [ "$pid" != "$$" ] && exit 0
done

SHADER="$HOME/.config/hypr/shaders/vibrancy.frag"
OUTPUTS="$HOME/.config/hypr/outputs.lua"
HYPRLAND="$HOME/.config/hypr/hyprland.lua"

apply_out() {  # $1 = riga "sat|contr|warm|cm|eotf"
    local sat contr warm cme eotf
    IFS='|' read -r sat contr warm cme eotf <<<"$1"

    if [[ -n "$sat" && "$sat" != mantieni* ]]; then
        sed -i "s/^const float SAT   = [-0-9.]\+;/const float SAT   = ${sat};/" "$SHADER"
    fi
    if [[ -n "$contr" && "$contr" != mantieni* ]]; then
        sed -i "s/^const float CONTR = [-0-9.]\+;/const float CONTR = ${contr};/" "$SHADER"
    fi
    if [[ -n "$warm" && "$warm" != mantieni* ]]; then
        sed -i "s/^const float WARM  = [-0-9.]\+;/const float WARM  = ${warm};/" "$SHADER"
    fi
    if [[ -n "$cme" && "$cme" != mantieni* ]]; then
        sed -i 's/^\([[:space:]]*cm[[:space:]]*= \)"[a-z]*"/\1"'"${cme}"'"/' "$OUTPUTS"
    fi
    if [[ -n "$eotf" && "$eotf" != mantieni* ]]; then
        sed -i 's/^\([[:space:]]*cm_sdr_eotf = \)"[a-z0-9]*"/\1"'"${eotf}"'"/' "$HYPRLAND"
    fi
    hyprctl reload >/dev/null
}

while :; do
    # Rilegge i valori correnti a ogni riapertura: il pannello mostra lo
    # stato reale (comprese eventuali modifiche fatte fuori dal pannello).
    SAT=$(sed -n "s/^const float SAT   = \([-0-9.]*\);.*/\1/p" "$SHADER" | head -1); SAT=${SAT:-1.00}
    CONTR=$(sed -n "s/^const float CONTR = \([-0-9.]*\);.*/\1/p" "$SHADER" | head -1); CONTR=${CONTR:-1.00}
    WARM=$(sed -n "s/^const float WARM  = \([-0-9.]*\);.*/\1/p" "$SHADER" | head -1); WARM=${WARM:-0.00}
    CM=$(sed -n 's/^[[:space:]]*cm[[:space:]]*= "\([a-z]*\)".*/\1/p' "$OUTPUTS" | head -1); CM=${CM:-srgb}
    EOTF=$(sed -n 's/^[[:space:]]*cm_sdr_eotf = "\([a-z0-9]*\)".*/\1/p' "$HYPRLAND" | head -1); EOTF=${EOTF:-default}

    out=$(zenity --forms \
        --title="Pannello colore" \
        --text="Scegli solo i parametri da cambiare (gli altri restano come ora).
Saturazione: intensita' dei colori (1.00 = neutro)
Contrasto: separazione chiaro/scuro attorno al grigio medio
Temperatura: >0 caldo, <0 freddo
Color management: mappatura primarie (attuale: ${CM})
EOTF/gamma: curva SDR (attuale: ${EOTF})" \
        --separator="|" \
        --ok-label="Apply" --cancel-label="Close" \
        --add-combo="Saturazione" --combo-values="mantieni (${SAT})|1.00|1.05|1.10|1.15|1.20|1.25|1.30|1.40|1.50|1.70" \
        --add-combo="Contrasto" --combo-values="mantieni (${CONTR})|1.00|1.02|1.04|1.06|1.08|1.10|1.15" \
        --add-combo="Temperatura" --combo-values="mantieni (${WARM})|-0.10|-0.05|0.00|0.05|0.10" \
        --add-combo="Color management" --combo-values="mantieni (${CM})|srgb|edid|wide|dcip3|adobe" \
        --add-combo="EOTF/gamma SDR" --combo-values="mantieni (${EOTF})|srgb|gamma22|gamma22force") || break

    apply_out "$out"
done
