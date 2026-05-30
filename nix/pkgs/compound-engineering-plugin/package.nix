{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "compound-engineering-plugin";
  version = "3.9.3";

  src = fetchFromGitHub {
    owner = "EveryInc";
    repo = "compound-engineering-plugin";
    tag = "compound-engineering-v${finalAttrs.version}";
    hash = "sha256-FwxbWgLIM4Gt3Zmk/2YkIcp5Y8YAfVq8mev/L2rAldE=";
  };

  outputs = [
    "out"
    "opencode"
  ];

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

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

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install --no-progress --frozen-lockfile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/node_modules

      runHook postInstall
    '';

    # NOTE: Required else we get errors that our fixed-output derivation references store paths
    dontFixup = true;

    outputHash = "sha256-n2yixmHYzC+6jy7qK81IuhrDX12/CZwB+lAI98a/Qpg=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
  ];

  buildPhase = ''
    runHook preBuild

    cp -R ${finalAttrs.node_modules}/node_modules .
    patchShebangs node_modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R plugins/compound-engineering/agents $out
    cp -R plugins/compound-engineering/skills $out

    mkdir -p $opencode
    HOME=$PWD bun cli:install compound-engineering --to opencode
    cp -R .config/opencode/agents $opencode
    cp -R .config/opencode/skills $opencode

    runHook postInstall
  '';

  meta = {
    description = "Official Compound Engineering plugin for Claude Code, Codex, Cursor, and more";
    homepage = "https://github.com/EveryInc/compound-engineering-plugin";
    changelog = "https://github.com/EveryInc/compound-engineering-plugin/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.maxbrunet ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
