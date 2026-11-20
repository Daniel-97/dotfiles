# dotfiles
Personal repository with various configuration files

## Programmi configurati

- **ghostty** – terminale (font, aspetto della finestra, cursore)
- **hypr** – Hyprland, compositore Wayland (config Lua, shell Noctalia, bind, hypridle)
- **nvim** – Neovim (configurazione minimale in `init.lua`)
- **sway** – window manager Wayland stile i3 (`config` + frammenti in `config.d/`)
- **waybar** – barra di stato (moduli e stile CSS)
- **wofi** – launcher applicazioni (foglio di stile)
- **noctalia** – shell Wayland v5 (config dichiarativa in `.config/noctalia/noctalia.toml`: barra, lockscreen e widget, tema, OSD)

> **Noctalia su una macchina nuova:** copia `.config/noctalia/` in `~/.config/noctalia/` e riattiva il plugin
> `yocraft/battery-widget` (batteria nella lockscreen) con `noctalia msg plugins enable yocraft/battery-widget`.
> Nota: l'editor grafico dei widget scrive in `~/.local/state/noctalia/settings.toml`, che **ha precedenza**
> sul file dichiarativo — dopo modifiche via GUI riesporta con `noctalia config export > ~/.config/noctalia/noctalia.toml`.
