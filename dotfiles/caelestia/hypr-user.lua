-- Personal Hyprland config, loaded last by ~/.config/hypr/hyprland.lua (Caelestia dots).
-- Options the dots expose as variables go in hypr-vars.lua instead.

-- Scrolling layout; the dots' general.lua already tunes its `scrolling` section.
hl.config({ general = { layout = "scrolling" } })

-- Switch workspaces vertically, like niri, and faster than the dots' speed 5 (speed is in 100 ms units).
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "standard", style = "slidevert" })

-- The dots' kill/restart binds run `qs -c caelestia`, which the nixpkgs shell does not provide.
hl.unbind("CTRL + SUPER + SHIFT + R")
hl.unbind("CTRL + SUPER + ALT + R")
hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("caelestia shell -k"), { release = true })
hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("caelestia shell -r"), { release = true })

-- The dots send only discord|equibop|vesktop to the communication workspace; add Legcord.
-- A direct rule: the dots' tag definitions must follow every tagging, and this file loads last.
hl.window_rule({ match = { class = "legcord" }, workspace = "special:communication" })

-- Monitors
hl.monitor({
  output = "desc:BNQ BenQ EL2870U R5M00386SL0",
  mode = "3840x2160",
  scale = 1.5,
})
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.bind("SUPER + mouse_left", hl.dsp.layout("focus l"))
hl.bind("SUPER + mouse_right", hl.dsp.layout("focus r"))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.layout("focus l"))
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.layout("focus r"))
