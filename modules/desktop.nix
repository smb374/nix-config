{ pkgs, ... }:
{
  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
  programs.dms-shell.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-mozc
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    maple-mono.NF-CN
    maple-mono.NL-NF-CN
  ];

  # Theming: colors come from the Basix scheme in users/poyehchen/theming.nix.
  # Qt follows the GTK3 theme (adw-gtk3 + Basix gtk.css) via qtbase's built-in gtk3 platform theme.
  qt.enable = true;
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
  };
  environment.systemPackages = with pkgs; [
    adw-gtk3
    papirus-icon-theme
    kdePackages.qqc2-desktop-style
    gearlever
  ];

  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-volman ];
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  # No capSysNice: its ambient CAP_SYS_NICE breaks Steam's bwrap in the gamescope session.
  programs.gamescope.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-gstreamer
      obs-vaapi
    ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
