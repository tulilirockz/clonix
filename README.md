# Clonix

Declarative rsync deployments heavily inspired by [nix-flatpak](https://github.com/gmodena/nix-flatpak).

## Usage

First import this repo's flake to your NixOS or Home-Manager configuration
```nix
{
  inputs = {
    clonix.url = "github:tulilirockz/clonix"; # github:tulilirockz/clonix/?ref=<tag> to target specific releases.
  };

  outputs = { clonix, ... }: {
    nixosConfigurations.<host> = nixpkgs.lib.nixosSystem {
      modules = [
        clonix.nixosModules.clonix

        ./configuration.nix
      ];
    };
    homeConfigurations.<username> = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        clonix.homeManagerModules.clonix

        ./home-manager.nix
      ];
    };
  };
}
```

Then you can add your clonix configuration to your NixOS or Home-manager configurations

```nix
services.clonix.enable = true;

service.clonix.deployments = [
  {
    deploymentName = "amogus";
    local.dir = /path/to/abspath;
    targetDir = /path/to/abspath;
    remote.enable = true;
    remote.user = "root";
  }
  {
    deploymentName = "sussy";
    local.dir = /path/to/abspath;
    targetDir = /path/to/abspath;
    remote.enable = true;
    remote.user.name = "momoga";
    remote.user.password = "mimiga";
    remote.ipOrHostname = "bazingamachine";
    extraOptions = "-zi";
  }
  {
    deploymentName = "baus";
    local.dir = /path/to/abspath;
    targetDir = /path/to/abspath;
    remote.enable = true;
    remote.user.name = "momoga";
    remote.user.keyfile = /path/to/abspath;
    retry.enable = true;
    retry.times = "12";
    retry.infinite = false; # overrides any other option!
  }
  {
    deploymentName = "mimi";
    local.dir = /path/to/abspath;
    targetDir = /path/to/abspath;
    remote.user.name = "momoga";
    remote.user.keyfile = "/path/to/abspath";
    onCalendar = "Mon,Tue *-*-01..04 12:00:00";
    local.exclude = ["/path/to/abspath" "/path/to/abspath"];
  }
];
```
