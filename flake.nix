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
  };

  outputs =
    {
      nixpkgs,
      hjem,
      nix-flatpak,
      ...
    }@inputs:
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
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
