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

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # NVMe root (ext4): skip access-time writes. TRIM runs weekly via services.fstrim
  # (enabled by default) instead of the `discard` mount option.
  fileSystems."/".options = [ "noatime" ];

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/F6A6-5D2F";
    fsType = "exfat";
    options = [
      "nofail"
      "uid=1000"
      "gid=100"
    ];
  };

  system.stateVersion = "26.11";
}
