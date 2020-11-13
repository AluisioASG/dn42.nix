# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.dn42-peerfinder;
in
{
  options = {
    services.dn42-peerfinder.client = {
      enable = mkEnableOption "dn42 peer finder client script";

      serviceUrl = mkOption {
        description = "URL of the peer finder service to connect to.";
        default = "https://dn42.us/peer";
        type = types.str;
      };

      uuidFile = mkOption {
        description = ''
          File containing the identifier of the machine in the peer finder service.
          The file must be formatted as an assignment to the environment variable `UUID`.
        '';
        type = types.path;
      };

      numPings = mkOption {
        description = "Number of pings to send for each request.";
        type = types.ints.positive;
      };
    };
  };

  config = {
    systemd.services.dn42-peerfinder-client = mkIf cfg.client.enable {
      description = "dn42 peer finder client";
      after = [ "network-online.target" ];
      environment = {
        PEERFINDER = cfg.client.serviceUrl;
        NB_PINGS = toString cfg.client.numPings;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.dn42-peerfinder.client}/bin/peerfinder'';
        EnvironmentFile = cfg.client.uuidFile;
        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        PrivateTmp = true;
      };
    };

    systemd.timers.dn42-peerfinder-client = mkIf cfg.client.enable {
      wantedBy = [ "timers.target" ];
      after = [ "network-online.target" ];
      description = "dn42 peer finder processing timer";
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
