{
  lib,
  pkgs,
  cfg,
  generateDeploymentHash,
  ...
}: let
  generateProperRsyncCmd = (
    deployment: ''
      ${pkgs.rsync} \
      ${if (deployment.extraOptions != null) then deployment.extraOptions else ""} -avh \
      ${deployment.local.dir} \
      ${if deployment.remote.enable == true then (
	  (if deployment.remote.password != null then
	    (''--rsh=\"${deployment.remote.sshpass.package} -p password ${deployment.remote.user.password} -o StrictHostKeyChecking=no -l ${deployment.remote.user.name}\" \'') 
	  else "")
          + 
	  (if deployment.remote.keyfile != null then
	    ("-i ${deployment.remote.keyfile}") 
	  else "")
          + 
	  "${deployment.remote.user.name}@${deployment.remote.ipOrHostname}:${deployment.targetDir}")
        else "${deployment.targetDir}"}
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
    ${lib.concatMapStringsSep "\n" (deployment: if (deployment != null) then (uniqueRsyncCmd deployment) else "") cfg.deployments}
  ''
