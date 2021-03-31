# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mkEnableOption mkIf mkMerge mkOption types;

  serverCfg = config.services.bird-lg-go.server;
  proxyCfg = config.services.bird-lg-go.proxy;
in
{

  options = {

    services.bird-lg-go.server = {
      enable = mkEnableOption "BIRD looking glass frontend";

      targets = mkOption {
        description = "Hostnames of BIRD servers to query.";
        type = types.listOf types.str;
      };

      targetDomain = mkOption {
        description = "Domain of BIRD servers to query. Combined with `targets` to form FQDNs.";
        type = types.str;
      };

      listenAddress = mkOption {
        description = "IP address and port to bind to.";
        default = ":5000";
        type = types.str;
      };

      proxyPort = mkOption {
        description = "Port at which the looking glass proxy listens.";
        default = 8000;
        type = types.port;
      };

      whoisServer = mkOption {
        description = "WHOIS server queried to retrieve AS information.";
        default = "whois.verisign-grs.com";
        type = types.str;
      };

      asnZone = mkOption {
        description = "DNS zone queried to retrieve AS information.";
        default = "asn.cymru.com";
        type = types.str;
      };

      titleBrand = mkOption {
        description = "Prefix of page titles.";
        default = "Bird-lg Go";
        type = types.str;
      };

      navbarBrand = mkOption {
        description = "Brand shown in the navigation bar.";
        default = "Bird-lg Go";
        type = types.str;
      };
    };

    services.bird-lg-go.proxy = {
      enable = mkEnableOption "BIRD looking glass proxy";

      serverIPs = mkOption {
        description = "IP addresses allowed to access the proxy.";
        type = types.nullOr (types.listOf types.str);
        default = null;
      };

      birdSocket = mkOption {
        description = "Path to BIRD's socket.";
        default = "/run/bird.ctl";
        type = types.path;
      };

      listenAddress = mkOption {
        description = "IP address and port to bind to.";
        default = ":5000";
        type = types.str;
      };
    };

  };

  config = mkMerge [
    (mkIf serverCfg.enable {
      systemd.services.bird-lg-go = {
        description = "BIRD looking glass frontend";
        requires = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          BIRDLG_SERVERS = concatStringsSep "," serverCfg.targets;
          BIRDLG_DOMAIN = serverCfg.targetDomain;
          BIRDLG_LISTEN = serverCfg.listenAddress;
          BIRDLG_PROXY_PORT = toString serverCfg.proxyPort;
          BIRDLG_WHOIS = serverCfg.whoisServer;
          BIRDLG_DNS_INTERFACE = serverCfg.asnZone;
          BIRDLG_TITLE_BRAND = serverCfg.titleBrand;
          BIRDLG_NAVBAR_BRAND = serverCfg.navbarBrand;
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.dn42.bird-lg-go}/bin/bird-lg-go";
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
    })

    (mkIf proxyCfg.enable {
      systemd.services.bird-lg-go-proxy = {
        description = "BIRD looking glass proxy";
        requires = [ "network.target" ];
        after = [ "bird.service" "bird6.service" "bird2.service" "network.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          ALLOWED_IPS = concatStringsSep "," proxyCfg.serverIPs;
          BIRD_SOCKET = proxyCfg.birdSocket;
          BIRDLG_LISTEN = proxyCfg.listenAddress;
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.dn42.bird-lg-go}/bin/bird-lg-go-proxy";
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
    })
  ];

}
