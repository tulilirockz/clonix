{
  description = "Example clonix configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clonix = {
      url = "github:tulilirockz/clonix"; # github:tulilirockz/clonix/?ref=<tag> to target specific releases.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    clonix,
    ...
  }: let
    system = "x86_64-linux"; # Change this depending on your architecture!
    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
    };
    main_username = "example";
  in {
    nixosConfigurations = {
      example = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          clonix.nixosModules.clonix

          ./configuration.nix
        ];
      };
    };

    homeConfigurations.${main_username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        clonix.homeManagerModules.clonix

        ./home-manager.nix
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [nil gnumake];
    };

    formatter.${system} = pkgs.alejandra;
  };
}
