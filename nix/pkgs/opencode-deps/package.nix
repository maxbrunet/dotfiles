{
  lib,
  stdenvNoCC,
  fetchNpmDeps,
  nodejs,
  npmHooks,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-deps";
  version = "1.18.35";

  src = lib.filterSource (
    path: type:
    lib.elem (lib.baseNameOf path) [
      "package.json"
      "package-lock.json"
    ]
  ) ../../../.config/opencode;

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    npmHooks.npmInstallHook
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-9byZ1t4PWGXdyhnN1wW6UUabmNLjCcahXa6bwbaIFJw=";
  };

  npmRebuildFlags = [ "--ignore-scripts" ];

  installPhase = ''
    mkdir $out
    cp -R node_modules $out
  '';
})
