# NixOS side of the user: account, system-level programs, and the Hjem wiring.
# Everything under $HOME lives in ./home, which also works with the standalone `hjem` CLI
# (hjemConfigurations.poyehchen in flake.nix).
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  users.users.poyehchen = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "i2c"
      "tss"
      "ydotool"
    ];
    # GUI apps: they need the system GL/Vulkan drivers, which only NixOS provides
    # (standalone Hjem hosts would need NixGL). CLI tools stay in ./home.
    packages = with pkgs; [
      kitty
      foot
      brave-origin
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      imv
      lxqt.pavucontrol-qt
    ];
  };

  hjem.specialArgs = { inherit inputs; };
  hjem.users.poyehchen.imports = [ ./home ];

  programs.fish.enable = true;
  # fish only reads vendor plugin dirs linked into the system profile.
  environment.systemPackages = with pkgs.fishPlugins; [
    pure
    fzf-fish
  ];

  programs.direnv.enable = true;
  programs.zoxide = {
    enable = true;
    flags = [ "--cmd cd" ];
  };

  # Read by GTK on Wayland and by xdg-desktop-portal (dark-mode preference).
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3-dark";
        icon-theme = "Papirus-Dark";
        color-scheme = "prefer-dark";
        cursor-theme = "Vanilla-DMZ";
        cursor-size = lib.gvariant.mkInt32 24;
      };
    }
  ];
}
