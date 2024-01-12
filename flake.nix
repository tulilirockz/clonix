{
  description = "Manage rsync deployments declaratively.";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosModules = {clonix = import ./modules/nixos.nix;};
    homeManagerModules = {clonix = import ./modules/home-manager.nix;};
    formatter.${system} = pkgs.alejandra;
  };
}
