{ stdenv
, makeWrapper
, curl
, gnugrep
, iputils
, src ? fetchGit "git@git.dn42.dev:dn42/pingfinder.git"
}:

stdenv.mkDerivation {
  name = "dn42-peerfinder-client";

  inherit src;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace clients/generic-linux-debian-redhat-busybox.sh \
      --replace '"$NB_PINGS"' '-c "$NB_PINGS"'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    mv clients/generic-linux-debian-redhat-busybox.sh "$out/bin/peerfinder"
    wrapProgram "$out/bin/peerfinder" --set PATH "${stdenv.lib.makeBinPath [ curl gnugrep iputils ]}"
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
