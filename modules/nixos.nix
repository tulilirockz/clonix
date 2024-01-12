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
      enable = true;
      unitConfig = {
        Description = "Clonix for ${deployment.deploymentName}: local: ${deployment.localDir}, target: ${deployment.targetDir}";
        Wants = "network-online.target";
        After = "network-online.target";
      };

      serviceConfig = {
        DynamicUser = true;
        WorkingDirectory = deployment.local.dir;
        ExecStart = "${import ./cloner-script.nix {inherit cfg pkgs lib deployment;}} ${generateDeploymentHash deployment}";
      };
    };
  };
  generateTimer = deployment: {
    "clonix@${generateDeploymentHash deployment}" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "${
          if (deployment.timer.onBootSec != null)
          then deployment.timer.onBootSec
          else ""
        }";
        OnUnitActiveSec = "${
          if (deployment.timer.onUnitActiveSec != null)
          then deployment.timer.onUnitActiveSec
          else ""
        }";
        OnCalendar = "${
          if (deployment.timer.onCalendar != null)
          then deployment.timer.onCalendar
          else ""
        }";
        Unit = "clonix@${generateDeploymentHash deployment}.service";
      };
    };
  };
in {
  options.services.clonix = import ./options.nix {inherit lib pkgs;};

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mkMerge (lib.lists.flatten (builtins.map generateService cfg.deployments));
    systemd.timers = lib.mkMerge (lib.lists.flatten (builtins.map generateTimer cfg.deployments));
  };
}
