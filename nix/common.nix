{ pkgs }:

{
  packages = with pkgs; [
    amazon-ecr-credential-helper
    android-tools
    argocd
    aws-vault
    awscli2
    azure-cli
    bash-language-server
    bat
    bottom
    buf
    cmake
    d2
    delta
    unstable.delve
    direnv
    docker-credential-helpers
    dockerfile-language-server
    dos2unix
    unstable.egctl
    fd
    fpp
    fzf
    gdu
    git-lfs
    gh
    unstable.go_1_25
    go-jsonnet
    unstable.golangci-lint
    golangci-lint-langserver
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    unstable.gopls
    goreleaser
    grpcurl
    hadolint
    helm-ls
    htop
    imagemagick
    jq
    jsonnet-bundler
    jsonnet-language-server
    k3d
    kubecolor
    kubectl
    kubectl-explore
    kubectx
    (linkFarm "kubectl-ctx" [
      {
        name = "bin/kubectl-ctx";
        path = "${kubectx}/bin/kubectx";
      }
      {
        name = "bin/kubectl-ns";
        path = "${kubectx}/bin/kubens";
      }
    ])
    kubelogin
    kubelogin-oidc
    kubernetes-helm
    kustomize
    lazygit
    lua-language-server
    marksman
    mods
    neovim
    nixd
    nixfmt
    nmap
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs
    oci-cli
    perl
    pnpm
    podman-compose
    (poetry.overridePythonAttrs (prev: {
      dependencies =
        prev.dependencies
        ++ (with python3Packages; [
          keyrings-google-artifactregistry-auth
        ]);
    }))
    popeye
    pre-commit
    pwgen
    python3
    (
      let
        inherit (python3Packages) keyring;
        unpropagateKeyring =
          pkg:
          pkg.overridePythonAttrs (prev: {
            build-system = prev.build-system ++ [ keyring ];
            dependencies = lib.remove keyring prev.dependencies;
          });
        backends = map unpropagateKeyring (
          with python3Packages;
          [
            keyrings-google-artifactregistry-auth
          ]
        );
      in
      keyring.overridePythonAttrs (prev: {
        dependencies = prev.dependencies ++ backends;
        pythonImportsCheck = prev.pythonImportsCheck ++ map (pkg: pkg.pythonImportsCheck) backends;
      })
    )
    regctl
    ripgrep
    unstable.ruff
    rustup
    unstable.scaleway-cli
    shellcheck
    shfmt
    solo2-cli
    ssm-session-manager-plugin
    stern
    tanka
    tcptraceroute
    terraform-docs
    terraform-ls
    tflint
    tfswitch
    tmux
    tree
    unstable.ty
    urlscan
    unstable.uv
    wget
    yq-go
    zsh-autosuggestions
    zsh-completions
    zsh-fzf-tab
    zsh-syntax-highlighting
  ];
}
