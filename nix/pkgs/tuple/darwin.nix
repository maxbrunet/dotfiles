{
  pname,
  version,
  src,
  strictDeps,
  __structuredAttrs,
  passthru,
  meta,

  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    strictDeps
    __structuredAttrs
    passthru
    meta
    ;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a $src $out/Applications/Tuple.app
    runHook postInstall
  '';
}
