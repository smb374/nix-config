-- Personal Hyprland config, loaded last by ~/.config/hypr/hyprland.lua (Caelestia dots).
-- Options the dots expose as variables go in hypr-vars.lua instead.

-- Scrolling layout; the dots' general.lua already tunes its `scrolling` section.
hl.config({ general = { layout = "scrolling" } })

-- The dots' kill/restart binds run `qs -c caelestia`, which the nixpkgs shell does not provide.
hl.unbind("CTRL + SUPER + SHIFT + R")
hl.unbind("CTRL + SUPER + ALT + R")
hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("caelestia shell -k"), { release = true })
hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("caelestia shell -r"), { release = true })
