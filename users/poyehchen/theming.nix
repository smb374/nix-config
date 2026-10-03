{
  config,
  lib,
  dotfiles,
  ...
}:
let
  home = config.hjem.users.poyehchen.directory;

  # DMS runs these alongside its built-in templates on every wallpaper/theme change.
  # Paths must be absolute. DMS splices this file by text search for the literal
  # `[config]` and `[templates]` lines, so both headers must be present.
  templates = {
    tmux = {
      input_path = "${dotfiles}/matugen/templates/tmux.conf";
      output_path = "${home}/.config/tmux/dank-colors.conf";
      post_hook = "tmux source-file ${home}/.config/tmux/tmux.conf >/dev/null 2>&1 || true";
    };
    fish = {
      input_path = "${dotfiles}/matugen/templates/fish.theme";
      output_path = "${home}/.config/fish/themes/dank.theme";
    };
    fzf = {
      input_path = "${dotfiles}/matugen/templates/fzf-colors";
      output_path = "${home}/.config/fzf/dank-colors";
    };
    btop = {
      input_path = "${dotfiles}/matugen/templates/btop.theme";
      output_path = "${home}/.config/btop/themes/dank.theme";
    };
    bat = {
      input_path = "${dotfiles}/matugen/templates/bat.tmTheme";
      output_path = "${home}/.config/bat/themes/dank.tmTheme";
      post_hook = "bat cache --build >/dev/null 2>&1 || true";
    };
  };
in
{
  # fzf exits on a missing FZF_DEFAULT_OPTS_FILE; create it empty until DMS first writes it.
  systemd.user.tmpfiles.users.poyehchen.rules = [
    "d %h/.config/fzf"
    "f %h/.config/fzf/dank-colors"
  ];

  hjem.users.poyehchen = {
    environment.sessionVariables = {
      BAT_THEME = "dank";
      FZF_DEFAULT_OPTS_FILE = "${home}/.config/fzf/dank-colors";
    };

    xdg.config.files = {
      "kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";

      "matugen/config.toml".text = ''
        [config]

        [templates]

      ''
      + lib.generators.toINI {
        mkSectionName = name: "templates.${name}";
        mkKeyValue = lib.generators.mkKeyValueDefault { mkValueString = builtins.toJSON; } " = ";
      } templates;
    };
  };
}
