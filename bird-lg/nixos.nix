# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mkDefault mkEnableOption mkIf mkOption types;
  settingsFormat = pkgs.formats.json { };

  cfg = config.services.bird-lg;

  sharedOptions = description: {
    enable = mkEnableOption description;

    logToSyslog = mkOption {
      description = "Whether to log to journald via syslog instead of writing to stderr.";
      type = types.bool;
      default = true;
    };

    appSettings = mkOption {
      description = "Configuration for bird-lg.";
      type = settingsFormat.type;
      default = { };
    };

    gunicornSettings = mkOption {
      description = "Configuration for the Gunicorn runner.";
      type = settingsFormat.type;
      default = { };
    };

    extraConfigFiles = mkOption {
      description = "Extra JSON files containing configuration, for example secrets.";
      type = types.listOf types.path;
      default = [ ];
    };
  };

  gunicornDefaults = subcfg: mkIf subcfg.logToSyslog {
    errorlog = mkDefault "/dev/null";
    syslog = mkDefault true;
    syslog_addr = mkDefault "unix:///dev/log";
  };

  sharedService = { description, script, subcfg }: mkIf subcfg.enable {
    inherit description;
    requires = [ "network-online.target" ];
    after = [ "bird.service" "bird6.service" "bird2.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      BIRD_LG_CONFIG = ./bird-lg-config.py;
      BIRD_LG_CONFIG_FILES = concatStringsSep ":" ([
        (settingsFormat.generate "${script}-gunicorn.json" subcfg.gunicornSettings)
        (settingsFormat.generate "${script}.json" subcfg.appSettings)
      ] ++ subcfg.extraConfigFiles);
      BIRD_LG_SYSLOG = toString subcfg.logToSyslog;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dn42.bird-lg}/bin/${script} --config=\${BIRD_LG_CONFIG}";
      Restart = "on-failure";

      DynamicUser = true;
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
    };
  };
in
{

  options = {
    services.bird-lg.server = sharedOptions "BIRD looking glass server";
    services.bird-lg.client = sharedOptions "BIRD looking glass client proxy";
  };

  config = {

    ################
    # Server setup #
    ################

    services.bird-lg.server.appSettings = {
      DEBUG = mkDefault true;
      LOG_LEVEL = mkDefault "WARNING";
      PROXY = mkDefault { };
      PROXY_TIMEOUT = mkDefault {
        bird = 10;
        traceroute = 60;
      };
      UNIFIED_DAEMON = mkDefault true;
    };

    services.bird-lg.server.mkGunicornSettings = gunicornDefaults cfg.server;

    systemd.services.bird-lg-server = sharedService {
      description = "BIRD looking glass web server";
      script = "bird-lg";
      subcfg = cfg.server;
    };

    ######################
    # Client proxy setup #
    ######################

    services.bird-lg.client.appSettings = {
      DEBUG = mkDefault false;
      LOG_LEVEL = mkDefault "WARNING";
      BIRD_SOCKET = mkDefault "/run/bird.ctl";
      BIRD6_SOCKET = mkDefault "/run/bird6.ctl";
    };

    services.bird-lg.client.gunicornSettings = gunicornDefaults cfg.client;

    systemd.services.bird-lg-client = sharedService {
      description = "BIRD looking glass client proxy";
      script = "bird-lgproxy";
      subcfg = cfg.client;
    };
  };

}
