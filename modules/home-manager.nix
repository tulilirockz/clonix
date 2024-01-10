{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clonix;
  generateDeploymentHash = deployment: builtins.hashString "sha256" (builtins.toJSON deployment);
  generateService = deployment: {
    "clonix@${generateDeploymentHash deployment}" = {
      Unit = {
        Description = "Clonix for ${deployment.deploymentName}: local: ${deployment.local.dir}, target: ${deployment.targetDir}";
        Documentation = "man:clonix(1)";
      };

      Service = {
        Type = "exec";
        ExecStart = "${import ./cloner-script.nix {inherit cfg pkgs lib generateDeploymentHash;}}/bin/clonix-main ${generateDeploymentHash deployment}";
      };
    };
  };
in {
  options.services.clonix = import ./options.nix {inherit lib pkgs;};

  config = lib.mkIf cfg.enable {
    systemd.user.services = lib.mkMerge (lib.lists.flatten (builtins.map generateService cfg.deployments));
  };
}
