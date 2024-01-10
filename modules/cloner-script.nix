{
  lib,
  pkgs,
  cfg,
  generateDeploymentHash,
  ...
}: let
  generateProperRsyncCmd = (
    deployment: ''
      ${cfg.rsyncPackage}/bin/rsync \
      ${
        if (deployment.extraOptions != null)
        then deployment.extraOptions
        else ""
      } -avh \
      ${deployment.local.dir}/* \
      ${
        if deployment.remote.enable == true
        then
          (
            (
              if deployment.remote.user.password != null
              then ("--rsh=\"${deployment.remote.user.sshpass.package}/bin/sshpass -p ${deployment.remote.user.password} ssh -o StrictHostKeyChecking=no -l ${deployment.remote.user.name}\" " + ''\'' + "\n")
              else ""
            )
            + (
              if deployment.remote.user.keyfile != null
              then "-i ${deployment.remote.user.keyfile}"
              else ""
            )
            + "${deployment.remote.user.name}@${deployment.remote.ipOrHostname}:${deployment.targetDir}"
          )
        else "${deployment.targetDir}"
      }
    ''
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
