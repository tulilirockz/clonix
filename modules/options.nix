{
  pkgs,
  lib,
  ...
}: let
  deploymentOptions = _: {
    options = {
      deploymentName = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "The deployments tag name";
      };
      local = lib.mkOption {
        type = lib.types.submodule (_: {
          options = {
            dir = lib.mkOption {
              type = lib.types.str;
              default = null;
              description = "Path that will be used as the local directory";
            };
            user = lib.mkOption {
              type = with lib.types; str;
              default = null;
              description = "User that will run the rsync command";
            };
          };
        });
      };
      targetDir = lib.mkOption {
        type = lib.types.str;
        default = null;
        description = "Path that will be used as the target directory";
      };
      extraOptions = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Extra CLI options for rsync";
      };
      remote = lib.mkOption {
        default = {enable = false;};
        type = with lib.types;
          submodule (_: {
            options = {
              enable = lib.mkEnableOption {
                type = lib.types.bool;
                default = false;
                description = "Whether or not rsync will be manage remotes";
              };
              ipOrHostname = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Target remote IP or Hostname";
              };
              user = lib.mkOption {
                default = {};
                type = lib.types.submodule (_: {
                  options = {
                    name = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                      description = "Target username for the remote";
                    };
                    password = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                      description = "Target password for the remote";
                    };
                    
		    # TODO: Implement ssh keyfile password
                    keyfile = lib.mkOption {
                      type = lib.types.nullOr lib.types.path;
                      default = null;
                      description = "SSH keyfile that will be used for authentication";
                    };
                  };
                });
              };
            };
          });
      };
    };
  };
in {
  enable = lib.mkEnableOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable clonix declarative management.";
  };
  deployments = lib.mkOption {
    type = with lib.types; listOf (submodule deploymentOptions);
    default = null;
    description = ''
      Declare a list of deployments.
    '';
    example = lib.literalExpression ''
      [{ deploymentName = "amogus"; local.dir = /path/to/abspath; targetDir = /path/to/abspath; remote.enable = true; remote.user = "root"; remote.ipOrHostname = "192.168.1.1"}]
    '';
  };
  packages = lib.mkOption {
    default = {
      sshpass = pkgs.sshpass;
      openssh = pkgs.openssh;
      rsync = pkgs.rsync;
    };
    type = lib.types.submodule(_:{
      options = {
	rsync = lib.mkOption {
  	  type = lib.types.package;
  	  default = pkgs.rsync;
  	  description = "Rsync package to be used";
  	};
  	sshpass = lib.mkOption {
	  type = lib.types.package;
	  default = pkgs.sshpass;
  	  description = "Sshpass package to be used";
  	};
	openssh = lib.mkOption {
	  type = lib.types.package;
	  default = pkgs.openssh;
  	  description = "Openssh package to be used";
	};
      };
    });
  };
}
