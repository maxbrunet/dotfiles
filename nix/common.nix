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
    delve
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
    go
    go-jsonnet
    golangci-lint
    golangci-lint-langserver
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    gopls
    goreleaser
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
    nixfmt-rfc-style
    nmap
    nodePackages.prettier
    nodePackages.ts-node
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodejs
    oci-cli
    (pdm.overridePythonAttrs (prev: {
      dependencies =
        prev.dependencies
        ++ (with python3Packages; [
          keyrings-google-artifactregistry-auth
        ]);
    }))
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
    (
      let
        inherit (python3Packages) python-lsp-server;
        unpropagatePylsp =
          pkg:
          pkg.overridePythonAttrs (prev: {
            build-system = (prev.build-system or [ ]) ++ [ python-lsp-server ];
            dependencies = lib.remove python-lsp-server prev.dependencies;
          });
        plugins = map unpropagatePylsp (
          with python3Packages;
          [
            pylsp-mypy
          ]
        );
      in
      python-lsp-server.overridePythonAttrs (prev: {
        dependencies = prev.dependencies ++ plugins;
        disabledTests = prev.disabledTests ++ [
          "test_autoimport_code_actions_and_completions_for_notebook_document"
          "test_notebook_document__did_open"
          "test_notebook_document__did_change"
        ];
        pythonImportsCheck = prev.pythonImportsCheck ++ map (pkg: pkg.pythonImportsCheck) plugins;
      })
    )
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
    terraform-docs
    terraform-ls
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
    zsh-completions
    zsh-fzf-tab
    zsh-syntax-highlighting
  ];
}
