# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  # Template updater for the dn42 ASN records.
  #
  # What here needs to be set for it to be complete:
  # - `destination`
  # - `reload` or `services`
  # - `interval`
  #
  # What needs to be prepended to `process` via `mkBefore`:
  # - `$ORIGIN`
  # - `$TTL`
  # - `SOA`
  # - `NS`
  dn42.updaters.asn = {
    source = "https://explorer.burble.com/api/registry/aut-num/*?raw";
    processPackages = [ pkgs.glibc.bin pkgs.jq ];
    process =
      let
        filter = pkgs.writeText "jq-dn42-asn-filter" ''
          .[]
          | map({key: .[0], value: .[1]})
          | from_entries
          | "\(."aut-num" | ltrimstr("AS")) | | \(.source | ascii_downcase) | | \(."as-name")" as $rdata
          | "\(."aut-num") IN TXT \"\($rdata)\""
        '';
      in
      ''
        jq --from-file "${filter}" --raw-output \
        | iconv --from-code=UTF-8 --to-code=ASCII//TRANSLIT
      '';
  };
}
