{
  lib,
  pkgs,
  cfg,
  generateDeploymentHash,
  ...
}: let
  generateProperRsyncCmd = (
    deployment:
      "${cfg.packages.rsync}/bin/rsync "
      + "${
        if (deployment.extraOptions != null)
        then deployment.extraOptions + " "
        else ""
      }"
      + "-avh "
      + "${
        if deployment.remote.enable == true
        then
          (
            (
              if deployment.remote.user.password != null
              then "--rsh=\"${cfg.packages.sshpass}/bin/sshpass -p ${deployment.remote.user.password} ${cfg.packages.openssh}/bin/ssh -o StrictHostKeyChecking=no -l ${deployment.remote.user.name}\" "
              else ""
            )
            + (
              if deployment.remote.user.keyfile != null
              then "-e \"${cfg.packages.openssh}/bin/ssh -i ${deployment.remote.user.keyfile}\" "
              else ""
            )
          )
        else ""
      }"
      + "${
        if (builtins.length deployment.local.exclude > 0)
        then "--exclude={${lib.concatStringsSep "," deployment.local.exclude} "
        else ""
      }"
      + "${deployment.local.dir}/* "
      + "${
        if deployment.remote.enable == true
        then "${deployment.remote.user.name}@${deployment.remote.ipOrHostname}:${deployment.targetDir} "
        else "${deployment.targetDir} "
      }"
  );

  uniqueRsyncCmd = (
    deployment: ''
      if [ "$1"  == "${generateDeploymentHash deployment}" ] ; then 

        ${generateProperRsyncCmd deployment}
      
      fi''
  );
in
  pkgs.writeShellScriptBin "clonix-main" ''
    set -euo pipefail
    ${lib.concatMapStringsSep "\n" (deployment:
      if (deployment != null)
      then (uniqueRsyncCmd deployment)
      else "")
    cfg.deployments}
  ''
