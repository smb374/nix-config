{ pkgs, ... }:
{
  imports = [ ./hardware.nix ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "poyehchen" ];
  };
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "smb374-nix";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-mozc
    ];
  };

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/F6A6-5D2F";
    fsType = "exfat";
    options = [
      "nofail"
      "uid=1000"
      "gid=100"
    ];
  };

  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
  programs.dms-shell.enable = true;
  programs.steam.enable = true;
  programs.fish.enable = true;

  # YubiKey via scdaemon's internal CCID driver; gpg-agent is the only SSH agent.
  hardware.gpgSmartcards.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  services.gnome.gcr-ssh-agent.enable = false;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    maple-mono.NF-CN
  ];

  users.users.poyehchen = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  system.stateVersion = "26.11";
}
