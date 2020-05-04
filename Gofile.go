package gofile

import (
	_ "github.com/ahmetb/kubectx/cmd/kubectx"
	_ "github.com/ahmetb/kubectx/cmd/kubens"
	_ "github.com/google/go-jsonnet/cmd/jsonnet"
	_ "github.com/google/go-jsonnet/cmd/jsonnetfmt"
	_ "github.com/grafana/tanka/cmd/tk"
	_ "github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"
	_ "golang.org/x/lint/golint"
	_ "golang.org/x/tools/cmd/goimports"
	_ "mvdan.cc/sh/v3/cmd/shfmt"
)
