# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{
  description = "dn42 packages";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    let
      exports = {
        nixosModules = {
          bird-lg = import ./bird-lg/nixos.nix;
          peerfinder-client = import ./peerfinder-client/nixos.nix;
        };
        overlay = final: prev: {
          dn42.bird-lg = final.callPackage ./bird-lg { };
          dn42.peerfinder-client = final.callPackage ./peerfinder-client { };
        };
      };
      outputs = flake-utils.lib.simpleFlake {
        inherit self nixpkgs;
        inherit (exports) overlay;
        name = "dn42";
      };
    in
    exports // outputs;
}
