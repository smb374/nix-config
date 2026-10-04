{
  lib,
  inputs,
  dotfiles,
  ...
}:
let
  hyprDir = "${inputs.caelestia-dots}/hypr";

  # Link each file, not the directory: hyprland.lua and the CLI write hypr/scheme/current.lua.
  # Attribute names cannot carry store context; `source` still references the store path.
  relName =
    file: builtins.unsafeDiscardStringContext (lib.removePrefix "${hyprDir}/" (toString file));
  hyprFiles = lib.listToAttrs (
    map (file: lib.nameValuePair "hypr/${relName file}" { source = file; }) (
      lib.filesystem.listFilesRecursive hyprDir
    )
  );
in
{
  hjem.users.poyehchen.xdg.config.files = hyprFiles // {
    # Personal overrides, loaded by the dots' hyprland.lua.
    "caelestia/hypr-vars.lua".source = "${dotfiles}/caelestia/hypr-vars.lua";
    "caelestia/hypr-user.lua".source = "${dotfiles}/caelestia/hypr-user.lua";

    "caelestia/cli.json".text = builtins.toJSON {
      # Basix (theming.nix) owns these outputs; the CLI only themes Hyprland and the shell.
      theme = {
        enableTerm = false;
        enableGtk = false;
        enableQt = false;
        enableBtop = false;
      };
      # The CLI's default btop toggle launches foot, the default terminal (hypr-vars.lua).
    };
  };
}
