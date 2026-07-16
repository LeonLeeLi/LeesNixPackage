{ stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, lib
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zcode";
  version = "0.1.0";

  src = fetchurl {
    url = "https://example.com/zcode_${finalAttrs.version}_amd64.deb";
    hash = ""; # replace with actual hash: nix-prefetch-url <url> or use lib.fakeHash first
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    mv opt/ZCode .
    mv usr/share .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt
    mv ZCode $out/opt/
    mv share $out/share
    substituteInPlace $out/share/applications/zcode.desktop \
      --replace-fail '/opt/ZCode/zcode' "$out/bin/zcode"
    mkdir -p $out/bin
    ln -s $out/opt/ZCode/zcode $out/bin/zcode
    runHook postInstall
  '';

  meta = with lib; {
    description = "Zcode, Simple, Fast, Vibe‑Ready ! z.ai agent client";
    homepage = "https://zcode.z.ai";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
    mainProgram = "zcode";
  };
})
