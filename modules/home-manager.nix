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
  generateTimer = deployment: {
    "clonix@${generateDeploymentHash deployment}" = {
      Timer = {
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
