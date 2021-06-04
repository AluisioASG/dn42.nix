# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ lib
, stdenv
, makeWrapper
, writeScriptBin
, coreutils
, curl
, gnugrep
, iputils
, which
}:
let silentWhich = writeScriptBin "which" ''
  exec "${which}/bin/which" "$@" 2>/dev/null
'';
in
stdenv.mkDerivation rec {
  name = "dn42-peerfinder-client";

  src = ./client.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    mv "${src}" "$out/bin/peerfinder"
    wrapProgram "$out/bin/peerfinder" --set PATH "${lib.makeBinPath [
      coreutils
      curl
      gnugrep
      iputils
      silentWhich
    ]}"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Measurement script for the dn42 peer finder";
    homepage = "https://dn42.us/peers";
    license = licenses.bsd2;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
