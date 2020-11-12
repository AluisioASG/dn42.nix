{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.services.dn42-pingfinder.client;
in
{
  options = {
    services.dn42-pingfinder.client = {
      enable = mkEnableOption "dn42-pingfinder client script";

      serviceUrl = mkOption {
        description = "URL of the peerfinder service to connect to.";
        default = "https://dn42.us/peer";
        type = types.str;
      };

      uuid = mkOption {
        description = "Identifier of the machine in the peerfinder service.";
        type = types.strMatching " [[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}";
      };

      numPings = mkOption {
        description = "Number of pings to send for each request.";
        type = types.ints.positive;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dn42-pingfinder-client = {
      description = "dn42 PingFinder client";
      after = [ "network-online.target" ];
      environment = {
        PEERFINDER = cfg.serviceUrl;
        UUID = cfg.uuid;
        NB_PINGS = toString cfg.numPings;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.dn42-pingfinder-client}/bin/pingfinder'';
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
  };
}
