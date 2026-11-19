-- Monitor interno: 1920x1200, refresh nativo, scala 1.25.
-- "preferred" evita di hardcodare il refresh (il repo originale aveva
-- 1920x1080@60.056, che non e' il pannello di questa macchina).
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})

-- Quando colleghi uno schermo esterno aggiungi qui la sua regola, ad es.:
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 })
