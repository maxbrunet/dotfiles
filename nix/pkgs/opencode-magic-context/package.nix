{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  nodejs,
  opencode,
  writableTmpDirAsHomeHook,
}:

let
  node_modules =
    finalAttrs:
    stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-node_modules";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        # Install only the workspaces that get built; other workspaces'
        # floating ranges make bun's hoisting nondeterministic.
        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install \
          --cpu="*" \
          --filter=@cortexkit/opencode-magic-context \
          --filter=@cortexkit/retina-local-fs \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress \
          --os="*"

        # Canonicalize bun's nondeterministic hoisting and .bin link races,
        # as nixpkgs' opencode does.
        bun --bun ${opencode.src}/nix/scripts/canonicalize-node-modules.ts
        bun --bun ${opencode.src}/nix/scripts/normalize-bun-binaries.ts

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;

        runHook postInstall
      '';

      # NOTE: Required else we get errors that our fixed-output derivation
      # references store paths
      dontFixup = true;

      outputHash = "sha256-xhuLxbOQPxxGB/gF1nP/l9ClzsTxjY7J9Ly7Rai3Quo=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-magic-context";
  version = "0.49.9";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "cortexkit";
    repo = "magic-context";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C+7xncAP5vmC2crhDe/ZaFLMRYA3k/ivU3MvfG+gdqw=";
  };

  nativeBuildInputs = [
    bun
    nodejs
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.passthru.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    cd packages/plugin
    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R . $out/
    chmod -R u+w $out
    rm -rf $out/node_modules
    ln -s ${finalAttrs.passthru.node_modules}/packages/plugin/node_modules $out/node_modules

    runHook postInstall
  '';

  passthru = {
    node_modules = node_modules finalAttrs;
  };

  meta = {
    description = "OpenCode plugin for Magic Context - cross-session memory and context management";
    homepage = "https://github.com/cortexkit/magic-context";
    changelog = "https://github.com/cortexkit/magic-context/releases";
    license = lib.licenses.mit;
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
