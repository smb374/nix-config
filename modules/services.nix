{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  environment.systemPackages = [ pkgs.podman-compose ];

  # Trash, MTP, SMB, etc. for Thunar; thumbnails.
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  services.flatpak = {
    enable = true;
    packages = [ "org.freedownloadmanager.Manager" ];
  };
}
