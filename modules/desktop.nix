{ pkgs, ... }:
{
  services.displayManager.ly.enable = true;

  # Hyprland + Caelestia shell. The shell starts from the dots' Hyprland config.
  # UWSM gives a systemd graphical session: user services and XDG autostart (fcitx5) run there.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  # This file replaces Hyprland's packaged hyprland-portals.conf, so it restates the default.
  xdg.portal.config.hyprland = {
    default = [
      "hyprland"
      "gtk"
    ];
    "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  };
  services.gnome.gnome-keyring.enable = true;
  # Polkit agent as a user service; the dots' polkit-gnome exec uses an Arch path.
  security.soteria.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Night light: the dots exec gammastep, which reads the location from geoclue.
  services.geoclue2 = {
    enable = true;
    appConfig.gammastep = {
      isAllowed = true;
      isSystem = false;
    };
  };

  # The dots' paste-latest-clipboard bind types through ydotool.
  programs.ydotool.enable = true;

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
    nerd-fonts.jetbrains-mono
  ];

  # Theming: colors come from the Basix scheme in users/poyehchen/theming.nix.
  qt.enable = true;
  environment.variables.QT_QPA_PLATFORMTHEME = "qtengine";
  environment.systemPackages = with pkgs; [
    adw-gtk3
    papirus-icon-theme
    vanilla-dmz
    qtengine
    darkly
    kdePackages.qqc2-desktop-style
    gearlever

    # Commands the Caelestia dots run.
    caelestia-shell
    caelestia-cli
    cliphist
    trash-cli
    hyprpicker
    gammastep
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
