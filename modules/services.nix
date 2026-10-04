{ lib, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  # Resolve short image names (e.g. `podman pull alpine`) against Docker Hub.
  virtualisation.containers.registries.search = [ "docker.io" ];
  environment.systemPackages = [ pkgs.podman-compose ];

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
      ExecStart = "${lib.getExe pkgs.squeezelite} -n smb374-nix -o pipewire -Z 384000";
      Restart = "on-failure";
    };
  };

  # Lyrion Music Server (backend: podman, the NixOS default).
  virtualisation.oci-containers.containers.lms = {
    image = "docker.io/lmscommunity/lyrionmusicserver:latest";
    volumes = [
      "/var/lib/lms/config:/config:rw"
      "/media:/music:ro"
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
