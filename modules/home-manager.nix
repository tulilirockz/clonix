{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.clonix;
  ifNotNull = value: lib.mkIf (value != null) value;
  generateDeploymentHash = deployment: builtins.hashString "sha256" (builtins.toJSON deployment);
  generateService = deployment: {
    "clonix@${generateDeploymentHash deployment}-${deployment.deploymentName}" = {
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
  generateTimer = deployment: {
    "clonix@${generateDeploymentHash deployment}-${deployment.deploymentName}" = {
      Timer = {
        OnActiveSec = ifNotNull deployment.timer.OnActiveSec;
        OnBootSec = ifNotNull deployment.timer.OnBootSec;
        OnStartupSec = ifNotNull deployment.timer.OnStartupSec;
        OnUnitActiveSec = ifNotNull deployment.timer.OnUnitActiveSec;
        OnUnitInactiveSec = ifNotNull deployment.timer.OnUnitInactiveSec;
        OnCalendar = ifNotNull deployment.timer.OnCalendar;
        Unit = "clonix@${generateDeploymentHash deployment}.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
in {
  options.services.clonix = import ./options.nix {inherit lib pkgs;};

  config = lib.mkIf cfg.enable {
    systemd.user.services = lib.mkMerge (lib.lists.flatten (builtins.map generateService cfg.deployments));
    systemd.user.timers = lib.mkMerge (lib.lists.flatten (builtins.map generateTimer cfg.deployments));
  };
}
