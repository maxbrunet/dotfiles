{
  lib,
  stdenvNoCC,
  fetchNpmDeps,
  nodejs,
  npmHooks,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-deps";
  version = "1.18.33";

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
    hash = "sha256-YcJnhzAEjMjy1WEM6TnQo3U+SKIfOMfCedfpuJd4Nzo=";
  };

  installPhase = ''
    mkdir $out
    cp -R node_modules $out
  '';
})
