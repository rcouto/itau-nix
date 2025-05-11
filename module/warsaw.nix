{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.warsaw;
in
{
  imports = [ ];

  options = {
    services.warsaw.enable = lib.mkEnableOption "enables warsaw";
    services.warsaw.package = lib.mkPackageOption pkgs "warsaw package" { };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.warsaw = {
      wantedBy = [ "multi-user.target" ];
      after = [
        "multi-user.target"
        "dbus.service"
      ];
      serviceConfig = {
        User = "warsaw";
        Group = "warsaw";

        DynamicUser = true;
        StateDirectory = "warsaw";
        # Restart = "always";
        # RestartSec = 5;

        ExecStart = "${cfg.package}/usr/local/bin/warsaw/core";
        Type = "forking";

        # Hardening
        # CapabilityBoundingSet = [ ];
        # DeviceAllow = [ ];
        # LockPersonality = true;
        # NoNewPrivileges = true;
        # PrivateDevices = true;
        # PrivateTmp = true;
        # PrivateUsers = true;
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectHostname = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # ProtectProc = "invisible";
        # ProtectSystem = "strict";
        # ReadOnlyPaths = [
        #   "/usr"
        #   "/etc"
        #   "/var"
        #   "/nix"
        # ];
        # ReadWritePaths = [ "/run/core.pid" ];
        # RestrictAddressFamilies = [
        #   "AF_INET"
        #   "AF_INET6"
        # ];
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # RestrictSUIDSGID = true;
        # SystemCallArchitectures = "native";
        # SystemCallFilter = [
        #   "@system-service"
        #   "~@privileged"
        #   "~@resources"
        # ];
        TemporaryFileSystem = "/tmp";
        UMask = "0077";
      };
    };
  };
}
