# ycode-tweaks

[drew-council/zed-config](https://github.com/drew-council/zed-config) ported to a ycode
Lua plugin (`tweaks.x.lua`):

- settings.json goes into ycode's in-memory plugin layer through `ycode.settings{}`:
  Catppuccin theme and icons, vim mode, VSCode base keymap, left-docked panels, agent on
  the right, autosave, auto-installed extensions and per-language options. Nothing is
  written to disk, and the user's settings.json still overrides it.
- keymap.json bindings come from `%hookf keymap::user`. They are prepended, so your own
  keymap.json wins.
- The lazygit task (`ctrl-shift-space`) comes from `%hookf tasks::global`.

Changes from upstream:

- The terminal shell is set to `nu` only when nu is installed.
- `edit_predictions.provider = "zed"` is dropped. It needs a zed.dev sign-in and would
  override ycode-offline.
- The sample "Example task" and the nix flake/treefmt/pre-commit tooling are left out.

## Install

    ln -s "$PWD" ~/.config/zed/hooks/ycode-tweaks

then run "ycode: reload hooks".

GPL-3.0, like upstream.
