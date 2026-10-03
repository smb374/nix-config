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
  strip = lib.removePrefix "#";

  # Semantic roles, so the app configs below read the same for any scheme.
  bg = c.base00;
  bgAlt = c.base01;
  bgHigh = c.base02;
  bgHighest = c.base03;
  muted = c.base04;
  fg = c.base05;
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

  # Terminal colors 0-15, per the base24 styling spec.
  ansi = with c; [
    base00
    base08
    base0B
    base0A
    base0D
    base0E
    base0C
    base05
    base03
    base12
    base14
    base13
    base16
    base17
    base15
    base07
  ];

  # qt6ct palette: one color per QPalette::ColorRole, in enum order; qt6ct falls back to
  # the default palette with fewer than NColorRoles entries. (Basix's generated qt6ct
  # file has 14 entries in a different order, so it is not used.)
  qtPalette =
    {
      text,
      highlight,
      highlightedText,
    }:
    lib.concatStringsSep ", " [
      text # WindowText
      bgHigh # Button
      muted # Light
      bgHighest # Midlight
      bgAlt # Dark
      bg # Mid
      text # Text
      c.base07 # BrightText
      text # ButtonText
      bg # Base
      bg # Window
      "#000000" # Shadow
      highlight # Highlight
      highlightedText # HighlightedText
      blue # Link
      magenta # LinkVisited
      bgAlt # AlternateBase
      bg # NoRole
      bgAlt # ToolTipBase
      text # ToolTipText
      muted # PlaceholderText
      highlight # Accent
    ];
  qtNormal = qtPalette {
    text = fg;
    highlight = accent;
    highlightedText = bg;
  };
  qtColors = pkgs.writeText "qt6ct-basix.conf" ''
    [ColorScheme]
    active_colors=${qtNormal}
    inactive_colors=${qtNormal}
    disabled_colors=${
      qtPalette {
        text = muted;
        highlight = bgHigh;
        highlightedText = muted;
      }
    }
  '';

  dmsTheme = {
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

  # libadwaita / adw-gtk3 named colors.
  gtkCss = ''
    @define-color accent_color ${accent};
    @define-color accent_bg_color ${accent};
    @define-color accent_fg_color ${bg};
    @define-color destructive_color ${red};
    @define-color destructive_bg_color ${red};
    @define-color destructive_fg_color ${bg};
    @define-color success_color ${green};
    @define-color success_bg_color ${green};
    @define-color success_fg_color ${bg};
    @define-color warning_color ${yellow};
    @define-color warning_bg_color ${yellow};
    @define-color warning_fg_color ${bg};
    @define-color error_color ${red};
    @define-color error_bg_color ${red};
    @define-color error_fg_color ${bg};
    @define-color window_bg_color ${bg};
    @define-color window_fg_color ${fg};
    @define-color view_bg_color ${bg};
    @define-color view_fg_color ${fg};
    @define-color headerbar_bg_color ${bgAlt};
    @define-color headerbar_fg_color ${fg};
    @define-color headerbar_border_color ${bgHigh};
    @define-color headerbar_backdrop_color ${bg};
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);
    @define-color sidebar_bg_color ${bgAlt};
    @define-color sidebar_fg_color ${fg};
    @define-color sidebar_backdrop_color ${bg};
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.36);
    @define-color secondary_sidebar_bg_color ${bgAlt};
    @define-color secondary_sidebar_fg_color ${fg};
    @define-color secondary_sidebar_backdrop_color ${bg};
    @define-color card_bg_color ${bgHigh};
    @define-color card_fg_color ${fg};
    @define-color card_shade_color rgba(0, 0, 0, 0.36);
    @define-color dialog_bg_color ${bgAlt};
    @define-color dialog_fg_color ${fg};
    @define-color popover_bg_color ${bgAlt};
    @define-color popover_fg_color ${fg};
    @define-color popover_shade_color rgba(0, 0, 0, 0.36);
    @define-color thumbnail_bg_color ${bgAlt};
    @define-color thumbnail_fg_color ${fg};
    @define-color shade_color rgba(0, 0, 0, 0.36);
    @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
  '';
in
{
  # Read by GTK on Wayland and by xdg-desktop-portal (dark-mode preference).
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "adw-gtk3-dark";
        icon-theme = "Papirus-Dark";
        color-scheme = "prefer-dark";
      };
    }
  ];

  hjem.users.poyehchen = {
    environment.sessionVariables = {
      # bat's "ansi" theme uses the terminal palette set in kitty below.
      BAT_THEME = "ansi";
      FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
        "--color=fg:${fg},bg:-1,hl:${accent}"
        "--color=fg+:${fg},bg+:${bgHigh},hl+:${accent}"
        "--color=info:${secondary},prompt:${secondary},pointer:${tertiary}"
        "--color=marker:${tertiary},spinner:${tertiary},header:${accent}"
        "--color=selected-bg:${bgHighest},border:${bgHigh},label:${fg}"
      ];
    };

    xdg.config.files = {
      "kitty/basix-theme.conf".text = ''
        foreground ${fg}
        background ${bg}
        selection_foreground ${bg}
        selection_background ${accent}
        cursor ${fg}
        cursor_text_color ${bg}
        url_color ${cyan}
        active_border_color ${accent}
        inactive_border_color ${bgHighest}

        tab_bar_margin_color ${bg}
        tab_bar_background ${bg}
        active_tab_foreground ${bg}
        active_tab_background ${accent}
        inactive_tab_foreground ${muted}
        inactive_tab_background ${bg}

      ''
      + lib.concatImapStrings (i: color: "color${toString (i - 1)} ${color}\n") ansi;

      "tmux/basix-colors.conf".text = ''
        # Palette; tmux.conf refers to these.
        set -g @theme_background      "${bg}"
        set -g @theme_primary         "${accent}"
        set -g @theme_outline         "${muted}"
        set -g @theme_outline_variant "${bgHigh}"
        set -g @theme_red             "${red}"
        set -g @theme_blue            "${blue}"
        set -g @theme_cyan            "${cyan}"

        set -g message-style               "bg=${bgAlt},fg=${fg}"
        set -g message-command-style       "bg=${bgAlt},fg=${fg}"
        set -g mode-style                  "bg=${bgHigh},fg=${fg}"
        set -g pane-border-style           "fg=${bgHigh}"
        set -g pane-active-border-style    "fg=${accent}"
        set -g display-panes-colour        "${muted}"
        set -g display-panes-active-colour "${accent}"
        set -g clock-mode-colour           "${accent}"
      '';

      "fish/themes/basix.theme".text = ''
        # name: 'Basix'

        fish_color_normal ${strip fg}
        fish_color_command ${strip accent}
        fish_color_keyword ${strip tertiary}
        fish_color_param ${strip fg}
        fish_color_option ${strip secondary}
        fish_color_quote ${strip green}
        fish_color_redirection ${strip secondary}
        fish_color_end ${strip yellow}
        fish_color_operator ${strip cyan}
        fish_color_escape ${strip magenta}
        fish_color_error ${strip red}
        fish_color_comment ${strip muted}
        fish_color_autosuggestion ${strip muted}
        fish_color_selection --background=${strip bgHigh}
        fish_color_search_match --background=${strip bgHigh}
        fish_color_valid_path --underline
        fish_color_history_current --bold
        fish_color_cwd ${strip yellow}
        fish_color_cwd_root ${strip red}
        fish_color_user ${strip cyan}
        fish_color_host ${strip accent}
        fish_color_host_remote ${strip green}
        fish_color_status ${strip red}
        fish_color_cancel ${strip red}
        fish_pager_color_progress ${strip muted}
        fish_pager_color_prefix ${strip accent}
        fish_pager_color_completion ${strip fg}
        fish_pager_color_description ${strip muted}
        fish_pager_color_selected_background --background=${strip bgHigh}
      '';

      # Select with `color_theme = "basix"` in btop.conf.
      "btop/themes/basix.theme".text = ''
        theme[main_bg]="${bg}"
        theme[main_fg]="${fg}"
        theme[title]="${fg}"
        theme[hi_fg]="${accent}"
        theme[selected_bg]="${bgHigh}"
        theme[selected_fg]="${accent}"
        theme[inactive_fg]="${muted}"
        theme[graph_text]="${fg}"
        theme[meter_bg]="${bgHighest}"
        theme[proc_misc]="${secondary}"
        theme[div_line]="${bgHigh}"
        theme[cpu_box]="${accent}"
        theme[mem_box]="${secondary}"
        theme[net_box]="${tertiary}"
        theme[proc_box]="${muted}"
        theme[temp_start]="${green}"
        theme[temp_mid]="${yellow}"
        theme[temp_end]="${red}"
        theme[cpu_start]="${accent}"
        theme[cpu_mid]="${tertiary}"
        theme[cpu_end]="${red}"
        theme[free_start]="${green}"
        theme[free_mid]="${green}"
        theme[free_end]="${c.base14}"
        theme[cached_start]="${cyan}"
        theme[cached_mid]="${cyan}"
        theme[cached_end]="${c.base15}"
        theme[available_start]="${yellow}"
        theme[available_mid]="${yellow}"
        theme[available_end]="${c.base13}"
        theme[used_start]="${red}"
        theme[used_mid]="${red}"
        theme[used_end]="${c.base12}"
        theme[download_start]="${secondary}"
        theme[download_mid]="${secondary}"
        theme[download_end]="${accent}"
        theme[upload_start]="${tertiary}"
        theme[upload_mid]="${tertiary}"
        theme[upload_end]="${accent}"
        theme[process_start]="${accent}"
        theme[process_mid]="${tertiary}"
        theme[process_end]="${red}"
      '';

      # Select in DMS: Settings → Theme & Colors → Custom → this file.
      "DankMaterialShell/themes/basix.json".text = builtins.toJSON {
        dark = dmsTheme;
        light = dmsTheme;
      };

      # DMS wrote these before; clobber replaces its files on first activation.
      "gtk-3.0/gtk.css" = {
        text = gtkCss;
        clobber = true;
      };
      "gtk-4.0/gtk.css" = {
        text = gtkCss;
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
