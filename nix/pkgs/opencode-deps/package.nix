{
  lib,
  stdenvNoCC,
  fetchNpmDeps,
  nodejs,
  npmHooks,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-deps";
  version = "1.19.0";

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
    hash = "sha256-aUxb0LheZiKSoDi4+8GTx6BROQeV7fgP4z09XwwyK/Y=";
  };

  npmRebuildFlags = [ "--ignore-scripts" ];

  installPhase = ''
    mkdir $out
    cp -R node_modules $out
  '';
})
