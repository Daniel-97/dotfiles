//
// Vibrancy morbida per pannello narrow-gamut (Innolux N140JCA-EEK, ~66% sRGB).
//   SAT   saturazione (1.0 = neutro)
//   CONTR micro-contrasto attorno al medio grigio (1.0 = neutro)
//   WARM  temperatura: >0 piu' caldo (rossi su, blu giu), <0 piu' freddo
// Regola i valori e ricarica con `hyprctl reload`, oppure usa il pannello
// colore (scripts/color-panel.sh, bind SUPER+SHIFT+B).
//
#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

const float SAT   = 1.40;
const float CONTR = 1.04;
const float WARM  = 0.00;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    vec3 c = pixColor.rgb;
    c.r *= (1.0 + WARM);
    c.b *= (1.0 - WARM);
    float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
    vec3 outc  = vec3(luma) + (c - vec3(luma)) * SAT;
    outc        = mix(vec3(0.5), outc, CONTR);
    fragColor   = vec4(clamp(outc, 0.0, 1.0), pixColor.a);
}
