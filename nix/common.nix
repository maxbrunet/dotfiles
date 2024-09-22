{ pkgs }:

{
  packages = with pkgs; [
    amazon-ecr-credential-helper
    android-tools
    argocd
    aws-vault
    awscli2
    bat
    bottom
    buf
    cmake
    d2
    delta
    (unstable.delve.override {
      buildGoModule = unstable.buildGo123Module;
    })
    devpod
    direnv
    docker-credential-helpers
    dockerfile-language-server-nodejs
    dos2unix
    fd
    fpp
    fzf
    gdu
    git-lfs
    gh
    unstable.go_1_23
    go-jsonnet
    gofumpt
    unstable.golangci-lint
    golangci-lint-langserver
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    (unstable.gopls.override {
      buildGoModule = unstable.buildGo123Module;
    })
    goreleaser
    gotools
    grpcurl
    hadolint
    helm-ls
    htop
    imagemagick
    jq
    jsonnet-bundler
    jsonnet-language-server
    kube3d
    kubecolor
    kubectl
    kubectl-explore
    kubectx
    (linkFarm "kubectl-ctx" [
      { name = "bin/kubectl-ctx"; path = "${kubectx}/bin/kubectx"; }
      { name = "bin/kubectl-ns"; path = "${kubectx}/bin/kubens"; }
    ])
    kubernetes-helm
    kustomize
    lazygit
    (unstable.llm-ls.overrideAttrs (previousAttrs: rec {
      # https://github.com/huggingface/llm-ls/pull/104
      src = fetchFromGitHub {
        owner = "huggingface";
        repo = "llm-ls";
        rev = "fc5f4d249d78108aeed33b1cc464c4e9bcccd82c";
        sha256 = "sha256-0xlJOip68gQ9TKJmu8DdVsgk5qetQPb/YbV3HTlf0b8=";
      };
      patches = [ (builtins.elemAt previousAttrs.patches 0) ];
      cargoDeps = previousAttrs.cargoDeps.overrideAttrs (lib.const {
        name = "${previousAttrs.pname}-${previousAttrs.version}-vendor.tar.gz";
        inherit src patches;
        outputHash = "sha256-m/w9aJZCCh1rgnHlkGQD/pUDoWn2/WRVt5X4pFx9nC4=";
      });
    }))
    lua-language-server
    marksman
    unstable.mods
    neovim
    nixd
    nixpkgs-fmt
    nmap
    nodePackages.bash-language-server
    nodePackages.prettier
    nodePackages.ts-node
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs
    oci-cli
    (pdm.overrideAttrs (_: previousAttrs: {
      propagatedBuildInputs =
        previousAttrs.propagatedBuildInputs ++
        (with python3Packages; [
          keyrings-google-artifactregistry-auth
        ]);
    }))
    perl
    unstable.pnpm
    podman-compose
    poetry
    popeye
    pre-commit
    pwgen
    python3
    python3Packages.python-lsp-server
    regctl
    ripgrep
    unstable.ruff
    rustup
    shellcheck
    shfmt
    solo2-cli
    ssm-session-manager-plugin
    stern
    tanka
    tcptraceroute
    unstable.terraform-ls
    tflint
    tfswitch
    tmux
    tree
    urlscan
    unstable.uv
    wget
    yarn
    yq-go
    zsh-autosuggestions
    (zsh-completions.overrideAttrs (_: _: {
      installPhase = ''
        functions=(
          _direnv
          _golang
          _grpcurl
          _node
          _ts-node
          _tsc
          _yarn
        )
        install -D --target-directory=$out/share/zsh/site-functions "''${functions[@]/#/src/}"
      '';
    }))
    zsh-fzf-tab
    zsh-syntax-highlighting
  ];
}
