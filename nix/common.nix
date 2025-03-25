{ pkgs }:

{
  packages = with pkgs; [
    amazon-ecr-credential-helper
    android-tools
    argocd
    aws-vault
    awscli2
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
    unstable.go_1_24
    go-jsonnet
    unstable.golangci-lint
    golangci-lint-langserver
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    (unstable.gopls.override {
      buildGoModule = unstable.buildGo124Module;
    })
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
    unstable.kubelogin-oidc
    kubernetes-helm
    kustomize
    lazygit
    (llm-ls.overrideAttrs (prev: rec {
      # https://github.com/huggingface/llm-ls/pull/104
      src = fetchFromGitHub {
        owner = "huggingface";
        repo = "llm-ls";
        rev = "fc5f4d249d78108aeed33b1cc464c4e9bcccd82c";
        sha256 = "sha256-0xlJOip68gQ9TKJmu8DdVsgk5qetQPb/YbV3HTlf0b8=";
      };
      patches = [ (builtins.elemAt prev.patches 0) ];
      cargoDeps = prev.cargoDeps.overrideAttrs (
        lib.const {
          name = "${prev.pname}-${prev.version}-vendor.tar.gz";
          inherit src patches;
          outputHash = "sha256-m/w9aJZCCh1rgnHlkGQD/pUDoWn2/WRVt5X4pFx9nC4=";
        }
      );
    }))
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
            buildInputs = prev.buildInputs ++ [ keyring ];
            propagatedBuildInputs = lib.remove keyring prev.propagatedBuildInputs;
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
