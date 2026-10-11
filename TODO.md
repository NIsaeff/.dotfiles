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

---
*Last updated: $(date)*
*System: EndeavourOS (Arch Linux) on Lenovo IdeaPad 5 Pro*