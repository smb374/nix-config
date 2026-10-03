{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Battery level of connected devices.
    settings.General.Experimental = true;
  };

  # AMD: RX 9070 XT + Granite Ridge iGPU.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.initrd.enable = true;
  environment.variables.AMD_VULKAN_ICD = "RADV";
  services.lact.enable = true;

  # DDC/CI monitor control for ddcutil.
  hardware.i2c.enable = true;

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # YubiKey via scdaemon's internal CCID driver; gpg-agent is the only SSH agent.
  hardware.gpgSmartcards.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  services.gnome.gcr-ssh-agent.enable = false;

  environment.systemPackages = with pkgs; [
    amdgpu_top
    ddcutil
    exfatprogs
    tpm2-tools
    udisks
    yubikey-manager
  ];
}
