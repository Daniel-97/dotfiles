# Hyprland (Lua)

Configurazione per Hyprland >= 0.55 con DMS 2.0.

- `hyprland.lua`: configurazione principale (startup, env, input, look, regole, `require` dei frammenti DMS).
- `dms/`: frammenti gestiti da DMS.
  - Non modificare a mano `colors.lua`, `layout.lua`, `input.lua`, `windowrules.lua`, `cursor.lua` e `binds.lua`: vengono rigenerati da DMS.
  - Le personalizzazioni dei tasti vanno in `dms/binds-user.lua`.
- `scripts/`: script richiamati da bind e gesture.
- `dms/outputs.lua`: monitor `eDP-1` 1920x1080@60.056, posizione 0x0, scala 1.

## Ripristino

```bash
cp -a .config/hypr/. ~/.config/hypr/
dms setup   # solo se mancano frammenti generati da DMS
```

I backup dei vecchi `.conf` non sono versionati: vivono in `~/.config/hypr/.dms-backups/`.
