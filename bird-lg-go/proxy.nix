# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ buildGoModule, callPackage }:
let common = callPackage ./common.nix { };
in
buildGoModule {
  pname = "bird-lg-go-proxy";
  inherit (common) version src;
  sourceRoot = "source/proxy";

  vendorSha256 = "sha256-7LZeCY4xSxREsQ+Dc2XSpu2ZI8CLE0mz0yoThP7/OO4=";

  meta = common.meta // { description = "${common.meta.description} (frontend)"; };
}
