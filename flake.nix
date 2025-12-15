{
  description = "siddhi's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    zen-browser-source.url = "github:youwen5/zen-browser-flake";
    nixcord.url = "github:KaylorBen/nixcord";
    lazyvim-nix.url = "github:jla2000/lazyvim-nix";
    syd.url = "github:sidharthify/syd";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    spicetify-nix,
    zen-browser-source,
    nixcord,
    lazyvim-nix,
    syd,
    nix-flatpak,
    parsecgaming,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs; };

      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              parsecgaming =
                parsecgaming.packages.${system}.parsecgaming;
            })
          ];
        })

        ./nixos/configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.sidharthify = {
            imports = [
              ./home/home.nix
              ./home/spicetify.nix
              ./home/vscodium.nix
              ./home/nixcord.nix
            ];
          };

          home-manager.sharedModules = [
            inputs.nixcord.homeModules.nixcord
          ];

          home-manager.extraSpecialArgs = {
            inherit spicetify-nix lazyvim-nix;
          };
        }

        ({ pkgs, ... }: {
          environment.systemPackages = [
            zen-browser-source.packages.${system}.default
            syd.packages.${system}.default
            pkgs.parsecgaming
          ];
        })
      ];
    };
  };
}
