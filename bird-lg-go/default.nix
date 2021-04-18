# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib, callPackage, fetchFromGitHub, runCommand }:
let
  pname = "bird-lg-go";
  version = "2021-04-09-unstable";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "6e19b5ae6449cd636f739e287dadfbf194aa2933";
    hash = "sha256-/gYQ4vc3muIIlVFuCtYLvigDQ9GvrFO6ibgOrYd4QT8=";
  };

  meta = with lib; {
    description = "Looking glass for the BIRD Internet Routing Daemon";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };

  frontend = callPackage ./frontend.nix { inherit src version meta; };
  proxy = callPackage ./proxy.nix { inherit src version meta; };
in
runCommand "${pname}-${version}" { inherit pname version meta frontend proxy; } ''
  install -D $frontend/bin/frontend $out/bin/bird-lg-go
  install -D $proxy/bin/proxy $out/bin/bird-lg-go-proxy
''
