-- Integrazione Hyprland <-> Noctalia v5
-- Regole raccomandate da:
-- https://docs.noctalia.dev/noctalia/compositor-settings/hyprland/

-- Namespace delle superfici layer-shell di Noctalia.
local noctalia_ns = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"

-- Noctalia anima da se' le proprie superfici: le animazioni layer di Hyprland
-- si sovrapporrebbero causando glitch (es. pannello che strappa in chiusura).
hl.layer_rule({
    name = "noctalia-no-anim",
    match = { namespace = noctalia_ns },
    no_anim = true,
})

-- Blur per barra, pannelli, dock e notifiche.
hl.layer_rule({
    name = "noctalia-blur",
    match = { namespace = noctalia_ns },
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- Finestra Impostazioni Noctalia: floating, dimensionata sul monitor.
hl.window_rule({
    name = "noctalia-settings",
    match = { class = "dev\\.noctalia\\.Noctalia" },
    float = true,
    size = "monitor_w*0.5625 monitor_h*0.85",
})

-- Workspace persistenti: il widget workspaces di Noctalia mostra anche
-- quelli vuoti. Adatta "monitor" se aggiungi schermi esterni.
for i = 1, 9 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "eDP-1",
        persistent = true,
    })
end

-- Se in futuro attivi ecosystem.enforce_permissions = true, servono:
--   hl.permission("^/usr/bin/noctalia$", "screencopy", "allow")
--   hl.permission("^hl-virtual-keyboard-noctalia$", "keyboard", "allow")
-- Nota: Hyprland non ricarica i permessi con reload, serve restart.
