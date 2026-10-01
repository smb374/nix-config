{ pkgs, inputs, ... }:
{
  hjem.users.poyehchen = {
    packages = with pkgs; [
      neovim
      git
      kitty
      brave-origin
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
