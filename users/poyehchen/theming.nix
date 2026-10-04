{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Pick any scheme from github:NotAShelf/Basix (json/base16 or json/base24).
  # base24 supplies distinct bright ANSI colors (base12-base17).
  # The Caelestia shell and Hyprland borders use the CLI's own scheme; keep it matching:
  #   caelestia scheme set -n catppuccin -f mocha -m dark
  slug = "catppuccin-mocha";
  scheme = inputs.basix.schemeData.base24.${slug};

  # Palette values are "#rrggbb".
  c = scheme.palette;

  # Semantic roles, so the templates read the same for any scheme.
  roles = {
    bg = c.base00;
    bgAlt = c.base01;
    bgHigh = c.base02;
    bgHighest = c.base03;
    muted = c.base04;
    fg = c.base05;
    bright = c.base07;
    accent = c.base0D;
    secondary = c.base0E;
    tertiary = c.base0C;
    red = c.base08;
    orange = c.base09;
    yellow = c.base0A;
    green = c.base0B;
    cyan = c.base0C;
    blue = c.base0D;
    magenta = c.base0E;
    # base24 bright ANSI colors.
    brightRed = c.base12;
    brightYellow = c.base13;
    brightGreen = c.base14;
    brightCyan = c.base15;
    brightBlue = c.base16;
    brightMagenta = c.base17;
  };

  # Renders ./templates/<name>.mustache. Templates see every role as "#rrggbb"
  # ({{bg}}) and as bare "rrggbb" ({{hex.bg}}).
  render =
    name:
    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.mustache-go ];
        passAsFile = [ "data" ];
        data = builtins.toJSON (roles // { hex = lib.mapAttrs (_: lib.removePrefix "#") roles; });
      }
      ''
        mustache "$dataPath" ${./templates + "/${name}.mustache"} > "$out"
      '';

  # KDE color scheme for qtengine, laid out like the Caelestia CLI's qtdark.colors.
  qtColors = render "kde.colors";
  gtkCss = render "gtk.css";
in
{
  # Read by GTK on Wayland and by xdg-desktop-portal (dark-mode preference).
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3-dark";
        icon-theme = "Papirus-Dark";
        color-scheme = "prefer-dark";
        cursor-theme = "Vanilla-DMZ";
        cursor-size = lib.gvariant.mkInt32 24;
      };
    }
  ];

  hjem.users.poyehchen = {
    environment.sessionVariables = {
      # bat's "ansi" theme uses the terminal palette set in foot and kitty below.
      BAT_THEME = "ansi";
      FZF_DEFAULT_OPTS =
        with roles;
        lib.concatStringsSep " " [
          "--color=fg:${fg},bg:-1,hl:${accent}"
          "--color=fg+:${fg},bg+:${bgHigh},hl+:${accent}"
          "--color=info:${secondary},prompt:${secondary},pointer:${tertiary}"
          "--color=marker:${tertiary},spinner:${tertiary},header:${accent}"
          "--color=selected-bg:${bgHighest},border:${bgHigh},label:${fg}"
        ];
    };

    xdg.config.files = {
      "foot/basix-colors.ini".source = render "foot.ini";
      "kitty/basix-theme.conf".source = render "kitty.conf";
      "tmux/basix-colors.conf".source = render "tmux-colors.conf";
      "fish/themes/basix.theme".source = render "fish.theme";
      # Select with `color_theme = "basix"` in btop.conf.
      "btop/themes/basix.theme".source = render "btop.theme";

      # The Caelestia CLI's gtk writer is off (hyprland.nix); clobber replaces any
      # existing unmanaged file.
      "gtk-3.0/gtk.css" = {
        source = gtkCss;
        clobber = true;
      };
      "gtk-4.0/gtk.css" = {
        source = gtkCss;
        clobber = true;
      };

      # Read by the qtengine platform theme (QT_QPA_PLATFORMTHEME in modules/desktop.nix).
      "qtengine/config.json".text = builtins.toJSON {
        theme = {
          colorScheme = "${qtColors}";
          iconTheme = "Papirus-Dark";
          style = "Darkly";
          font = {
            family = "Sans Serif";
            size = 12;
            weight = -1;
          };
          fontFixed = {
            family = "Monospace";
            size = 12;
            weight = -1;
          };
        };
        misc = {
          menusHaveIcons = true;
          singleClickActivate = true;
          shortcutsForContextMenus = true;
        };
      };
    };
  };
}
