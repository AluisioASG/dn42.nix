# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{
  description = "dn42 peer finder";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    let
      exports = {
        nixosModule = import ./module.nix;
        overlay = final: prev: {
          dn42-peerfinder.client = final.callPackage ./client.nix { };
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
