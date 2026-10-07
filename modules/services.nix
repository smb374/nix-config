{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  # Resolve short image names (e.g. `podman pull alpine`) against Docker Hub.
  virtualisation.containers.registries.settings.unqualified-search-registries = [ "docker.io" ];
  environment.systemPackages = [
    pkgs.podman-compose
    pkgs.proton-vpn-cli
  ];

  # Trash, MTP, SMB, etc. for Thunar; thumbnails.
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  services.flatpak = {
    enable = true;
    packages = [ "org.freedownloadmanager.Manager" ];
  };
  # User service: a system service has no access to the user's PipeWire session.
  systemd.user.services.squeezelite = {
    description = "Software Squeezebox emulator";
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" ];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe pkgs.squeezelite)
        "-n"
        "smb374_nix"
        "-s"
        "127.0.0.1"
        "-o"
        "pipewire"
        "-Z"
        "384000"
      ];
      Restart = "on-failure";
    };
  };
  # MPRIS bridge for the squeezelite player above (reports position and duration).
  systemd.user.services.slimpris2 = {
    description = "Squeezebox MPRIS remote control";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "squeezelite.service" ];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe (pkgs.callPackage ../pkgs/slimpris2.nix { }))
        "127.0.0.1"
        "9000"
        "smb374_nix"
      ];
      Restart = "on-failure";
    };
  };

  # Lyrion Music Server (backend: podman, the NixOS default).
  virtualisation.oci-containers.containers.lms = {
    image = "docker.io/lmscommunity/lyrionmusicserver:latest";
    volumes = [
      "/var/lib/lms/config:/config:rw"
      "/media/music:/music:ro"
      "/var/lib/lms/playlist:/playlist:rw"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment.HTTP_PORT = "9000";
    extraOptions = [ "--network=host" ];
  };
  # compose `restart: always`; the module defaults to on-failure.
  systemd.services.podman-lms.serviceConfig.Restart = lib.mkForce "always";
  systemd.tmpfiles.rules = [
    "d /var/lib/lms/config 0755 root root -"
    "d /var/lib/lms/playlist 0755 root root -"
  ];
  # Local DNS resolver with ad blocking; this host's only nameserver.
  # Listens on loopback only (podman's aardvark-dns owns :53 on its bridge).
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1"; # web UI: http://127.0.0.1:3000
    settings = {
      dns = {
        bind_hosts = [
          "127.0.0.1"
          "::1"
        ];
        port = 53;
        upstream_dns = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
        ];
        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
      filters =
        map
          (url: {
            enabled = true;
            url = url;
          })
          [
            # Default
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"
            # General ones
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt" # Phishing Army
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt" # AdGuard DNS Popup Hosts filter
            # Regional
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt" # CHN: AdRules DNS List
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_29.txt" # CHN: anti-AD
          ];
      # GitHub's Fastly download domains publish no AAAA record, so a device
      # with working IPv6 still downloads over HiNet's congested IPv4 path to
      # Fastly. Supply the IPv6 addresses GitHub itself announces in
      # 2606:50c0::/32. $dnstype=AAAA leaves A queries untouched, which keeps
      # clients that have no IPv6 working. Remove this block once
      # getent ahostsv6 release-assets.githubusercontent.com returns a native
      # address instead of ::ffff:185.199.108.133.
      user_rules =
        lib.concatMap
          (
            host:
            map (addr: "||${host}^$dnstype=AAAA,dnsrewrite=NOERROR;AAAA;${addr}") [
              "2606:50c0:8000::154"
              "2606:50c0:8001::154"
              "2606:50c0:8002::154"
              "2606:50c0:8003::154"
            ]
          )
          [
            "release-assets.githubusercontent.com"
            "objects.githubusercontent.com"
            "github-cloud.githubusercontent.com"
            "gist.githubusercontent.com"
            "private-user-images.githubusercontent.com"
            "camo.githubusercontent.com"
          ];
    };
  };
  # NetworkManager stops writing DHCP-provided DNS; resolv.conf points at AdGuard Home.
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];

  # Host networking: web UI/JSON-RPC (9000), CLI (9090), SlimProto player discovery (3483).
  networking.firewall = {
    allowedTCPPorts = [
      9000
      9090
      3483
    ];
    allowedUDPPorts = [ 3483 ];
  };
}
