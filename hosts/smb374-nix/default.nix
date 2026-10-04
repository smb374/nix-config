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

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    # Windows lives on its own ESP (nvme1n1p1); match it by GPT partition GUID.
    extraEntries = ''
      /Windows Boot Manager
      comment: Windows Boot Manager
      comment: order-priority=20
      protocol: efi
      path: guid(1207444c-8417-46bb-be2e-bac19c74631f):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
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

  # MY_MEDIA btrfs disk (old Arch install): one subvolume per media type.
  fileSystems = {
    "/media/music" = {
      device = "/dev/disk/by-label/MY_MEDIA";
      fsType = "btrfs";
      options = [
        "subvol=@music"
        "noatime"
        "nofail"
      ];
    };
    "/media/videos" = {
      device = "/dev/disk/by-label/MY_MEDIA";
      fsType = "btrfs";
      options = [
        "subvol=@videos"
        "noatime"
        "nofail"
      ];
    };
    "/home/poyehchen/Videos" = {
      device = "/media/videos";
      fsType = "none";
      options = [
        "bind"
        "nofail"
      ];
      depends = [ "/media/videos" ];
    };
  };
  # Subvolume roots owned by the user so rsync needs no root.
  systemd.tmpfiles.rules = [
    "d /media/music 0755 poyehchen users -"
    "d /media/videos 0755 poyehchen users -"
  ];

  system.stateVersion = "26.11";
}
