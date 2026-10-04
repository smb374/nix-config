-- Overrides for ~/.config/hypr/variables.lua (Caelestia dots); see that file for every key.
return {
    -- Apps
    terminal      = "foot",
    browser       = "zen-beta",
    editor        = "foot nvim",
    audioSettings = "pavucontrol-qt",

    -- Matches the dconf cursor in users/poyehchen/theming.nix.
    cursorTheme   = "Vanilla-DMZ",

    -- Default is suspend-then-hibernate; this system has no hibernation resume device.
    sleepGestureCmd = "systemctl suspend",
}
