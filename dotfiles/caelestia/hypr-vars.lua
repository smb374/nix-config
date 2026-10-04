-- Overrides for ~/.config/hypr/variables.lua (Caelestia dots); see that file for every key.
return {
  -- Apps
  terminal                   = "foot",
  browser                    = "zen-beta",
  editor                     = "foot nvim",
  audioSettings              = "pavucontrol-qt",

  -- Matches the dconf cursor in users/poyehchen/default.nix.
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

  -- niri-style: SUPER + F maximizes the column (layout-aware "maximized" in the scrolling
  -- layout), SUPER + SHIFT + F is real fullscreen.
  kbWindowBorderedFullscreen = "SUPER + F",
  kbWindowFullscreen         = "SUPER + SHIFT + F",

  -- Apps
  kbTerminal                 = "SUPER + Return",

  -- Misc
  kbLauncher                 = "SUPER + Space",
}
