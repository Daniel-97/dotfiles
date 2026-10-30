-- Hyprland configuration (Lua)
-- Migrazione da hyprland.conf alla config Lua (Hyprland >= 0.55, DMS 2.0).
-- I frammenti gestiti da DMS sono inclusi in fondo.

-- ==================
-- STARTUP
-- ==================
-- dms.service è già abilitato via systemd: qui esportiamo l'ambiente
-- e avviamo il target di sessione, senza lanciare "dms run" una seconda volta.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

-- ==================
-- ENVIRONMENT
-- ==================
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")
hl.env("TERMINAL", "ghostty")

-- ==================
-- INPUT
-- ==================
hl.config({
    input = {
        kb_layout = "it",
        numlock_by_default = true,
        accel_profile = "flat",
        sensitivity = 5.0,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
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
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 5,
            offset = "0 5",
            color = "rgba(00000070)",
        },
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
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

-- DMS layers: niente animazioni
hl.layer_rule({ match = { namespace = "^(quickshell)$" }, no_anim = true })
hl.layer_rule({ match = { namespace = "^dms:.*" }, no_anim = true })

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

-- Copre le finestre spostate nello scratchpad (DMS, script o move manuale).
hl.on("window.move_to_workspace", function(w, ws)
    if not w or not is_scratchpad_workspace(ws) then return end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
    end
end)

-- Copre le finestre già presenti nello scratchpad al reload della config.
hl.on("config.reloaded", function()
    for _, w in ipairs(hl.get_windows()) do
        float_in_scratchpad(w)
    end
end)

-- ==================
-- DMS FRAGMENTS
-- ==================
require("dms.colors")
require("dms.outputs")
require("dms.layout")
require("dms.cursor")
require("dms.input")
require("dms.binds")
require("dms.binds-user")
require("dms.windowrules")
