# EndeavourOS Dotfiles TODO

## System Configuration

### Completed ✅
- [x] Alacritty terminal with FiraCode Nerd Font
- [x] Niri compositor with rounded corners (12px)
- [x] Qutebrowser config with autoconfig loading
- [x] Tmux session management
- [x] LUKS full-disk encryption
- [x] Zsh shell configuration

### High Priority 🔴
- [ ] Git configuration (user.name, user.email, aliases)
- [ ] Python development environment optimization
- [ ] Backup strategy for dotfiles (git repo)
- [ ] System update automation (pacman hooks)
- [ ] **Try carapace for zsh completions (soon).**
  Problem: pressing Tab on commands with no zsh completion definition falls back
  to `_default` → `_files`, dumping the current directory instead of showing
  flags/arguments. `carapace` is a spec-driven completion engine (~1000+ commands,
  can bridge zsh/fish/bash) — the closest thing to an "LSP" for the shell.
  - Plan: install `carapace` (AUR `carapace-bin`), then in `zsh/.config/zsh/.zshrc`
    (after `compinit`): `source <(carapace _carapace)`; optionally
    `export CARAPACE_BRIDGES='zsh,fish,bash'`.
  - Also consider `ZSH_AUTOSUGGEST_STRATEGY=(completion history)` so inline
    suggestions use context-aware completions.
  - Alternatives: `nodejs-inshellisense` (IDE overlay, heavier), per-tool
    `docker completion zsh` / `kubectl completion zsh` dumps.
  - Collisions/UX: rides normal Tab; add to `KEYBINDINGS.md` when adopted.

### Medium Priority 🟡
- [ ] Waybar configuration and theming
- [ ] Wallpaper management system improvements
- [ ] Terminal color scheme optimization
- [ ] Keybinding documentation
- [ ] Performance monitoring setup

### Browser / Default Applications 🟡
- [ ] **Domain whitelist: LibreWolf default, Firefox for sign-in domains.**
  Keep LibreWolf as the default browser, but route a whitelist of domains that
  require signing in (auth / MFA) to Firefox via a custom `xdg-open` / `BROWSER`
  wrapper. Rationale: Firefox holds the logged-in / MFA-completed sessions, so
  sending those domains to Firefox avoids redoing MFA every time.
  - Current state (2026-10-10): default browser temporarily set to
    `firefox.desktop` in `~/.config/mimeapps.list` (backup: `mimeapps.list.bak`).
    Target end state = LibreWolf default + Firefox-for-auth whitelist.
  - Candidate approach: a small `xdg-open` shim (or `BROWSER`) that matches the
    URL host against the whitelist and dispatches to `firefox` vs `librewolf`.

### Gotchas / Watch-outs 🚧
- [ ] **Never make `~/.config` a symlink (keep it a real directory).**
  On 2026-10-10 a dangling `~/.config -> ~/.dotfiles/config` symlink (while
  `~/.dotfiles` was moved aside) caused a running **Firefox** to recreate its
  profile and get a poisoned QuotaManager state: Browser Console spammed
  `NS_ERROR_FILE_READ_ONLY` / `IndexedDB ... DirectoryLockFailed`, and
  **Gemini was blank/black when signed in** (signed-out worked). Storage was
  actually fine; a **full quit + relaunch** (`pkill firefox`) cleared it.
  - If it recurs: `pkill firefox` then relaunch; if still broken,
    `rm -rf ~/.config/mozilla/firefox/<profile>/storage/{default,permanent,temporary}`.
  - Rule: `~/.config` must be a real dir (stow target), never a symlink.

### Low Priority 🟢
- [ ] Additional niri window rules
- [ ] Qutebrowser userscripts
- [ ] Shell aliases and functions
- [ ] Development tools installation (rg, fd, bat, etc.)
- [ ] Font management and fallbacks

## Development Environment

### Python/AI/ML Stack
- [ ] Virtual environment management (pyenv/conda)
- [ ] Jupyter notebook configuration
- [ ] AI tools integration (local LLM setup)
- [ ] Bias analysis toolkit optimization

### System Maintenance
- [ ] Log rotation configuration
- [ ] Disk cleanup automation
- [ ] Memory usage optimization
- [ ] Battery management (laptop-specific)

## Documentation
- [ ] System specs documentation
- [ ] Installation guide recreation
- [ ] Troubleshooting notes
- [ ] Performance benchmarks

## Deferred / Decisions

- [ ] **zsh plugin location: keep in the config dir (decided 2026-10-11).**
  Current: `ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"`, matching
  `radleylewis/zsh` upstream. Considered moving the plugin clones to the XDG
  data dir (`$XDG_DATA_HOME/zsh/plugins` -> `~/.local/share/zsh/plugins`) on the
  rationale that plugins are downloaded data, not hand-edited config, and
  `~/.config` should hold only configuration.
  - **Decision: not doing it for now.** Keeping parity with upstream
    (`radleylewis/zsh` keeps them in `$ZDOTDIR/plugins`); the current stow setup
    already keeps plugin clones out of the dotfiles repo (they are a local,
    untracked dir at `~/.config/zsh/plugins`).
  - If revisited: set
    `ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"` in
    `zsh/.config/zsh/plugins.zsh`, then
    `mkdir -p ~/.local/share/zsh && mv ~/.config/zsh/plugins ~/.local/share/zsh/plugins`,
    `exec zsh`, and commit the `plugins.zsh` change.
  - Note: this becomes a deliberate local divergence from `radleylewis/zsh`, so
    keep a comment in `plugins.zsh` for future upstream diffs.

---
*Last updated: $(date)*
*System: EndeavourOS (Arch Linux) on Lenovo IdeaPad 5 Pro*