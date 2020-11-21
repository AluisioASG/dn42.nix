# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # Template updater for the dn42 ASN records.
  #
  # Be sure to set the destination file and reload scripts, and to set
  # an `$ORIGIN` and SOA and NS records using `mkBefore` in the process
  # script.
  dn42.updaters.asn = {
    source = "https://explorer.burble.com/api/registry/aut-num/*?raw";
    processPackages = [ pkgs.glibc.bin pkgs.jq ];
    process =
      let
        ttl = "86400";
        filter = pkgs.writeText "jq-dn42-asn-filter" ''
          .[]
          | map({key: .[0], value: .[1]})
          | from_entries
          | "\(."aut-num" | ltrimstr("AS")) | | \(.source | ascii_downcase) | | \(."as-name")" as $rdata
          | "\(."aut-num") \($ttl) IN TXT \"\($rdata)\""
        '';
      in
      ''
        jq --from-file "${filter}" --arg ttl "${ttl}" --raw-output \
        | iconv --from-code=UTF-8 --to-code=ASCII//TRANSLIT
      '';
    interval = "1day";
  };
}
