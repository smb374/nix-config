{ pkgs, ... }:

{
  # Run unpatched, dynamically linked binaries (prebuilt tools, language-server downloads, ...).
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    lshw

    # Archives
    unrar
    unzip
    zip
    unar

    # CLI
    ripgrep
    fd
    jq
  ];
}
