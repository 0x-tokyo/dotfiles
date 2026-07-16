# dotfiles

Personal Linux dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Stack:** Arch Linux · Hyprland (Wayland) · ghostty + zsh · Neovim · NVIDIA (hybrid Intel/NVIDIA)
**Theme:** TokyoNight Storm across the whole environment.

---

## Structure

Each top-level folder is a Stow *package* that mirrors its target layout under `$HOME`:

```
dotfiles/
├── ghostty/      .config/ghostty/        → terminal config + shaders
├── zsh/           .zshrc, .p10k.zsh      → shell (oh-my-zsh + powerlevel10k)
├── tmux/         .config/tmux/           → tmux.conf (plugins via TPM, not committed)
├── hypr/         .config/hypr/           → hyprland.lua, hypridle, hyprlock + Scripts
├── rofi/         .config/rofi/           → config + tokyonight theme
├── waybar/       .config/waybar/         → config.jsonc + style.css
├── cava/         .config/cava/           → waybar_config (raw ascii output for waybar's custom/cava module)
├── qbittorrent/  .local/share/qbittorrent-themes/ → dracula.qbtheme (custom UI theme)
├── claude/       .claude/                → CLAUDE.md, commands/ (slash prompts), settings.json (plugin marketplaces)
├── kitty/        .config/kitty/          → kitty.conf + theme (dormant — kitty not installed, kept for reference)
├── wezterm/      .config/wezterm/        → wezterm.lua + bg.jpg (dormant — wezterm not installed, kept for reference)
├── environment/  .config/environment.d/  → systemd user env vars (PATH, QT platform theme, ssh-agent socket) + systemd user units (backup, vault-reminder, whisper-daemon, ssh-agent)
├── gtk-theme/    .themes/Tokyonight-Dark-Storm/ → GTK theme itself (gtk-2.0/3.0/4.0, trimmed — no GNOME/Cinnamon/XFCE on Hyprland)
├── ssh/          .ssh/config             → minimal safe template only (Include ~/.ssh/config.d/* for private/host-specific stuff, kept out of git)
├── thunderbird/  chrome/                 → userChrome/userContent (copied, not stowed)
├── wireshark/    .config/wireshark/      → pentest profile (colorfilters, dfilter_buttons)
├── gtk-interface.dconf                   → GTK theme/icons/cursor dconf dump (references gtk-theme/ by name)
└── install.sh                            → bootstrap script
```

Running `stow <package>` from the repo root creates symlinks like
`~/.config/hypr/hyprland.lua → ~/dotfiles/hypr/.config/hypr/hyprland.lua`.

> **hyprland.conf is not used.** As of Hyprland 0.55, the classic `hyprlang` config
> format is deprecated in favor of Lua. Hyprland will *regenerate* `hyprland.lua`
> from its own stock template if the file is missing — it does not fall back to
> `hyprland.conf` even if one is present. Everything lives in `hyprland.lua` now.

> **nvim** is a separate repo: [0x-tokyo/nvim-config](https://github.com/0x-tokyo/nvim-config).
> `install.sh` clones it into `~/.config/nvim`.

> **thunderbird/** is *not* a stow package — the TB profile directory name is
> machine-generated, so `install.sh` finds the active profile via `profiles.ini`
> and copies the CSS into `<profile>/chrome/` instead of symlinking.

> **ssh/** is *not* auto-stowed by `install.sh` (permissions/secrets need manual
> care). Stow it explicitly: `stow ssh`. Private hosts/keys go in
> `~/.ssh/config.d/local.conf` (untracked, gitignored) — the tracked
> `ssh/.ssh/config` just has `Include ~/.ssh/config.d/*` plus the GitHub block.

> **claude/** — `settings.json` lists `extraKnownMarketplaces` (`karpathy-skills`,
> `claude-plugins-official`) and `enabledPlugins` (`security-guidance`,
> `code-review`); Claude Code pulls the actual plugin code from those
> marketplaces itself, nothing else to restore manually. Session state
> (`.credentials.json`, `history.jsonl`, `projects/`, etc.) is intentionally
> not stowed — machine/session-local, not config.

> **kitty/** and **wezterm/** are *not* in `PACKAGES` — carried over from an old
> machine's backup for reference, neither terminal is currently installed/used
> (ghostty is the daily driver). Stow explicitly (`stow kitty` / `stow wezterm`)
> if you actually install one.

---

## Install (fresh machine)

### 1. SSH key for GitHub

`install.sh` clones the nvim repo over SSH, so set up a key first:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519_github.pub   # add this to GitHub → Settings → SSH keys
ssh -T git@github.com               # verify
```

Uses port 443 for GitHub (some networks block 22) — already set in `ssh/.ssh/config`:

```
Host github.com
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519_github
```

### 2. Clone and bootstrap

```bash
git clone https://github.com/0x-tokyo/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
stow ssh   # not auto-stowed, see above
```

`install.sh` will:
- `stow` every package in `PACKAGES` (ghostty zsh tmux hypr rofi waybar cava qbittorrent claude environment gtk-theme)
- clone TPM (tmux plugin manager)
- clone nvim-config
- restore GTK theme/icons/cursor via `dconf load`
- copy the Thunderbird userChrome/userContent theme into the active TB profile

### 3. Post-install (manual)

- **Locale:** Arch installer doesn't always generate `en_US.UTF-8` even if
  `/etc/locale.conf` points at it. If GUI apps (rofi, etc.) silently exit 1 with
  "Failed to set locale" warnings, run:
  `sudo sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && sudo locale-gen`
- **tmux:** open tmux, press `prefix + I` to install plugins
- **Thunderbird:** Settings → Config Editor →
  `toolkit.legacyUserProfileCustomizations.stylesheets = true`, then restart TB
  (otherwise userChrome.css is ignored)
- **GNOME Keyring:** no PAM auto-unlock hook on a getty/tty1 login (no GDM/SDDM),
  so the keyring prompts for a password on every app request until you set a
  *blank* password the first time it asks — then it auto-unlocks on login.
- Install the actual programs yourself (see below) — `install.sh` only lays down configs

---

## Dependencies

`install.sh` only creates symlinks and restores settings. Install programs yourself.

| Package  | Requires |
|----------|----------|
| ghostty  | `ghostty`; font **JetBrainsMono Nerd Font** (`ttf-jetbrains-mono-nerd`) |
| zsh      | `zsh`, [oh-my-zsh](https://ohmyz.sh/), [powerlevel10k](https://github.com/romkatv/powerlevel10k), `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-history-substring-search`, `fzf`, `eza`, `bat` |
| tmux     | `tmux`; TPM (cloned by install.sh) |
| hypr     | `hyprland`, `hyprpaper`, `swaync`, `hyprshot`, `hyprlock`, `hypridle`, `hyprpicker`, `rofi`, `cliphist`, `playerctl` |
| waybar   | `waybar`; `cava` (audio visualizer module) |
| rofi     | `rofi` (Wayland build); `rofi -show filebrowser` doubles as a lightweight file manager |
| file manager | `nemo` (default, `inode/directory` in `~/.config/mimeapps.list` — not stowed, machine-local) |
| images   | `imv` (default image viewer) |
| Qt theme | `papirus-icon-theme`, `kvantum`, `qt6ct` (`QT_QPA_PLATFORMTHEME=qt6ct` in environment.d) — no dedicated Tokyonight Kvantum theme exists, using `KvArcDark` as the closest bundled dark theme |
| cursor   | `bibata-cursor-theme` (AUR) |
| whisper  | `faster-whisper` (pip, `--break-system-packages`), `alsa-utils`, `sox`, `bc` |
| GTK theme| **Tokyonight-Dark-Storm** (stowed from `gtk-theme/`, see Structure above), **Papirus-Dark** icons (`papirus-icon-theme`), **Bibata-Modern-Classic** cursor |

> **Keybind mod:** `$mod = SUPER` in `hyprland.lua`. (Was `ALT` for a while on
> this specific keyboard when Super looked dead — turned out to be fine.)

### NVIDIA (hybrid Intel + NVIDIA)

- `nvidia`, `nvidia-utils`
- `mkinitcpio.conf`: `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`, then `mkinitcpio -P`
- Kernel params (GRUB): `nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1`
- Env vars (`.zprofile`, only set when auto-launching Hyprland on tty1):
  `LIBVA_DRIVER_NAME=nvidia GBM_BACKEND=nvidia-drm _GLX_VENDOR_LIBRARY_NAME=nvidia`

---

## Applications

| App | Method | Notes |
|-----|--------|-------|
| Firefox, Chromium, Obsidian, Bitwarden, Wireshark, rsync, tor, Discord, Telegram (`telegram-desktop`), VLC, qBittorrent, Nemo, imv | `pacman -S` (official repos) | Discord/other Wayland apps may need `--enable-features=UseOzonePlatform --ozone-platform=wayland` in their `.desktop` if not native Wayland already |
| Claude Desktop | AUR / official installer | binary: `claude-desktop` |
| Signal | flatpak `org.signal.Signal` | |
| Google Chrome, Spotify, obfs4proxy, platformsh-cli | AUR (`yay -S`) | |

---

## Usage

```bash
cd ~/dotfiles
stow hypr        # link a single package
stow */          # link all packages
stow -D hypr     # unlink (remove symlinks)
stow -R hypr     # restow (re-link after changes)
```

After editing a config the symlink already points at the repo file — just
`git add` / `commit`. No re-stow needed unless you add new files.

**After editing `hyprland.lua`:** `hyprctl reload` re-parses the file, but does
**not** re-run top-level statements like `exec_cmd` autostart calls or refire
`hl.on("hyprland.start", ...)` — that only fires on a fresh compositor start.
If you change autostart, either guard the `exec_cmd` calls with a `pkill`/`pgrep`
check (see current file) so `reload` stays idempotent, or fully restart Hyprland.

---

## Notes

- Secrets are excluded via `.gitignore` (keys, tokens, `.env`, `*secret*`).
- GTK *settings* (theme name, icon theme, cursor, fonts, accent-color, etc.) live in
  dconf (binary), not a file — dumped to `gtk-interface.dconf`, restored by
  install.sh. Re-dump after changing it — but only from a machine that actually
  has the full curated settings applied (`dconf load` them first if unsure), or
  a re-dump will silently overwrite the tracked values with whatever's un-tuned
  on that machine:
  `dconf dump /org/gnome/desktop/interface/ > gtk-interface.dconf`.
  The GTK theme *files themselves* (referenced by name from that dump) are the
  separate `gtk-theme/` package.
- `hyprpaper.conf`'s wallpaper block and `random-wall.sh`'s fallback both use
  `monitor = *` (wildcard, matches any output) — previously hardcoded to
  `eDP-1` (one machine's laptop panel), which silently produced no wallpaper
  on any machine without that exact connector (e.g. a desktop's `HDMI-A-1`).
  `random-wall.sh` picks a random image from `~/Pictures/Wallpapers` +
  `~/Pictures/walls` (clone of [dharmx/walls](https://github.com/dharmx/walls),
  optional — skipped if not cloned on a given machine), persisting the choice
  via `source = ~/.cache/hypr/current-wall.conf`. That cache file is
  auto-seeded with a sane default by `hyprland.lua`'s autostart if missing —
  `hyprpaper`'s `source=` errors out hard (refuses to start at all) rather
  than falling back gracefully when the target file doesn't exist, which bit
  every fresh machine before the file had been generated once.
- hyprpaper 0.8.x has no working `preload`/`unload` IPC (only `wallpaper` — verified
  broken on 0.8.4 too, not just an old-version thing), so every switch is a
  synchronous decode inside the daemon. `random-wall.sh` masks this by flashing
  `Scripts/black.png` first. Also: `hl.config({ misc = { force_default_wallpaper,
  disable_hyprland_logo } })` in `hyprland.lua` must both be disabled, or Hyprland's
  built-in "anime mascot" fallback wallpaper flashes for a frame whenever hyprpaper's
  layer surface briefly disappears during a switch — easy to mistake for a decode
  bug, it isn't one.
- ghostty ANSI palette is tweaked (`palette = 2/10` green, `3/11` yellow→magenta) —
  see comments in `ghostty/.config/ghostty/config`.
- `environment.d/*.conf` env vars (incl. `SSH_AUTH_SOCK`) only reach processes
  started *via systemd activation* — a systemd user unit, or anything that
  goes through `systemctl --user`/D-Bus activation. LightDM execs Hyprland
  directly (`start-hyprland`), bypassing that entirely, so the graphical
  session — and everything launched from it (GUI apps, hyprland.lua binds)
  — never inherits `environment.d` vars no matter how many times you
  relogin/reboot. `ssh-agent.service` itself is fine either way (its
  `Environment=` is on the unit directly), but anything that needs to *use*
  the agent from inside the graphical session (e.g. Obsidian Git) needs the
  var set some other way — currently `hl.env("SSH_AUTH_SOCK", ...)` directly
  in `hyprland.lua`, resolved from `$XDG_RUNTIME_DIR` at config-load time.
- `~/.local/bin/backup` (systemd `backup.timer`, daily 20:00) snapshots configs +
  package lists to `~/backups/env_*.tar.gz`. Uses `pacman -Qqe`/`pacman -Qqem`
  for package lists — don't reintroduce `dpkg`/`snap` calls if porting from an
  older (Debian-era) version of this script.
