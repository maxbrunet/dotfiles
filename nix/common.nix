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
    (unstable.golangci-lint.override {
      buildGoModule = unstable.buildGo123Module;
    })
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
    python3Packages.pipx
    python3Packages.python-lsp-server
    regctl
    ripgrep
    ruff
    ruff-lsp
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
