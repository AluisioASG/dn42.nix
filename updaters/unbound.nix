# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # Update the dn42 root servers and DNSSEC keys regularly.
  dn42.updaters.unbound-roots = {
    source = "https://explorer.burble.com/api/registry/domain/delegation-servers.dn42/nserver";
    destination = "/var/lib/unbound/dn42_stub_addrs.conf";
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
    processPackages = [ pkgs.jq ];
    process = ''
      jq --raw-output '."domain/dn42"."ds-rdata" | .[] | "dn42. IN DS \(.)"'
    '';
    services = [ "unbound.service" ];
    interval = "1day";
  };
}
