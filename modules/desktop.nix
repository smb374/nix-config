{ pkgs, ... }:
let
  # qt6ct with the AUR qt6ct-kde patch: KDE color schemes and icon engine support.
  qt6ct-kde = pkgs.qt6Packages.qt6ct.overrideAttrs (old: {
    pname = "qt6ct-kde";
    patches = (old.patches or [ ]) ++ [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/archlinux/aur/8c1003e13b7e7545e717273e0716f095f195bd13/qt6ct-shenanigans.patch";
        hash = "sha256-uqsrcUrUkN46Eu3V1OwPYiPt7QNNZqaUmJ50a4bR9CA=";
      })
    ];
    buildInputs =
      old.buildInputs
      ++ (with pkgs.kdePackages; [
        kconfig
        kcolorscheme
        kiconthemes
        qtdeclarative
      ]);
  });
in
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
  qt.enable = true;
  environment.variables.QT_QPA_PLATFORMTHEME = "qt6ct";
  environment.systemPackages = with pkgs; [
    adw-gtk3
    papirus-icon-theme
    vanilla-dmz
    qt6ct-kde
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
