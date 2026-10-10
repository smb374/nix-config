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
  # Wi-Fi regulatory domain: Taiwan. The global default (00) marks all 5 GHz channels no-IR,
  # which blocks AP mode there.
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=TW
  '';

  networking.hostName = "smb374-nix";
  networking.networkmanager.enable = true;
  # wlp7s0 is dedicated to the access point; keep NetworkManager off it.
  networking.networkmanager.unmanaged = [ "interface-name:wlp7s0" ];

  # Wi-Fi 6 access point: 5 GHz channel 149 at 80 MHz (149-161, center 155), WPA2.
  services.hostapd = {
    enable = true;
    radios.wlp7s0 = {
      band = "5g";
      channel = 149;
      countryCode = "TW";
      # Capabilities copied from `iw phy0 info`: HT 0x9ff, VHT 0x339071f6.
      wifi4.capabilities = [
        "HT40+"
        "LDPC"
        "GF"
        "SHORT-GI-20"
        "SHORT-GI-40"
        "TX-STBC"
        "RX-STBC1"
        "MAX-AMSDU-7935"
      ];
      wifi5 = {
        operatingChannelWidth = "80";
        capabilities = [
          "MAX-MPDU-11454"
          "VHT160"
          "RXLDPC"
          "SHORT-GI-80"
          "SHORT-GI-160"
          "TX-STBC-2BY1"
          "RX-STBC-1"
          "SU-BEAMFORMEE"
          "MU-BEAMFORMEE"
          "BF-ANTENNA-4"
          "MAX-A-MPDU-LEN-EXP7"
          "RX-ANTENNA-PATTERN"
          "TX-ANTENNA-PATTERN"
        ];
      };
      wifi6 = {
        enable = true;
        operatingChannelWidth = "80";
      };
      # The module sets the widths but not the 80 MHz center channel.
      settings = {
        vht_oper_centr_freq_seg0_idx = 155;
        he_oper_centr_freq_seg0_idx = 155;
      };
      networks.wlp7s0 = {
        ssid = "smb374-nix_AP";
        authentication = {
          mode = "wpa2-sha1";
          # PSK from wpa_passphrase; readable by anyone in the Nix store.
          wpaPskFile = pkgs.writeText "hostapd-wpa-psk" ''
            00:00:00:00:00:00 28d5aabe628b512367bcbc29bf3eceaf9304074a0bce7b7939568adebc774be0
          '';
        };
      };
    };
  };

  # AP side: static gateway address plus DHCP server via systemd-networkd.
  # NetworkManager keeps every other interface.
  # networkd enables systemd-resolved by default; keep it off so AdGuard Home stays
  # the only resolver and NetworkManager can keep dns = "none".
  services.resolved.enable = false;
  systemd.network = {
    enable = true;
    # NetworkManager-wait-online already gates network-online.target.
    wait-online.enable = false;
    networks."40-wlp7s0" = {
      matchConfig.Name = "wlp7s0";
      address = [ "192.168.12.1/24" ];
      networkConfig = {
        DHCPServer = true;
        # Keep the address while hostapd is down so AdGuard Home can bind it.
        ConfigureWithoutCarrier = true;
        IgnoreCarrierLoss = true;
      };
      dhcpServerConfig = {
        PoolOffset = 100;
        PoolSize = 100;
        EmitDNS = true;
        DNS = [ "192.168.12.1" ];
      };
      linkConfig.RequiredForOnline = "no";
    };
  };
  # Clients resolve through AdGuard Home on the gateway address.
  services.adguardhome.settings.dns.bind_hosts = [ "0.0.0.0" "::1" ];
  networking.firewall.interfaces.wlp7s0 = {
    allowedUDPPorts = [
      53 # DNS
      67 # DHCP
    ];
    allowedTCPPorts = [ 53 ];
  };
  networking.nat = {
    enable = true;
    internalInterfaces = [ "wlp7s0" ];
  };

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
