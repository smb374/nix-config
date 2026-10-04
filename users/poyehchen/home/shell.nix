{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:
{
  packages = with pkgs; [
    fzf
    tmux
  ];

  environment.sessionVariables = {
    # A store path works on NixOS and standalone hosts; the reference also keeps fish installed.
    EDITOR = "nvim";
    VISUAL = "nvim";
    GOPATH = "$HOME/.local/lib/go";
    PI_ASK_USER_DISPLAY_MODE = "inline";
  };

  xdg.config.files = {
    # Runs before config.fish; loads Hjem's session variables.
    "fish/conf.d/hjem-env.fish".text = ''
      source ${config.environment.loadEnv}
    '';
    "fish/config.fish".source = "${dotfiles}/fish/config.fish";
    "foot/foot.ini".source = "${dotfiles}/foot/foot.ini";
    "kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";
    "tmux/tmux.conf".source = "${dotfiles}/tmux/tmux.conf";
  };
}
