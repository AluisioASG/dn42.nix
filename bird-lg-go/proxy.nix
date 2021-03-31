# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ buildGoModule, meta, src, version }:
buildGoModule {
  pname = "bird-lg-go-proxy";
  inherit version src;
  sourceRoot = "source/proxy";

  vendorSha256 = "sha256-7LZeCY4xSxREsQ+Dc2XSpu2ZI8CLE0mz0yoThP7/OO4=";

  meta = meta // { description = "${meta.description} (frontend)"; };
}
