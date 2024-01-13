# Clonix

Declarative [rsync](https://github.com/WayneD/rsync) deployments for NixOS and Home-Manager supported system!

Heavily inspired by [nix-flatpak](https://github.com/gmodena/nix-flatpak).

If you dont want to read all this and just skip to how to use it, go to the `Usage & Examples` section at the end.

## Deployments

They are a way to run rsync at a specific time by using a systemd timer and a systemd service. Its pretty much like a declarative [syncthing](https://syncthing.net/) of sorts!

You can declare your deployments by adding them to a list with an attrset with them. They can be either remote deployments or local sync deployments. E.g.:

```nix
deployments = [{
    #...
    local.dir = "/path/to/abspath"; # This needs to be a string, because if it is of the path type itll be on the /nix/store instead of actually being where you want.
    local.exclude = [ "/path/to/abspath" ];
    targetDir = "/path/to/other/abspath";
}];
```

This generates pretty much this rsync command:

```shell
rsync -avh /path/to/abspath/* /path/to/other/abspath
```

## Remote

You can also remotely deploy your rsync folders through SSH by specifying the user, machine, and password or keyfile that you want to use 

```nix
deployments = [{
    #...
    remote.enable = true;
    remote.user.name = "user";
    remote.user.password = "somethingsomething";
    remote.user.keyfile = null;
}];
```

This would generate:

```shell
rsync --rsh "sshpass -p somethingsomething ssh -l user" /path/to/abspath user@iphostname:/path/to/other/abspath
```

## Timer

When your deployments are going to be ran is also completely customizable by systemd standards, by editing the "timer" option in each of your deployments (timers are enabled by default at 12:00 PM).

```nix
deployments = [{
    #...
    timer.enable = true;
    timer.OnCalendar = "";
    timer.OnUnitActiveSec = "";
    timer.OnUnitInactiveSec = "";
    timer.OnBootSec = "";
    timer.OnActiveSec = "";
    timer.OnStartupSec = "";
}];
```

Which would generate a systemd unit with all these configurations in its toml-like structure.

## Overrides

You can also feel free to change up whichever rsync, or whatever else's versions and packages that you want this script to run by overriding them in the options

```nix
services.clonix.enable = true;
services.clonix.packages = {
    openssh = otherplace.openssh;
    rsync = otherplace.rsync;
    sshpass = otherplace.sshpass;
    # and so on...
};
```

## Usage & Examples

You can either quickly import this project's template for your configurations by running:

```shell
nix flake init . -t github:tulilirockz/clonix
```

Or you can manually import this repo's flake over to your NixOS or Home-Manager configuration

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    clonix = {
        url = "github:tulilirockz/clonix"; # github:tulilirockz/clonix/?ref=<tag> to target specific releases.
        inputs.nixpkgs.follows = "nixpkgs";
    };
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
    local.dir = "/path/to/abspath";
    targetDir = "/path/to/abspath";
    remote.enable = true;
    remote.user.name = "root";
    remote.user.keyfile = ./keyfile;
  }
  {
    deploymentName = "sussy";
    local.dir = "/path/to/abspath";
    targetDir = "/path/to/abspath";
    remote.enable = true;
    remote.user.name = "momoga";
    remote.user.password = "mimiga";
    remote.ipOrHostname = "machine";
    extraOptions = "-zi";
  }
  {
    deploymentName = "baus";
    local.dir = /path/to/abspath;
    local.exclude = ["/path/to/abspath" "/path/to/abspath"];
    targetDir = "/path/to/abspath";
    remote.enable = true;
    remote.user.name = "momoga";
    remote.user.keyfile = "/path/to/abspath";
    timer.enable = true;
    timer.onCalendar = "Mon,Tue *-*-01..04 12:00:00";
  }
];
```

## Testing and Contributing

If you want to contribute and test out your stuff, you can make a new test with `nix flake check` by adding a new option insite of `flake.nix`s `nixosTest` tests!
