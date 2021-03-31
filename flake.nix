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
          updaters = import ./updaters/nixos.nix;
          updaters-asn = import ./updaters/asn-dns-zone.nix;
          updaters-bird = import ./updaters/bird.nix;
          updaters-unbound = import ./updaters/unbound.nix;
          bird-lg = import ./bird-lg/nixos.nix;
          peerfinder-client = import ./peerfinder-client/nixos.nix;
        };
        # Compose all modules into one, for convenience.
        nixosModule = {
          imports = builtins.attrValues self.nixosModules;
        };
        overlay = final: prev: {
          dn42.bird-lg = final.callPackage ./bird-lg { };
          dn42.bird-lg-go = final.callPackage ./bird-lg-go { };
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
