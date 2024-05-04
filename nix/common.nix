{ pkgs }:

let
  pnpm-completion =
    let inherit (pkgs.nodePackages) pnpm; in
    pkgs.runCommand "pnpm-completion-${pnpm.version}"
      {
        nativeBuildInputs = [ pkgs.installShellFiles pnpm ];
      }
      ''
        # https://github.com/pnpm/pnpm/issues/3083
        export HOME="$PWD"
        pnpm install-completion bash
        pnpm install-completion fish
        pnpm install-completion zsh
        sed -i '1 i#compdef pnpm' .config/tabtab/zsh/pnpm.zsh
        installShellCompletion \
          .config/tabtab/bash/pnpm.bash \
          .config/tabtab/zsh/pnpm.zsh \
          .config/tabtab/fish/pnpm.fish
      '';
in
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
      buildGoModule = unstable.buildGo122Module;
    })
    unstable.devpod
    direnv
    docker-credential-helpers
    dos2unix
    fd
    fpp
    fzf
    gdu
    git-lfs
    gh
    unstable.go_1_22
    go-jsonnet
    gofumpt
    (unstable.golangci-lint.override {
      buildGoModule = unstable.buildGo122Module;
    })
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    (unstable.gopls.override {
      buildGoModule = unstable.buildGo122Module;
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
    unstable.kubecolor
    kubectl-explore
    kubectx
    (linkFarm "kubectl-ctx" [
      { name = "bin/kubectl-ctx"; path = "${kubectx}/bin/kubectx"; }
      { name = "bin/kubectl-ns"; path = "${kubectx}/bin/kubens"; }
    ])
    kustomize
    lazygit
    lua-language-server
    neovim
    nixd
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
    unstable.oci-cli
    (unstable.pdm.overrideAttrs (_: previousAttrs: {
      propagatedBuildInputs =
        previousAttrs.propagatedBuildInputs ++
        (with pkgs.unstable.python3Packages; [
          keyrings-google-artifactregistry-auth
        ]);

      # Fails: No module named 'first' ¯\_(ツ)_/¯
      disabledTests = previousAttrs.disabledTests ++ [
        "test_build_with_no_isolation"
      ];
    }))
    perl
    pnpm-completion
    podman-compose
    poetry
    unstable.popeye
    pre-commit
    pwgen
    python3
    python3Packages.pipx
    python3Packages.python-lsp-server
    unstable.regctl
    ripgrep
    unstable.mise
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
