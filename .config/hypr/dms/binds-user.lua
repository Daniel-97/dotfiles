-- Override personali ai default DMS 2.0.
-- Questo file viene caricato dopo dms/binds.lua: hl.unbind rimuove il bind
-- stock già registrato, poi hl.bind registra il comportamento migrato.

-- ==================
-- APP / LAUNCHER
-- ==================
hl.unbind("SUPER + Q")
hl.bind("SUPER + Q", hl.dsp.exec_cmd("ghostty"))

hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))

hl.unbind("SUPER + D")
hl.bind("SUPER + D", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))

hl.unbind("SUPER + M")
hl.bind("SUPER + M", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))

hl.unbind("SUPER + N")
hl.bind("SUPER + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))

hl.unbind("SUPER + SHIFT + N")
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"))

-- ==================
-- WINDOW MANAGEMENT
-- ==================
hl.unbind("SUPER + C")
hl.bind("SUPER + C", hl.dsp.window.close())

hl.unbind("SUPER + V")
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.group.toggle())

hl.unbind("SUPER + L")
hl.bind("SUPER + L", hl.dsp.exec_cmd("dms ipc call lock lock"))

-- Il dispatcher Lua accetta solo pixel; "exact 100%" resta via hyprctl.
hl.unbind("SUPER + CTRL + F")
hl.bind("SUPER + CTRL + F", hl.dsp.exec_cmd("hyprctl dispatch resizeactive exact 100%"))

-- ==================
-- SCRATCHPAD DMS
-- ==================
hl.unbind("SUPER + S")
hl.bind("SUPER + S", hl.dsp.exec_cmd("dms ipc call scratchpad toggle special"))

hl.unbind("SUPER + SHIFT + S")
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/scratchpad-move.sh"))

-- ==================
-- RESIZE PERCENTUALE
-- resizeactive accetta percentuali, hl.dsp.window.resize solo pixel:
-- calcoliamo il delta dal 10% della dimensione corrente della finestra.
-- ==================
local function resize_active(pct_x, pct_y)
    local w = hl.get_active_window()
    if not w then return end
    hl.dispatch(hl.dsp.window.resize({
        x = math.floor(w.size.x * pct_x / 100),
        y = math.floor(w.size.y * pct_y / 100),
        relative = true,
    }))
end

-- Ripristina i bind DMS di resize: sulla layout italiana "equal" è Shift+0,
-- quindi meglio usare frecce e + / - che sono tasti diretti.
hl.unbind("SUPER + equal")
hl.unbind("SUPER + minus")
hl.unbind("SUPER + SHIFT + equal")
hl.unbind("SUPER + SHIFT + minus")

-- Orizzontale: destra = più largo, sinistra = più stretto.
hl.unbind("SUPER + ALT + left")
hl.bind("SUPER + ALT + left", function() resize_active(-10, 0) end, { repeating = true, description = "Resize window narrower" })
hl.unbind("SUPER + ALT + right")
hl.bind("SUPER + ALT + right", function() resize_active(10, 0) end, { repeating = true, description = "Resize window wider" })

-- Verticale: su = più alto, giù = più basso.
hl.unbind("SUPER + ALT + up")
hl.bind("SUPER + ALT + up", function() resize_active(0, 10) end, { repeating = true, description = "Resize window taller" })
hl.unbind("SUPER + ALT + down")
hl.bind("SUPER + ALT + down", function() resize_active(0, -10) end, { repeating = true, description = "Resize window shorter" })

-- L'Alt destro sulla layout italiana è AltGr (Mod5), non Mod1/ALT:
-- aggiungo gli alias per far funzionare il resize con entrambi i tasti Alt.
hl.unbind("SUPER + MOD5 + left")
hl.bind("SUPER + MOD5 + left", function() resize_active(-10, 0) end, { repeating = true, description = "Resize window narrower (AltGr)" })
hl.unbind("SUPER + MOD5 + right")
hl.bind("SUPER + MOD5 + right", function() resize_active(10, 0) end, { repeating = true, description = "Resize window wider (AltGr)" })
hl.unbind("SUPER + MOD5 + up")
hl.bind("SUPER + MOD5 + up", function() resize_active(0, 10) end, { repeating = true, description = "Resize window taller (AltGr)" })
hl.unbind("SUPER + MOD5 + down")
hl.bind("SUPER + MOD5 + down", function() resize_active(0, -10) end, { repeating = true, description = "Resize window shorter (AltGr)" })

-- Alias orizzontali con - e + (sulla layout italiana + è un tasto dedicato).
hl.unbind("SUPER + plus")
hl.bind("SUPER + plus", function() resize_active(10, 0) end, { repeating = true, description = "Resize window wider" })
hl.bind("SUPER + minus", function() resize_active(-10, 0) end, { repeating = true, description = "Resize window narrower" })

-- ==================
-- GESTURES
-- ==================
-- Swipe 3 dita su: apre lo scratchpad. Giù: lo chiude.
local function scratchpad_is_open()
    local ws   = hl.get_active_special_workspace()
    local name = ws and ws.name or ""
    return name == "special" or name == "special:special"
end

local function scratchpad_open()
    if not scratchpad_is_open() then
        hl.dispatch(hl.dsp.workspace.toggle_special("special"))
    end
end

local function scratchpad_close()
    if scratchpad_is_open() then
        hl.dispatch(hl.dsp.workspace.toggle_special("special"))
    end
end

hl.gesture({ fingers = 3, direction = "up", action = scratchpad_open })
hl.gesture({ fingers = 3, direction = "down", action = scratchpad_close })

-- Swipe 3 dita con SUPER: ridimensiona la finestra attiva.
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "resize" })
