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
    (d2.overrideAttrs {
      patches = [
        (fetchpatch2 {
          # https://github.com/terrastruct/d2/pull/2659
          name = "0001-imgbundler-fetch-images-more-reliably-add-headers.patch";
          url = "https://github.com/terrastruct/d2/commit/58c2d17a255606e6abe297b481acf9382387820f.patch?full_index=1";
          hash = "sha256-mAK1VqLhBZP5//tbvlrARFhOrEVDNC4b4iubCOcYO+0=";
        })
      ];
    })
    delta
    (unstable.delve.override {
      buildGoModule = buildGo126Module;
    })
    docker-credential-helpers
    docker-language-server
    dos2unix
    unstable.egctl
    fd
    fzf
    gdu
    git-lfs
    gh
    unstable.go_1_26
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
    unstable.neovim
    nixd
    nixfmt
    nmap
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs
    oci-cli
    unstable.opencode
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
    unstable.prek
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
    (unstable.scaleway-cli.overrideAttrs {
      patches = [
        # https://github.com/NixOS/nixpkgs/pull/521971
        (fetchpatch2 {
          name = "update-expected-time-in-marshaler-test.patch";
          url = "https://github.com/scaleway/scaleway-cli/commit/21f7a93e6e924600ac7bc3c7cfba69171fd05f60.patch?full_index=1";
          hash = "sha256-lZbqqC/A2sIOGZKqC8pANqKW+da4PJxawlkHEZi5EsM=";
        })
      ];
    })
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
    tree
    tree-sitter
    unstable.ty
    unstable.uv
    wget
    yq-go
    unstable.zellij
    zsh-autosuggestions
    zsh-completions
    zsh-fzf-tab
    zsh-syntax-highlighting
  ];
}
