{
  description = "Manage rsync deployments declaratively.";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosModules = {clonix = import ./modules/nixos.nix;};
    homeManagerModules = {clonix = import ./modules/home-manager.nix;};

    formatter.${system} = pkgs.alejandra;

    checks.${system}.default = pkgs.nixosTest {
      name = "Rsync integration test";

      nodes = {
        reciever = {pkgs, ...}: {
          services.openssh = {
            enable = true;
            allowSFTP = true;
            openFirewall = true;
            settings = {
              PermitRootLogin = "yes";
              PasswordAuthentication = true;
            };
          };

          networking.useDHCP = false;

          environment.systemPackages = with pkgs; [rsync];

          users.users.tester = {
            isNormalUser = true;
            password = "tester";
          };

          networking.interfaces.eth0.ipv4.addresses = [
            {
              address = "192.168.1.5";
              prefixLength = 24;
            }
          ];
        };
        sender = {
          nodes,
          pkgs,
          ...
        }: {
          imports = [self.nixosModules.clonix];

          environment.systemPackages = with pkgs; [rsync];

          users.users.tester = {
            isNormalUser = true;
            password = "tester";
          };

          services.clonix.enable = true;
          services.clonix.deployments = [
            {
              deploymentName = "testing_deployment";
              local.dir = "${nodes.sender.users.users.tester.home}/testingfiles";
              targetDir = "${nodes.reciever.users.users.tester.home}/testingfiles";
              timer.enable = false;
              timer.OnBootSec = "1";
              remote.enable = nodes.reciever.services.openssh.enable;
              remote.ipOrHostname = (builtins.elemAt nodes.reciever.networking.interfaces.eth0.ipv4.addresses 0).address;
              remote.user.name = nodes.reciever.users.users.tester.name;
              remote.user.password = nodes.reciever.users.users.tester.password;
            }
          ];
        };
      };

      testScript = {nodes, ...}: ''
        sender.wait_for_unit("network.target")
        reciever.wait_for_unit("network.target")
        reciever.succeed("mkdir ${nodes.reciever.users.users.tester.home}/testingfiles")
        sender.succeed("mkdir ${nodes.reciever.users.users.tester.home}/testingfiles && echo hi!!! >> ${nodes.reciever.users.users.tester.home}/testingfiles/cheetos && systemctl start clonix@*")
        reciever.succeed("sleep 5 ; ls ${nodes.reciever.users.users.tester.home}/testingfiles")
      '';
    };
  };
}
