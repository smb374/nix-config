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

-- Screenshots with grim, replacing the dots' shell UI (its save button does not work).
-- `pick` is shell code that sets grim's arguments with `set --`, or exits to cancel.
-- Each shot is saved to ~/Pictures/Screenshots/<date>.<kind>.png and copied to the clipboard.
local function shot(kind, pick)
  return hl.dsp.exec_cmd("sh -c '\n" .. pick .. [[

  dir="$HOME/Pictures/Screenshots"
  mkdir -p "$dir"
  f="$dir/$(date +%F_%T).]] .. kind .. [[.png"
  grim "$@" "$f" && wl-copy < "$f"
']])
end

local pick_all = "set --"
local pick_output = [[set -- -o "$(hyprctl monitors -j | jq -r ".[] | select(.focused).name")"]]
local pick_region = [[geom=$(slurp) || exit 0; set -- -g "$geom"]]
-- hyprpicker freezes the screen under slurp; it is killed once the selection is done.
local pick_freeze = [[
  hyprpicker -r -z & p=$!
  sleep 0.3
  geom=$(slurp)
  kill $p
  [ -n "$geom" ] || exit 0
  set -- -g "$geom"]]
-- Visible windows only: mapped, not hidden, on a visible workspace.
local pick_window = [[
  ws=$(hyprctl monitors -j | jq "[.[].activeWorkspace.id, (.[].specialWorkspace.id | select(. != 0))]")
  geom=$(hyprctl clients -j \
    | jq -r --argjson ws "$ws" ".[] | select(.mapped and (.hidden | not) and ([.workspace.id] | inside(\$ws))) | \"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])\"" \
    | slurp -r) || exit 0
  set -- -g "$geom"]]

for _, key in ipairs({ "Print", "CTRL + Print", "SUPER + SHIFT + S", "SUPER + SHIFT + ALT + S" }) do
  hl.unbind(key)
end
hl.bind("Print", shot("full", pick_all), { locked = true })
hl.bind("CTRL + Print", shot("output", pick_output), { locked = true })
hl.bind("SUPER + SHIFT + S", shot("region", pick_freeze))
hl.bind("SUPER + SHIFT + ALT + S", shot("region", pick_region))
hl.unbind("SUPER + SHIFT + W")
hl.bind("SUPER + SHIFT + W", shot("select", pick_window))
