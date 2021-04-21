# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib, pkgs, ... }:
let
  argJSON = v: lib.escapeShellArg (builtins.toJSON v);

  # List of zones queried from the dn42 nameservers.
  dn42_zones = [
    "dn42."
    "20.172.in-addr.arpa."
    "21.172.in-addr.arpa."
    "22.172.in-addr.arpa."
    "23.172.in-addr.arpa."
    "d.f.ip6.arpa."
  ];
  # List of zones queried from the NeoNetwork nameservers.
  neonetwork_zones = [
    "neo."
    "127.10.in-addr.arpa."
    "7.2.1.0.0.1.d.f.ip6.arpa."
  ];
in
{
  # Update the dn42 root servers and DNSSEC keys regularly.
  dn42.updaters.unbound-roots = {
    source = "https://explorer.burble.com/api/registry/domain/delegation-servers.dn42/nserver";
    destination = "/var/lib/unbound/dn42_stub_addrs.conf";
    defaultContents = "";
    processPackages = [ pkgs.jq ];
    process = ''
      jq --raw-output '."domain/delegation-servers.dn42".nserver | .[] | split(" ") | "stub-addr: \(.[1])@53#\(.[0])"'
    '';
    services = [ "unbound.service" ];
    interval = "1day";
  };

  dn42.updaters.unbound-dnssec = {
    source = "https://explorer.burble.com/api/registry/domain/dn42/ds-rdata";
    destination = "/var/lib/unbound/dn42.key";
    defaultContents = "";
    processPackages = [ pkgs.jq ];
    process = ''
      jq --raw-output --argjson zones ${argJSON dn42_zones} '."domain/dn42"."ds-rdata" | .[] as $rdata | $zones[] as $zone | "\($zone) IN DS \($rdata)"'
    '';
    services = [ "unbound.service" ];
    interval = "1day";
  };

  dn42.updaters.unbound-dnssec-neonetwork = {
    source = "https://explorer.burble.com/api/registry/domain/neo/ds-rdata";
    destination = "/var/lib/unbound/neonetwork.key";
    defaultContents = "";
    processPackages = [ pkgs.jq ];
    process = ''
      jq --raw-output --argjson zones ${argJSON neonetwork_zones} '."domain/neo"."ds-rdata" | .[] as $rdata | $zones[] as $zone | "\($zone) IN DS \($rdata)"'
    '';
    services = [ "unbound.service" ];
    interval = "1day";
  };
}
