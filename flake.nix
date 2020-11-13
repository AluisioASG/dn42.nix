# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{
  description = "Measurement script for the dn42 peer finder";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    src = { url = "git+ssh://git@git.dn42.dev/dn42/pingfinder.git"; flake = false; };
  };

  outputs = { self, flake-utils, nixpkgs, src }:
    let
      exports = {
        nixosModule = import ./module.nix;
      };
      outputs = flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        name = "dn42-peerfinder";
        overlay = final: prev: {
          dn42-peerfinder.client = final.callPackage ./client.nix {
            inherit src;
          };
        };
      };
    in
    exports // outputs;
}
