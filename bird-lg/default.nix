# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib, stdenv, fetchFromGitHub, fetchpatch, graphviz, python3, traceroute, whois }:
let
  runtimeDeps = [
    (python3.withPackages (ps: with ps; [
      flask
      dnspython
      gunicorn
      pydot
      memcached
    ]))
    graphviz
    whois
    traceroute
  ];
in
stdenv.mkDerivation rec {
  pname = "bird-lg-burble";
  version = "2020-05-20-unstable";

  src = fetchFromGitHub {
    owner = "sesa-me";
    repo = "bird-lg";
    rev = "f3699a3b61f2d9f77cb17fb163bcf3c3ad722835"; # refs/head/burble-clean
    sha256 = "0gisi6mbfclw36kms3qy3b0wzcwdkd50p2a6xdwggln4fi5y6bh1";
  };

  patches = [
    (fetchpatch {
      name = "bird-lg_fix_bgpmap_generation.patch";
      url = "https://github.com/miegl/bird-lg/commit/db8fb829d51889fab61bfb5ffac89199442d3117.patch";
      sha256 = "1vwr7ck5v7w4fr78kbc4wxyj3licsw7h0772xkmmxsb8vp9vcihg";
    })
    (fetchpatch {
      name = "bird-lg_dont_configure_log_file.patch";
      url = "https://github.com/AluisioASG/bird-lg/commit/e58112848e7160fb3cb71b5ca674ac3537e12b05.patch";
      sha256 = "0daqkql0a8slqap8pybngm4al96pcki69vai0807vck4gi4paw0z";
    })
  ];
  postPatch = ''
    # Replace the builtin config file with one given through an
    # environment variable.
    sed -i '/app\.config\.from_pyfile/c app.config.from_envvar("BIRD_LG_CONFIG")' lg.py lgproxy.py
  '';

  WRAPPER_PATH = lib.makeBinPath runtimeDeps;
  WRAPPER_PYTHONPATH = placeholder "out";
  installPhase = ''
    function wrapWSGI {
      set -e
      substitute ${./run-wsgi.sh} "$2" \
        --subst-var shell \
        --subst-var WRAPPER_PATH \
        --subst-var WRAPPER_PYTHONPATH \
        --subst-var-by SCRIPT "$1"
      chmod +x "$2"
    }

    runHook preInstall
    mkdir -p $out $out/bin
    cp -r * $out
    touch $out/__init__.py
    wrapWSGI lg:app $out/bin/bird-lg
    wrapWSGI lgproxy:app $out/bin/bird-lgproxy
    runHook postInstall
  '';

  meta = with lib; {
    description = "Looking glass for the BIRD Internet Routing Daemon";
    homepage = "https://github.com/sesa-me/bird-lg";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
