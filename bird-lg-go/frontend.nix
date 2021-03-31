# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ stdenv, pkgs, buildGoModule, go-bindata, nodejs, meta, src, version }:
let
  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  copyNodeFile = packageAttr: sourcePath: destinationPath:
    let pkg = nodePackages.${packageAttr};
    in
    ''
      install -Dm0644 ${pkg}/lib/node_modules/${pkg.packageName}/${sourcePath} ${destinationPath}
    '';
in
buildGoModule {
  pname = "bird-lg-go";
  inherit version src;
  sourceRoot = "source/frontend";
  patches = [
    ./skip_network_tests.patch
    ./vendor_npm.patch
  ];

  vendorSha256 = "sha256-jeQc6w4/0wWmvdEM370RUw2svvRqGIY1Ji4UDzOwP7M=";

  nativeBuildInputs = [ go-bindata ];

  preBuild = ''
    ${copyNodeFile "bootstrap-4.5.1" "dist/css/bootstrap.min.css" "bindata/static/bootstrap.min.css"}
    ${copyNodeFile "bootstrap-4.5.1" "dist/js/bootstrap.min.js" "bindata/static/bootstrap.min.js"}
    ${copyNodeFile "jquery-3.5.1" "dist/jquery.min.js" "bindata/static/jquery.min.js"}
    ${copyNodeFile "viz.js-2.1.2" "lite.render.js" "bindata/static/lite.render.js"}
    ${copyNodeFile "viz.js-2.1.2" "viz.js" "bindata/static/viz.min.js"}
    go generate
  '';

  meta = meta // { description = "${meta.description} (frontend)"; };
}
