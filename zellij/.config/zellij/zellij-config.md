# Zellij Configuration

Working notes for this zellij setup: the intent, how zellij names things, the
options we weighed, and the decisions still open.

> Status: **design/discussion** (2026-10-10). Not all of this is implemented yet.
> Config: `zellij/.config/zellij/config.kdl` (stowed to `~/.config/zellij`).
> Key collision policy lives in the repo root `KEYBINDINGS.md`.

---

## 1. Intent / goals

**Domain:** situational awareness + vim-native flow inside the terminal workspace.

- **Tabs** = "which context/project am I in" → a **glanceable directory name** by default.
- **Panes** = "what is this pane *doing*" → directory by default, escalating to
  **activity** when meaningful:
  - editor → the **file** being edited
  - a long-running service (backend / frontend / db) → the **process/service name**, abbreviated
- **Scrollback** = review output and **yank text with vim muscle-memory**, not the mouse.

**Constraints**
- **Minimal / no framework** (radleylewis ethos) → prefer terminal-native mechanisms over plugins.
- **No keybinding collisions** (see `KEYBINDINGS.md`): niri owns `Super`, zellij owns the
  `Ctrl+<letter>` mode cluster, shell owns `Ctrl`/`Alt+<letter>`, nvim owns `Space`.
- **Reproducible via dotfiles** (currently the `laptop` branch; ideally general enough for VMs later).

**Central tension:** rich auto-labelling usually wants a WASM plugin; minimalism prefers
**terminal-title (OSC) emission + shell hooks**. Current lean: the latter.

---

## 2. Mental model: how zellij shows names

Zellij does **not compute** a name for a pane — it **displays the terminal title** the
program in the pane emits, falling back to the running command name when nothing emits.

There are **two mechanisms**, and you should pick **one** per pane:

| Mechanism | Who sets it | Behaviour |
|---|---|---|
| **OSC title** (`printf '\e]2;TEXT\a'`) | the program in the pane (zsh, nvim, service) | zellij displays it; last emitter wins |
| **`zellij action rename-pane NAME`** | you / a script (zellij-native) | **pins** the name and **stops honouring OSC** for that pane |

**Decision (panes): use OSC emission**, not `rename-pane` — minimal, idiomatic, composable.

**Layering (OSC):** only the **foreground** process on the pane's PTY emits; the last
emission wins.
- idle shell → zsh `precmd` emits the **directory**
- running a command → zsh `preexec` emits the **command**
- launch nvim → nvim emits the **file** (`set title titlestring=...`)
- nvim exits → zsh `precmd` re-emits the directory
- a service → emits its own title **iff it stays foreground** (a backgrounded/`&` job does
  not — the shell stays foreground and the pane keeps the shell's title)

**Tabs have no OSC path.** Zellij cannot derive a tab name from a pane's title, so tab
naming is a *separate* problem (shell hook or plugin — see §4).

---

## 3. Pane naming (planned)

Enable title emission; let zellij display it.

- **zsh**: set the title in `precmd` (directory) and `preexec` (running command). None
  today; starship does not set a title.
- **nvim**: `title` is **off by default** → set `set title` + `titlestring` so the pane shows
  the edited file.
- **services**: emit `\e]2;<name>\a` at launch (via a wrapper/alias) and keep the process
  **foreground** in the pane; abbreviations live in the wrapper name.

Abbreviation ideas: `backend`→`be`, `frontend`→`fe`, `database`→`db`, `postgres`→`pg`.

---

## 4. Tab naming (OPEN — shell hook vs plugin)

| | Approach | Trade-off |
|---|---|---|
| **A1** | zsh `precmd`: if `$ZELLIJ` set → `zellij action rename-tab "$(basename $PWD)"` | Minimal, no plugin; renames the **focused** tab, so it follows the last shell that prompted (mild thrash with several panes) |
| **A2** | WASM plugin: `zellij-tabula` or `zellij-smart-tabs` (Jinja-like templates) | Richest (per-cwd / per-command), but adds a plugin + a second config surface |

Lean: **A1**.

---

## 5. Scrollback & copy (Ctrl+S)

- `Ctrl+S` → enter **scroll mode** (already bound; zellij owns `Ctrl+S`).
- In scroll mode: `j/k` line, `u/d` half-page, `PageUp/PageDown`, `s` → search,
  **`e` → EditScrollback** (opens *this pane's* scrollback in `$EDITOR` = nvim).
- Keyboard-only "select and yank" is **not native**; the vim-native answer is
  **`Ctrl+S` then `e`** → edit the scrollback in nvim → yank as usual.
- Mouse selection copies (OSC52; alacritty supports it). `copy_command "wl-copy"` /
  `copy_clipboard` are available on Wayland if needed.
- Possible minimal additions (modal, no collisions): `g`/`G` → top/bottom.
- Scripting capture: `zellij action dump-screen`, `zellij subscribe`.

---

## 6. Keybindings & collisions

- `Ctrl+S` is zellij's scroll key and already in the reserved set — no change.
- New **single-letter scroll-mode** binds (`g`, `G`) are **modal** → isolated, consistent
  with the zero-contention model in `KEYBINDINGS.md`.
- Current zellij global cluster (for reference): `Ctrl+{g,q,h,o,b,s,t,p,n}` +
  `Alt+{arrows,f,h,i,j,k,l,n,o,p,[,],±,=}`.

---

## 7. Current config facts

- `keybinds clear-defaults=true` (only what's defined is active).
- Modes: `locked / pane / tab / resize / move / scroll / search / session / tmux`.
- `scroll` mode today: `e` = EditScrollback, `s` = search; shared scroll/search keys
  `d/u/h/j/k/l`, `Ctrl+b/c/f/s`, `PageUp/PageDown`.
- Plugins loaded: `zellij:tab-bar`, `zellij:status-bar`, `zellij:compact-bar`,
  `zellij:link` (+ `zellij:strider` filepicker alias).
- `pane_frames` default (true); `simplified_ui` commented off.

---

## 8. Open decisions

1. **Tab naming:** A1 shell hook (lean) vs A2 plugin.
2. **Pane naming:** confirm OSC route (needs titles in zsh + nvim).
3. **Services:** do you run services **foreground in an attached pane** (so titles work),
   or detached (titles won't reflect them)?
4. **Scroll extras:** keep just `Ctrl+S`+`e`, or add `g`/`G` (and any others)?

## 9. References

- Zellij keybindings/modes: https://zellij.dev/documentation/keybindings-modes.html
- Zellij CLI actions: https://zellij.dev/documentation/cli-actions.html
- Edit scrollback (`Ctrl+S`,`e`): https://zellij.dev/news/edit-scrollback-compact/
- Auto tab naming discussion: https://github.com/zellij-org/zellij/discussions/5000
- Auto pane naming (OSC) discussion: https://github.com/zellij-org/zellij/discussions/2848
