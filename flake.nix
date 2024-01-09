{
  description = "Manage rsync deployments declaratively.";

  outputs = _: {
    nixosModules = {clonix = import ./modules/nixos.nix;};
    homeManagerModules = {clonix = import ./modules/home-manager.nix;};
  };
}
