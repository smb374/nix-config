{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Pick any scheme from github:NotAShelf/Basix (json/base16 or json/base24).
  # base24 supplies distinct bright ANSI colors (base12-base17).
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

  # qt6ct palette: one color per QPalette::ColorRole, in enum order (WindowText, Button,
  # Light, Midlight, Dark, Mid, Text, BrightText, ButtonText, Base, Window, Shadow,
  # Highlight, HighlightedText, Link, LinkVisited, AlternateBase, NoRole, ToolTipBase,
  # ToolTipText, PlaceholderText, Accent). qt6ct falls back to the default palette with
  # fewer entries, so Basix's 14-entry qt6ct file is not used.
  qtColors = render "qt6ct-colors.conf";
  gtkCss = render "gtk.css";

  dmsTheme = with roles; {
    inherit (scheme) name;
    primary = accent;
    primaryText = bg;
    primaryContainer = bgHigh;
    inherit secondary;
    surfaceTint = accent;
    surface = bgAlt;
    surfaceText = fg;
    surfaceVariant = bg;
    surfaceVariantText = fg;
    background = bg;
    backgroundText = fg;
    outline = muted;
    surfaceContainerLowest = bgAlt;
    surfaceContainerLow = bgAlt;
    surfaceContainer = bg;
    surfaceContainerHigh = bgHigh;
    surfaceContainerHighest = bgHighest;
    error = red;
    warning = orange;
    info = blue;
  };
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
      # bat's "ansi" theme uses the terminal palette set in kitty below.
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
      "kitty/basix-theme.conf".source = render "kitty.conf";
      "tmux/basix-colors.conf".source = render "tmux-colors.conf";
      "fish/themes/basix.theme".source = render "fish.theme";
      # Select with `color_theme = "basix"` in btop.conf.
      "btop/themes/basix.theme".source = render "btop.theme";

      # Select in DMS: Settings → Theme & Colors → Custom → this file.
      "DankMaterialShell/themes/basix.json".text = builtins.toJSON {
        dark = dmsTheme;
        light = dmsTheme;
      };

      # DMS wrote these before; clobber replaces its files on first activation.
      "gtk-3.0/gtk.css" = {
        source = gtkCss;
        clobber = true;
      };
      "gtk-4.0/gtk.css" = {
        source = gtkCss;
        clobber = true;
      };

      "qt6ct/qt6ct.conf" = {
        clobber = true;
        generator = lib.generators.toINI { };
        value = {
          Appearance = {
            color_scheme_path = "${qtColors}";
            custom_palette = true;
            icon_theme = "Papirus-Dark";
            standard_dialogs = "default";
            style = "Fusion";
          };
          Interface = {
            activate_item_on_single_click = 1;
            dialog_buttons_have_icons = 1;
            menus_have_icons = true;
            show_shortcuts_in_context_menus = true;
            toolbutton_style = 4;
            underline_shortcut = 1;
            wheel_scroll_lines = 3;
          };
        };
      };
    };
  };
}
