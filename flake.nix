# inputs define all the sources the flake will pull from,
# outputs defines all the config that will be done once fetched.

{
  description = "My first flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";    
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, plasma-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    username = "iurii";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "vscode"
        ];
    };
  in
  {
    nixosConfigurations.book2 = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        ./configuration.nix
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager # plasma-manager integration
        {
  	      home-manager.useGlobalPkgs = true;
  	      home-manager.useUserPackages = true;
  	      home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
  	      home-manager.users = { iurii = import ./home.nix; };
	      }
      ];
    };
  };
}
