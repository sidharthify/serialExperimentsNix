{
  description = "siddhi's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url      = "github:Gerg-L/spicetify-nix";
    zen-browser-source.url = "github:youwen5/zen-browser-flake";
    nixcord.url            = "github:KaylorBen/nixcord";
    lazyvim-nix.url        = "github:jla2000/lazyvim-nix";
    syd.url                = "github:sidharthify/syd";
    nix-flatpak.url        = "github:gmodena/nix-flatpak";
    parsecgaming.url       = "github:DarthPJB/parsec-gaming-nix";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    catppuccin.url    = "github:catppuccin/nix";
    millennium.url    = "github:SteamClientHomebrew/Millennium/next?dir=packages/nix";
    balena-etcher.url = "github:sidharthify/balenaEtcher-flake";

    tuxManager = {
      url = "github:sidharthify/TuxManager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    spicetify-nix,
    lazyvim-nix,
    plasma-manager,
    catppuccin,
    aerothemeplasma-nix,
    nix-flatpak,
    jovian,
    ...
  }@inputs:
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        ./nixos/configuration.nix
        jovian.nixosModules.default
        aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;

          home-manager.users.sidharthify.imports = [ ./home/home.nix ];

          home-manager.sharedModules = [
            inputs.nixcord.homeModules.nixcord
            plasma-manager.homeModules.plasma-manager
            catppuccin.homeModules.catppuccin
          ];
          home-manager.extraSpecialArgs = {
            inherit spicetify-nix lazyvim-nix inputs;
          };
        }
      ];
    };
  };
}
