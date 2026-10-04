-- Overrides for ~/.config/hypr/variables.lua (Caelestia dots); see that file for every key.
return {
  -- Apps
  terminal                   = "foot",
  browser                    = "zen-beta",
  editor                     = "foot nvim",
  audioSettings              = "pavucontrol-qt",

  -- Matches the dconf cursor in users/poyehchen/theming.nix.
  cursorTheme                = "Vanilla-DMZ",

  -- Default is suspend-then-hibernate; this system has no hibernation resume device.
  sleepGestureCmd            = "systemctl suspend",

  windowOpacity = 1.0,

  ------------------
  ---- KEYBINDS ----
  ------------------

  -- Modifier only, the actual binds will be mod + 0-9. These should be strings and not arrays.
  kbGoToWs                   = "SUPER",
  kbGoToWsGroup              = "CTRL + SUPER",
  kbMoveWinToWs              = "SUPER + ALT",
  kbMoveWinToWsGroup         = "CTRL + SUPER + ALT",

  -- Apps
  kbTerminal                 = "SUPER + Return",

  -- Misc
  kbLauncher                 = "SUPER + Space",
}
