# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
# SPDX-License-Identifier: MIT

{ stdenv
, makeWrapper
, coreutils
, curl
, gnugrep
, iputils
, which
}:

stdenv.mkDerivation rec {
  name = "dn42-peerfinder-client";

  src = ./client.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    mv "${src}" "$out/bin/peerfinder"
    wrapProgram "$out/bin/peerfinder" --set PATH "${stdenv.lib.makeBinPath [
      coreutils
      curl
      gnugrep
      iputils
      which
    ]}"
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Measurement script for the dn42 peer finder";
    homepage = "https://dn42.us/peers";
    license = licenses.bsd2;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.gnu;
  };
}
