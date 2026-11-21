-- Hyprland configuration (Lua)
-- Hyprland >= 0.55, shell: Noctalia v5.
-- Porting dal setup DMS 2.0: la logica di finestre/workspace e' la stessa,
-- lo strato "shell" (barra, launcher, notifiche, lock, OSD) e' Noctalia.

-- ==================
-- STARTUP
-- ==================
-- Noctalia si avvia dal compositor. Se preferisci gestirlo come servizio
-- systemd utente, sostituisci la riga con:
--   hl.exec_cmd("systemctl --user start noctalia.service")
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    -- DPI per le app XWayland: 96 * 1.0 = 96 (scala 1.00). Con force_zero_scaling
    -- (vedi sezione INPUT) lo scaling delle app X11 e' gestito dalle app
    -- stesse tramite Xft.dpi, non dal compositor.
    hl.exec_cmd("sh -c \"echo 'Xft.dpi: 96' | xrdb -merge -\"")
    -- LC_TIME italiano per Noctalia: nomi di giorni/mesi localizzati nella barra (es. "Sab 21 nov").
    hl.exec_cmd("env LC_TIME=it_IT.UTF-8 noctalia")
    -- Idle/lock/suspend: le behavior di Noctalia sono disattivate di default,
    -- quindi usiamo hypridle (vedi hypridle.conf). In alternativa abilita
    -- idle.behavior.* in settings.toml e rimuovi questa riga.
    hl.exec_cmd("hypridle")
end)

-- ==================
-- ENVIRONMENT
-- ==================
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")
hl.env("TERMINAL", "ghostty")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ==================
-- INPUT
-- ==================
hl.config({
    input = {
        kb_layout = "it",
        numlock_by_default = true,
        accel_profile = "flat",
        sensitivity = 1.0,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            scroll_factor = 0.3,
        },
    },

    -- ==================
    -- GENERAL / DECORATION
    -- ==================
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12,
        -- Vibrancy screen-wide: compensa il gamut ridotto del pannello
        -- (~66% sRGB). Fattori regolabili in shaders/vibrancy.frag.
        screen_shader = "/home/dan/.config/hypr/shaders/vibrancy.frag",
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.1,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 4,
            offset = "0 5",
            color = "rgba(00000070)",
        },
        -- Blur richiesto dalle superfici Noctalia (barra, pannelli, OSD).
        blur = {
            enabled = true,
            xray = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
        -- Le finestre lente aprono sul workspace in cui sono state LANCIATE,
        -- non in quello attivo al momento dell'apertura.
        -- 2 = tracking persistente (vale anche per i processi figli); il
        -- token scade dopo 60s (default 10s: le app lente sfuggivano al
        -- tracking prima ancora di aprire la finestra).
        initial_workspace_tracking = 2,
        initial_workspace_token_timeout = 60,
    },

    -- XWayland: force_zero_scaling serviva con lo scaling frazionario (le app
    -- X11 venivano riscalate dal compositor -> testo sgranato). Con scala
    -- 1.00 la regola e' inerte ma innocua: la teniamo per se torni a scale
    -- frazionarie. Le app X11 si dimensionano comunque via Xft.dpi
    -- (impostato all'avvio, vedi sezione STARTUP).
    xwayland = {
        force_zero_scaling = true,
    },
    render = {
        -- Curva di trasferimento per i contenuti SDR senza tag colore.
        -- "gamma22" rende i mezzitoni leggermente piu' profondi: si puo'
        -- provare dal pannello colore (scripts/color-panel.sh).
        cm_sdr_eotf = "gamma22",
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        mfact = 0.5,
    },
    animations = {
        enabled = true,
    },
})

-- ==================
-- ANIMATIONS
-- ==================
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "default" })

-- Scratchpad: entra dal basso verso l'alto, esce scendendo.
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 5, bezier = "default", style = "slidevert bottom" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "default", style = "slidevert top" })

-- ==================
-- WINDOW RULES
-- ==================
-- Ghostty su Hyprland >= 0.55: ghostty (GTK4) dichiara l'intera superficie
-- come opaque region, quindi il suo background-opacity nativo non produce
-- trasparenza. La gestiamo lato compositor: regola opacity (attiva e
-- inattiva a 0.85, come il vecchio setup DMS). Nota: anche il testo risulta
-- leggermente traslucido, e' il compromesso noto di questo approccio.
hl.window_rule({
    name = "ghostty-transparency",
    match = { class = "^(com\\.mitchellh\\.ghostty)$" },
    opacity = "0.85 0.85",
})

hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, tile = true })

hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })

hl.window_rule({ match = { class = "^(gnome-control-center)$" }, tile = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, tile = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tile = true })

hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(gnome-calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(galculator)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.gnome\\.Nautilus)$" }, tile = true })
hl.window_rule({ match = { class = "^(steam)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal)$" }, float = true })

hl.window_rule({ match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })

-- ==================
-- SCRATCHPAD: FINESTRE SEMPRE FLOATING
-- ==================
local function is_scratchpad_workspace(ws)
    local name = ws and ws.name or ""
    return name == "special" or name:match("^special:") ~= nil
end

local function float_in_scratchpad(w)
    if not w or not is_scratchpad_workspace(w.workspace) then return end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
    end
end

-- Copre le finestre aperte direttamente nello scratchpad.
hl.on("window.open", float_in_scratchpad)

-- Copre le finestre spostate nello scratchpad (bind, script o move manuale).
hl.on("window.move_to_workspace", function(w, ws)
    if not w or not is_scratchpad_workspace(ws) then return end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
    end
end)

-- Copre le finestre gia' presenti nello scratchpad al reload della config.
hl.on("config.reloaded", function()
    for _, w in ipairs(hl.get_windows()) do
        float_in_scratchpad(w)
    end
end)

-- ==================
-- FRAMMENTI
-- ==================
require("colors")
require("outputs")
require("noctalia")
require("binds")
require("binds-user")

-- ==================
-- RESIZE SUI BORDI
-- ==================
-- Nativo di Hyprland: trascina bordo/gap col tasto sinistro.
-- Non richiede Meta; con Meta+sinistro resta attivo il move della finestra.
hl.config({ general = { resize_on_border = true } })
