# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{
  description = "dn42 peer finder";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    src = { url = "git+ssh://git@git.dn42.dev/dn42/pingfinder.git"; flake = false; };
  };

  outputs = { self, flake-utils, nixpkgs, src }:
    let
      exports = {
        nixosModule = import ./module.nix;
        overlay = final: prev: {
          dn42-peerfinder.client = final.callPackage ./client.nix {
            inherit src;
          };
        };
      };
      outputs = flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        inherit (exports) overlay;
        name = "dn42-peerfinder";
      };
    in
    exports // outputs;
}
