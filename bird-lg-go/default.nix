# SPDX-FileCopyrightText: 2021 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib, callPackage, fetchFromGitHub, runCommand }:
let
  pname = "bird-lg-go";
  version = "2021-03-31-unstable";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "5b5a09ccbddc2b35e080a9df0237ce6cc97a25a3";
    hash = "sha256-5lfOmbS3A+EwAINGQwqTLvhnh+kcpN5qKTQj4yCyNsM=";
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
