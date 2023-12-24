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
    delve
    unstable.devpod
    direnv
    docker-credential-helpers
    dos2unix
    fpp
    fzf
    gdu
    gh
    unstable.go_1_21
    go-jsonnet
    gofumpt
    (unstable.golangci-lint.override {
      buildGoModule = unstable.buildGo121Module;
    })
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    (unstable.gopls.override {
      buildGoModule = unstable.buildGo121Module;
    })
    goreleaser
    gotools
    grpcurl
    hadolint
    htop
    imagemagick
    jq
    jsonnet-bundler
    jsonnet-language-server
    kube3d
    kubectl-explore
    kubectx
    (linkFarm "kubectl-ctx" [
      { name = "bin/kubectl-ctx"; path = "${kubectx}/bin/kubectx"; }
      { name = "bin/kubectl-ns"; path = "${kubectx}/bin/kubens"; }
    ])
    lazygit
    neovim
    nixpkgs-fmt
    nmap
    nodePackages.bash-language-server
    nodePackages.pnpm
    nodePackages.prettier
    nodePackages.ts-node
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs
    perl
    podman-compose
    poetry
    popeye
    pre-commit
    pwgen
    python3
    python3Packages.pipx
    python3Packages.python-lsp-server
    python3Packages.virtualenv
    python3Packages.virtualenvwrapper
    regctl
    ripgrep
    rnix-lsp
    rtx
    unstable.ruff
    unstable.ruff-lsp
    rustup
    shellcheck
    shfmt
    solo2-cli
    ssm-session-manager-plugin
    stern
    tanka
    tcptraceroute
    terraform-ls
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
    # https://github.com/NixOS/nixpkgs/pull/271088
    unstable.zsh-fzf-tab
    zsh-syntax-highlighting
  ];
}
