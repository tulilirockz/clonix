{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clonix;
  generateDeploymentHash = deployment: builtins.hashString "sha256" (builtins.toJSON deployment);
  generateService = deployment: {
    # TODO: actually figure out how to make systemd template services, I don't know how to make these properly work for now.
    "clonix@${generateDeploymentHash deployment}" = {
      enable = true;
      unitConfig = {
        Description = "Clonix for ${deployment.deploymentName}: local: ${deployment.localDir}, target: ${deployment.targetDir}";
        Wants = "network-online.target";
        After = "network-online.target";
      };

      serviceConfig = {
        #User = deployment.local.user;
        WorkingDirectory = deployment.local.dir;
        ExecStart = "${import ./cloner-script.nix {inherit cfg pkgs lib deployment;}} ${generateDeploymentHash deployment}";
      };
    };
  };
in {
  options.services.clonix = import ./options.nix {inherit lib pkgs;};

  config = lib.mkIf cfg.enable {
    systemd.user.services = builtins.map generateService cfg.deployments;
  };
}
