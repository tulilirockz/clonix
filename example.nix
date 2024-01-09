{
  services.clonix.enable = true;
  services.clonix.logs.enable = true;
  services.clonix.logs.dir = ./logsdir;
  service.clonix.deployment = [
    {
      timerName = "amogus";
      localDir = /path/to/abspath;
      targetDir = /path/to/abspath;
      remote.enable = true;
      remote.user = "root";
    }
    {
      timerName = "sussy";
      localDir = /path/to/abspath;
      targetDir = /path/to/abspath;
      remote.enable = true;
      remote.user.name = "momoga";
      remote.user.password = "mimiga";
      remote.ipOrHostname = "bazingamachine";
      extraOptions = "-zi";
    }
    {
      timerName = "baus";
      localDir = /path/to/abspath;
      targetDir = /path/to/abspath;
      remote.enable = true;
      remote.user.name = "momoga";
      remote.user.keyfile = /path/to/abspath;
    }
    {
      timerName = "sussy";
      localDir = /path/to/abspath;
      remoteDir = /path/to/abspath;
      remoteUser.name = "momoga";
      remoteUser.keyfile = /path/to/abspath;
      onCalendar = "Mon,Tue *-*-01..04 12:00:00";
      retry.enable = true;
      retry.times = "12";
      retry.timeout = "20m";
      retry.infinite = false; # overrides any other option!
    }
  ];
}
# Heavily inspired by nix-flatpak
# Makes a timer with a name + hash for every entry -> sussyHASH@clonix.service -> Triggers in: Tue 2024-01-09
# All this stuff makes a file in the nix store called clonix-service-manager, which accepts hashes as inputs, and runs rsync as a side effect.
# clonix-service-manager 1236718263781 -> rsync /var/log/boot.log root@192.168.123.123:~/log/host/boot.log

