# KEYBINDINGS.md

A cross-layer map of keyboard shortcuts in this setup, and the policy we use to
keep them from colliding.

The goal is **zero contention**: design the key space so no two layers that can be
active at the same time ever want the same key. An overlap is a **defect to fix**,
not a ruling to make. We do not "let the outer system win" — we remap until the
overlap is gone.

---

## 1. The model

Key events travel down a single **focus path**, outermost first. Each node either
consumes the key or passes it through to the node below.

```
┌───────────────────────────────────────────────────────────────┐
│ niri        (compositor)   namespace:  Super (Mod)            │
│  └ alacritty (terminal)    namespace:  (none)                 │
│     └ zellij (multiplexer) namespace:  Ctrl+<letter> cluster  │
│        └ zsh (shell)       namespace:  Ctrl / Alt+<letter>    │
│           └ nvim (editor)  namespace:  Space (leader)         │
└───────────────────────────────────────────────────────────────┘
        ▲ outermost consumes first              innermost last ▼
```

Key facts:

- **Only the focus path matters.** Other windows / panes / tabs are *siblings*;
  only one subtree is live at a time, so reusing a key in a different subtree is
  safe. This is why the same `Ctrl+C` in two different apps is fine.
- **Modes qualify a node.** A binding is really `(node, mode) -> action`.
  Examples: zellij `normal/locked/scroll/search`; zsh vi-mode `insert/normal`;
  nvim modes; niri's overview. Two keys can coexist at the *same* node if they
  live in different modes.
- **The tree is a diagnostic lens, not a runtime system.** We are not building a
  remapper or an enforcement layer. We use the tree to *reason about where a
  collision comes from* and then fix it by remapping.

### The default (a bug, normally)

Out of the box, the **outermost node that binds a key wins**. That is how
accidental collisions happen (e.g. zellij grabbing `Ctrl+T` so the shell never
sees it). We treat every such overlap as a defect below.

---

## 2. Principles

1. **Zero contention by construction.** Prefer disjoint namespaces so layers never
   compete. Fix overlaps by moving one side, not by choosing a winner.
2. **Only the focus path collides.** Sibling isolation means reuse across separate
   apps/panes is expected and fine.
3. **Partition the space by layer** (see §3). Each layer owns a principal
   namespace; new bindings should land in *that layer's* namespace.
4. **Remap the less-contextual layer.** If a collision is unavoidable, the layer
   whose action is less tied to context moves off the key.
5. **Prefer passthrough/modal states** over fighting: zellij *locked*, vi-mode,
   nvim autolock — these let inner layers keep their keys.
6. **Record everything** so intent survives and defects aren't rediscovered.

---

## 3. Key-space partition (the design)

The intended, non-overlapping allocation:

| Layer | Principal namespace | Notes |
|---|---|---|
| niri (compositor) | `Super` (Mod) + modifiers | `Mod+…`, `Mod+Ctrl+…`, `Mod+Shift+…`; also `Ctrl+Alt+Del` |
| zellij (multiplexer) | `Ctrl+<letter>` mode cluster + `Alt+hjkl` nav | ideally shrink toward a single leader (`Ctrl+Space`) |
| zsh (shell) | `Ctrl+<letter>` (readline tradition) + `Alt+<letter>` (widgets) | widget convention: `Alt+<letter>` |
| nvim (editor) | `Space` (leader) | plugin maps are leader-based |

**Rule of thumb:** `Super` → niri · `Ctrl+<letter>` → zellij/zsh builtins ·
`Alt+<letter>` → shell widgets · `Space` → nvim.

**Namespace is contested:** `Ctrl+<letter>` is shared between zellij's mode
cluster and zsh/readline. This is the single biggest source of contention and the
main target for the "shrink zellij to a leader" work in §5.

---

## 4. Layer inventory

### niri — `niri/cfg/keybinds.kdl`
`Mod` = Super.

| Binding | Action |
|---|---|
| `Mod+Return` | alacritty |
| `Mod+Ctrl+Return` | noctalia launcher |
| `Mod+B` | firefox |
| `Mod+E` | nautilus |
| `Mod+Alt+L` | noctalia lock |
| `Mod+Shift+Q` | noctalia session menu |
| `Mod+Q` | close window |
| `Mod+{H,J,K,L}` / `Mod+{Left,Right,Up,Down}` | focus column/window |
| `Mod+Ctrl+{H,J,K,L}` / arrows | move column/window |
| `Mod+Home` / `Mod+End` | focus first/last column |
| `Mod+Ctrl+Home` / `Mod+Ctrl+End` | move to first/last column |
| `Mod+Shift+arrows` | focus monitor |
| `Mod+Shift+Ctrl+arrows` | move column to monitor |
| `Mod+WheelScroll*` (+`Ctrl`/`Shift`) | workspace / column scroll |
| `Mod+1..9` | focus workspace |
| `Mod+Ctrl+1..9` | move column to workspace |
| `Mod+Tab` | previous workspace |
| `Mod+C` / `Mod+Ctrl+C` | center column / center visible columns |
| `Mod+Ctrl+F` | expand column to available width |
| `Mod+Minus` / `Mod+Equal` | column width ∓/± |
| `Mod+Shift+Minus` / `Mod+Shift+Equal` | window height ∓/± |
| `Mod+T` | toggle floating |
| `Mod+F` | fullscreen |
| `Mod+W` | toggle tabbed display |
| `Mod+S` / `Mod+Ctrl+S` / `Mod+Alt+S` | screenshot region / window / full |
| `Mod+O` | overview |
| `Mod+Shift+P` | power off monitors |
| `Mod+Escape` | toggle keyboard-shortcuts-inhibit |
| `Mod+Shift+Escape` | show hotkey overlay |
| `Ctrl+Alt+Delete` | quit |
| `XF86Audio*`, `XF86MonBrightness*` | media / brightness (allow-when-locked) |

### zellij — `zellij/config.kdl` (`keybinds clear-defaults=true`)

Global (present in almost every mode):

`Ctrl+g` locked · `Ctrl+q` quit · `Ctrl+h` move · `Ctrl+o` session ·
`Ctrl+b` tmux · `Ctrl+s` scroll · `Ctrl+t` tab · `Ctrl+p` pane · `Ctrl+n` resize

`Alt` cluster: `Alt+arrows`, `Alt+h/i/j/k/l/n/o/p`, `Alt+[/]`, `Alt+±/=`,
`Alt+Shift+p`, `Alt+f`.

Per-mode keys (single letters, only while that mode is active): pane, tab, resize,
move, scroll, search, session, tmux. See `zellij/config.kdl`.

### zsh — `zsh/.config/zsh/bindings.zsh`, `fzf.zsh`

| Binding | Action | Mode |
|---|---|---|
| `Ctrl+R` | fzf fuzzy history | all |
| `Ctrl+T` | fzf file picker (incl. hidden) | all |
| `Ctrl+F` | fzf file picker (no hidden) | all |
| `Ctrl+\` | toggle autosuggestions | all |
| `Ctrl+Right` / `Ctrl+Left` | forward/backward word | all |
| `Up` / `Down` | history-substring-search | all |

All of the above (except the fzf `Ctrl+R`/`Ctrl+T` sourced by fzf's integration)
are registered inside `zvm_after_init()` because **zsh-vi-mode resets keybindings
on init** — see D-000.

### nvim — LazyVim (leader = `Space`)
Leader-based maps (`<leader>…`), plus mode-local defaults. Introspect with `:map`
and `:verbose map <key>`; browse with which-key (`Space`).

---

## 5. Defect register

Overlaps that break the zero-contention goal. Each has an owner decision and a
status. **Target state: no OPEN rows.**

### OPEN

| ID | Key | Conflict | Layers | Proposed fix |
|---|---|---|---|---|
| D-001 | `Ctrl+T` | zellij *tab* mode consumes it, so the shell's fzf file picker never fires | zellij ⊃ zsh | Remap the shell file pickers to `Alt+<key>` (matches the widget convention), **or** free zellij's `Ctrl+t` |
| D-002 | `Ctrl+G` | zellij *locked* mode owns it; unusable for shell widgets | zellij | Do not use `Ctrl+G`; use `Alt+G` for the planned fuzzy-grep widget |
| D-003 | `Ctrl+<letter>` cluster | zellij's mode cluster overlaps the shell/readline `Ctrl` space | zellij ⊃ zsh | Shrink zellij toward a single leader (`Ctrl+Space`) + `Alt+hjkl`, freeing `Ctrl+{g,q,h,o,b,s,t,p,n}` |

### RESOLVED

| ID | Key | Problem | Resolution |
|---|---|---|---|
| D-000 | `Ctrl+R` | zsh-vi-mode resets keymaps on init, reverting `Ctrl+R` to `history-incremental-search-backward` (the `bck-i-search:` prompt) | Re-bound `bindkey '^R' fzf-history-widget` (and `^T`) inside `zvm_after_init()` in `bindings.zsh`. Commit: *zsh: rebind Ctrl+R/Ctrl+T after zsh-vi-mode init* |

> D-000 is a **within-node** collision (a plugin resetting a node's own keymap),
> not a cross-layer one — but it presents identically to the user, so it lives here.

---

## 6. Accepted overlaps (do not "fix")

Intentional or unavoidable, recorded so they stop looking like defects:

- `Ctrl+C` — SIGINT to the shell. zellij binds `Ctrl+c` only inside `scroll`/`search`
  modes (modal), so it does not contend on the normal path.
- `Ctrl+Z`, `Ctrl+D`, `Ctrl+S`/`Ctrl+Q` — job control / EOF / flow control; leave
  to the shell/terminal.
- `Ctrl+Alt+Delete` — session quit (niri).
- `XF86*` media & brightness keys — owned globally by niri.
- Global-shortcut portals / push-to-talk style app shortcuts — outside the focus
  path; accepted.

---

## 7. Diagnosis procedure

To find *where* a key is consumed, walk the focus path top-down and check each
layer's config, then watch what actually reaches the innermost node.

```sh
# Does a layer mention the key? (search each config, outermost first)
grep -n "Ctrl g"  ~/.config/zellij/config.kdl
grep -n "Ctrl+F"  ~/.config/niri/cfg/keybinds.kdl
grep -rn "Ctrl+R" ~/.config/zsh/*.zsh

# zsh: what is actually bound right now
bindkey -L              # all keymaps
bindkey -M viins '^R'   # a specific key/map

# zellij: dump/validate config
zellij setup --dump-config
zellij setup --check

# niri: built-in visual listing + validate
#   press Mod+Shift+Escape  (hotkey overlay)
niri validate -c ~/.config/niri/config.kdl

# nvim: list maps
#   :map  /  :verbose map <key>

# See what PASSES THROUGH to a client (the decisive test)
wev            # Wayland event viewer (needs: wev-git, AUR) - run in the target app/pane
showmethekey   # on-screen key display (AUR) - good for recording/demos
```

Pragmatic shortcut: run the key in the target context while watching `wev` (or
`wshowkeys`) — if the event never arrives, an ancestor consumed it.

---

## 8. Adding a new binding — checklist

1. **Pick the layer** where the action is most contextual.
2. **Use that layer's namespace** (§3): niri→`Super`, zellij→its prefix,
   shell→`Ctrl`/`Alt+<letter>`, nvim→`Space`.
3. **Search every ancestor** for that key: `grep` the configs (§7), and check §5/§6.
4. **Confirm sibling isolation:** does it only need to work in one subtree? Then
   reuse is fine.
5. **Check node-level resets** (D-000 class): if it's a zsh binding, register it in
   `zvm_after_init()`.
6. **Record it here:** add to §4, or file a defect in §5 if it overlaps.
7. **Verify** with the §7 procedure, especially inside zellij.

---

*Concept, not runtime. The tree is how we think; the registers are how we stay at
zero contention.*
