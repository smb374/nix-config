{
  config,
  pkgs,
  dotfiles,
  ...
}:
let
  hjemUser = config.hjem.users.poyehchen;
in
{
  programs.fish.enable = true;
  # fish only reads vendor plugin dirs linked into the system profile.
  environment.systemPackages = with pkgs.fishPlugins; [
    pure
    fzf-fish
  ];

  programs.direnv.enable = true;
  programs.zoxide = {
    enable = true;
    flags = [ "--cmd cd" ];
  };

  hjem.users.poyehchen = {
    packages = with pkgs; [
      fzf
      tmux
    ];

    environment.sessionVariables = {
      SHELL = "/run/current-system/sw/bin/fish";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GOPATH = "$HOME/.local/lib/go";
      PI_ASK_USER_DISPLAY_MODE = "inline";
    };

    xdg.config.files = {
      # Runs before config.fish; loads Hjem's session variables.
      "fish/conf.d/hjem-env.fish".text = ''
        source ${hjemUser.environment.loadEnv}
      '';
      "fish/config.fish".source = "${dotfiles}/fish/config.fish";
      "foot/foot.ini".source = "${dotfiles}/foot/foot.ini";
      "kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";
      "tmux/tmux.conf".source = "${dotfiles}/tmux/tmux.conf";
    };
  };
}
