# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:
let
  inherit (builtins) any attrValues concatStringsSep getAttr;
  inherit (lib) filterAttrs mapAttrs' mkIf mkMerge mkOption nameValuePair types;

  user = "dn42-update";
  spoolDir = "/var/spool/dn42-update";

  generateUpdateService = name: cfg: {
    description = "${name} dn42 updater";
    after = [ "network-online.target" ];
    before = cfg.services;
    path = [ pkgs.coreutils pkgs.curl ] ++ cfg.processPackages;
    script = ''
      set -euo pipefail
      if curl --fail --no-progress-meter --location --output /tmp/download "${cfg.source}"; then
        {
        ${cfg.process}
        } </tmp/download >/tmp/generated
        chmod 0444 /tmp/generated
        mv /tmp/generated "${spoolDir}/${name}"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      TimeoutSec = 60;

      User = user;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      PrivateDevices = true;
      PrivateTmp = true;
      DevicePolicy = "closed";
      MemoryDenyWriteExecute = true;
      ReadWritePaths = [ spoolDir ];
    };
  };

  generateTimer = name: cfg: {
    wantedBy = [ "timers.target" ];
    after = [ "network-online.target" ];
    before = cfg.services;
    description = "${name} dn42 update timer";
    timerConfig = {
      OnBootSec = cfg.interval;
      OnUnitActiveSec = cfg.interval;
    };
  };

  generatePathWatcher = name: cfg: {
    wantedBy = [ "multi-user.target" ];
    description = "${name} reload notifier";
    pathConfig = {
      PathExists = "${spoolDir}/${name}";
    };
  };

  generateReloadService = name: cfg: {
    description = "${name} reloader";
    script = ''
      mv "${spoolDir}/${name}" "${cfg.destination}"
      ${cfg.reload}
    '';
    serviceConfig = {
      Type = "oneshot";
      ReadWritePaths = [ spoolDir (dirOf cfg.destination) ];
    };
  };

  generateUnits = prefix: generator:
    mapAttrs'
      (name: value: nameValuePair "${prefix}-${name}" (generator name value))
      (filterAttrs (_: getAttr "enable") config.dn42.updaters);
in
{

  options = {
    dn42.updaters = mkOption {
      description = "dn42 update services.";
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          enable = mkOption {
            description = "Whether to enable this dn42 updater.";
            type = types.bool;
            default = false;
          };
          source = mkOption {
            description = "URL to download as input for the updater.";
            type = types.str;
          };
          destination = mkOption {
            description = "File which is updated by the service.";
            type = types.path;
          };
          process = mkOption {
            description = "Shell script code to execute to transform the source data.";
            type = types.lines;
            default = "${pkgs.coreutils}/bin/cat";
          };
          processPackages = mkOption {
            description = "Extra packages to add to the service path.";
            type = types.listOf types.package;
            default = [ ];
          };
          services = mkOption {
            description = "Services affected by this update.";
            type = types.listOf types.str;
            default = [ ];
          };
          reload = mkOption {
            description = "Commands used to reload or restart the dependent services, run as root.";
            type = types.lines;
            default = "/run/current-system/systemd/bin/systemctl try-reload-or-restart ${concatStringsSep " " config.services}";
            defaultText = "/run/current-system/systemd/bin/systemctl try-reload-or-restart \${services}";
          };
          group = mkOption {
            description = "Group to run the updater as, and which will own the updated file.";
            type = types.str;
          };
          interval = mkOption {
            description = "systemd time interval at which the updater is run.";
            type = types.str;
          };
        };
      }));
      default = { };
    };
  };

  config = mkIf (any (getAttr "enable") (attrValues config.dn42.updaters)) {
    systemd.services = mkMerge [
      (generateUnits "dn42-updater" generateUpdateService)
      (generateUnits "dn42-updater-reload" generateReloadService)
    ];
    systemd.timers = generateUnits "dn42-updater" generateTimer;
    systemd.paths = generateUnits "dn42-updater-reload" generatePathWatcher;

    # Create the service user.
    users.users.${user} = {
      description = "dn42 update runner";
      group = user;
    };
    users.groups.${user} = { };

    # Create the spool directory
    systemd.tmpfiles.rules = [
      "d ${spoolDir} 0700 ${user} ${user} -"
    ];
  };

}
