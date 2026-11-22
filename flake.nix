{
  description = "smb374 NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    basix = {
      url = "github:NotAShelf/Basix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Caelestia dots: Hyprland Lua config, linked file by file into ~/.config/hypr.
    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    waydroid-script = {
      url = "github:casualsnek/waydroid_script";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-auth.url = "github:numtide/nix-auth";
  };

  outputs =
    {
      nixpkgs,
      hjem,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      mkHjemStandalone = import ./lib/hjem-standalone.nix {
        inherit nixpkgs hjem;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        specialArgs = { inherit inputs; };
      };
    in
    {
      nixosConfigurations.smb374-nix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          hjem.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          ./hosts/smb374-nix
          ./modules
          ./users/poyehchen
        ];
      };

      # Standalone Hjem (non-NixOS hosts): `hjem standalone switch --flake .`
      hjemConfigurations.poyehchen = mkHjemStandalone {
        user = "poyehchen";
        directory = "/home/poyehchen";
        modules = [ ./users/poyehchen/home ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
