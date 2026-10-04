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
  xdg.config.files = hyprFiles // {
    # Personal overrides, loaded by the dots' hyprland.lua.
    "caelestia/hypr-vars.lua".source = "${dotfiles}/caelestia/hypr-vars.lua";
    "caelestia/hypr-user.lua".source = "${dotfiles}/caelestia/hypr-user.lua";
    # Out-of-store link: the shell's settings UI writes this file back into the repo.
    "caelestia/shell.json".source = "${dotfiles}/caelestia/shell.json";

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
