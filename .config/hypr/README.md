# Hyprland (Lua) + Noctalia

Configurazione per **Hyprland >= 0.55** (config Lua) con **Noctalia v5** come shell.
È il porting del setup precedente basato su DMS 2.0: layout, animazioni, window
rules, scratchpad e bind sono gli stessi; lo strato shell usa `noctalia msg`
al posto di `dms ipc call`.

## File

- `hyprland.lua`: configurazione principale (startup, env, input, look, regole,
  logica scratchpad, `require` dei frammenti).
- `noctalia.lua`: integrazione Hyprland ↔ Noctalia (layer rule `no_anim` + blur,
  finestra Impostazioni floating, workspace persistenti).
- `binds.lua`: bind predefiniti, già tradotti in comandi `noctalia msg`.
- `binds-user.lua`: override personali (caricato dopo `binds.lua`).
- `colors.lua`: colori bordi/gruppi, **statici** (prima li generava DMS/matugen).
- `outputs.lua`: monitor `eDP-1` 1920x1200, refresh `preferred`, scala 1.25.
- `hypridle.conf`: idle/suspend; il lock passa da `noctalia msg session lock`.
- `scripts/scratchpad-move.sh`: sposta/riprende la finestra attiva dallo scratchpad.

La lockscreen è quella di Noctalia: `hyprlock.conf` è stato rimosso.

## Requisiti (Fedora)

```bash
sudo dnf copr enable lionheartp/Hyprland
sudo dnf install hyprland noctalia \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  hypridle nautilus gnome-keyring \
  brightnessctl playerctl wl-clipboard
```

> **Lockscreen:** il pacchetto `noctalia` dei repo Fedora **non include
> `noctalia-pam-helper`**, quindi il lock screen non riesce ad autenticare.
> Usa il pacchetto del COPR, che lo contiene:
>
> ```bash
> sudo dnf swap noctalia noctalia-git
> ```
>
> `hyprland.lua` avvia `hypridle` solo se l'helper esiste, per non rischiare
> un auto-lock senza autenticazione.

Agente polkit (prompt grafici per i comandi privilegiati):

```bash
noctalia msg config-set shell.polkit_agent true
```

`ghostty` (terminale usato dai bind) è già installato; il suo config non deve
contenere `theme = dankcolors`, che veniva generato da DMS.

## Installazione

Fai un backup di quello che c'è già, poi copia:

```bash
mkdir -p ~/.config/hypr/.backups/manual-$(date +%F)
cp -a ~/.config/hypr/. ~/.config/hypr/.backups/manual-$(date +%F)/ 2>/dev/null || true
cp -a .config/hypr/. ~/.config/hypr/
chmod +x ~/.config/hypr/scripts/scratchpad-move.sh
```

Al login (GDM → ingranaggio → *Hyprland*) Noctalia parte da `hyprland.lua`.
GNOME resta disponibile come fallback.

## Note

- I workspace persistenti 1–9 sono fissati a `eDP-1` in `noctalia.lua`: se
  aggiungi un monitor esterno, aggiorna `monitor`.
- Su layout italiano `AltGr` è Mod5: i resize con Super+Alt hanno anche gli
  alias Super+MOD5 in `binds-user.lua`.
- Se attivi `ecosystem.enforce_permissions = true`, scommenta i permessi per
  `noctalia` (screencopy/keyboard) in `noctalia.lua`.
