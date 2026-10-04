# Evaluates Hjem user modules outside NixOS into the value the standalone CLI reads
# (`hjem standalone switch --flake .` → hjemConfigurations."$USER"): { manifest; packages; }.
# Mirrors the per-user part of Hjem's NixOS module (modules/nixos/base.nix).
{
  nixpkgs,
  hjem,
  pkgs,
  specialArgs ? { },
}:
{
  user,
  directory,
  modules,
}:
let
  inherit (nixpkgs) lib;
  hjem-lib = hjem.hjem-lib.${pkgs.stdenv.hostPlatform.system};
  # Hjem's systemd module builds units with the NixOS systemd library, which reads these
  # NixOS options (defaults as on NixOS).
  utils = import "${nixpkgs}/nixos/lib/utils.nix" {
    inherit lib pkgs;
    config.systemd = {
      package = pkgs.systemd;
      globalEnvironment = { };
      enableStrictShellChecks = false;
    };
  };

  cfg =
    (lib.evalModules {
      class = "hjem";
      specialArgs = specialArgs // {
        inherit hjem-lib pkgs utils;
        name = user;
      };
      modules = [
        "${hjem}/modules/common/user.nix"
        "${hjem}/modules/nixos/systemd.nix"
        {
          inherit user directory;
          clobberFiles = lib.mkDefault false;
        }
      ]
      ++ modules;
    }).config;

  failed = map (a: a.message) (lib.filter (a: !a.assertion) cfg.assertions);
  userFiles = [
    cfg.files
    cfg.xdg.cache.files
    cfg.xdg.config.files
    cfg.xdg.data.files
    cfg.xdg.state.files
  ];
in
lib.throwIf (failed != [ ]) "hjem ${user}: ${lib.concatStringsSep "; " failed}" {
  manifest = {
    version = 3;
    files = lib.concatMap (
      files: map hjem-lib.fileToJson (lib.filter (f: f.enable) (lib.attrValues files))
    ) userFiles;
  };
  inherit (cfg) packages;
}
