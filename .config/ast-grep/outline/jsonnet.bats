#!/usr/bin/env nix
#! nix --extra-experimental-features ``nix-command flakes``
#! nix develop --ignore-env --impure --expr ``
#! nix let
#! nix   flake = builtins.getFlake (toString ../../..);
#! nix   pkgs = flake.inputs.nixos.legacyPackages.${builtins.currentSystem};
#! nix   unstable = flake.inputs."nixos-unstable".legacyPackages.${builtins.currentSystem};
#! nix   grammar = pkgs.tree-sitter-grammars.tree-sitter-jsonnet;
#! nix   sgconfig = (pkgs.formats.yaml { }).generate "sgconfig.yml" {
#! nix     customLanguages.jsonnet = {
#! nix       libraryPath = "${grammar}/parser";
#! nix       extensions = [
#! nix         "jsonnet"
#! nix         "libsonnet"
#! nix       ];
#! nix       expandoChar = "_";
#! nix       outlineRules = "${toString ../../..}/.config/ast-grep/outline/jsonnet.yml";
#! nix     };
#! nix   };
#! nix in
#! nix pkgs.mkShell {
#! nix   env = {
#! nix     SGCONFIG = "${sgconfig}";
#! nix   };
#! nix   packages = with pkgs; [
#! nix     unstable.ast-grep
#! nix     bats
#! nix     diffutils
#! nix     jq
#! nix     parallel
#! nix   ];
#! nix }
#! nix ``
#! nix --keep-env-var HOME
#! nix --keep-env-var TERM
#! nix --command bats
# shellcheck shell=bash

outline() {
  ast-grep --config="${SGCONFIG}" outline --lang=jsonnet --stdin --json=stream "${@}"
}

# $1 actual outline JSON; expected JSON on stdin.
# diff's exit code is the assertion: 0 = match, 1 = mismatch (prints the diff).
assert_items() {
  local actual
  actual=$(jq --sort-keys '
      [
        .items[] |
        {
          name,
          symbolType,
          isExported,
          isImport,
          members: [
            .members[]? |
            { name, symbolType, isPublic }
          ]
        }
      ]
    ' <<<"${1?actual required}")
  local expected
  expected="$(jq --sort-keys)"

  diff -U 100 --label expected --label actual \
    <(printf '%s' "${expected}") \
    <(printf '%s' "${actual}") >&2
}

@test "file-scope locals: variable, named and anonymous functions" {
  local items
  items="$(
    outline <<'EOF'
local v = 1;
local f(x) = x;
local fa = function(y) y;
{ a: 1 }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "v", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "f", "symbolType": "function", "isExported": false, "isImport": false, "members": [] },
  { "name": "fa", "symbolType": "function", "isExported": false, "isImport": false, "members": [] },
  { "name": "a", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "nested locals in expression contexts do not leak" {
  local items
  items="$(
    outline <<'EOF'
local h = (local inner = 3; inner);
local c = [local w = 2; w];
foo(local y = 1; y);
1 + local z = 2; z;
{ a: 1 }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "h", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "c", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "a", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "object field visibility: colon, hidden, forced-visible, quoted, computed" {
  local items
  items="$(
    outline <<'EOF'
{
  plain: 1,
  hidden:: 2,
  forced::: 3,
  "s:: key": 4,
  [k]:: 5,
  d: "has:: inside",
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "hidden", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "forced", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "\"s:: key\"", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "[k]", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "d", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "methods: public and hidden, with field-vs-method member classification" {
  local items
  items="$(
    outline <<'EOF'
{
  m(x): x,
  g(a):: a,
  nested: {
    f: 1,
    q(y): y,
  },
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "m", "symbolType": "method", "isExported": true, "isImport": false, "members": [] },
  { "name": "g", "symbolType": "method", "isExported": false, "isImport": false, "members": [] },
  {
    "name": "nested",
    "symbolType": "field",
    "isExported": true,
    "isImport": false,
    "members": [
      { "name": "f", "symbolType": "field", "isPublic": true },
      { "name": "q", "symbolType": "method", "isPublic": true }
    ]
  }
]
EOF
}

@test "object locals: not exported, functions detected in both forms" {
  local items
  items="$(
    outline <<'EOF'
{
  pub: 1,
  local oL = 2,
  local oF(x) = x,
  local oA = function(y) y,
  n: {
    q: 3,
    local nL = 4,
    local nF = function(z) z,
  },
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "pub", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "oL", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "oF", "symbolType": "function", "isExported": false, "isImport": false, "members": [] },
  { "name": "oA", "symbolType": "function", "isExported": false, "isImport": false, "members": [] },
  {
    "name": "n",
    "symbolType": "field",
    "isExported": true,
    "isImport": false,
    "members": [
      { "name": "q", "symbolType": "field", "isPublic": true },
      { "name": "nL", "symbolType": "variable", "isPublic": false },
      { "name": "nF", "symbolType": "function", "isPublic": false }
    ]
  }
]
EOF
}

@test "imports: both quote styles, import and importstr" {
  local items
  items="$(
    outline --items imports <<'EOF'
local a = import 'a.libsonnet';
local b = import "b.libsonnet";
local c = importstr 'c.txt';
local d = importstr "d.txt";
{ x: 1 }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "a.libsonnet", "symbolType": "module", "isExported": false, "isImport": true, "members": [] },
  { "name": "b.libsonnet", "symbolType": "module", "isExported": false, "isImport": true, "members": [] },
  { "name": "c.txt", "symbolType": "module", "isExported": false, "isImport": true, "members": [] },
  { "name": "d.txt", "symbolType": "module", "isExported": false, "isImport": true, "members": [] }
]
EOF
}

@test "hidden fields excluded from exports, kept in structure" {
  local items
  items="$(
    outline --items exports <<'EOF'
{
  visible: 1,
  hidden:: 2,
  forced::: 3,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "visible", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "forced", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "quoted and computed hidden keys" {
  local items
  items="$(
    outline <<'EOF'
{
  "quotedHidden":: 1,
  "quotedVisible:: inside": 2,
  ["c"]:: 3,
  ['d']:: 4,
  ["a" + "b"]:: 5,
  [k]:: 6,
  plain: 7,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "\"quotedHidden\"", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "\"quotedVisible:: inside\"", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "[\"c\"]", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "['d']", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "[\"a\" + \"b\"]", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "[k]", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "merge (+) field visibility" {
  local items
  items="$(
    outline <<'EOF'
{
  a+: 1,
  b+:: 2,
  c+::: 3,
  plain: 4,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "a", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "b", "symbolType": "field", "isExported": false, "isImport": false, "members": [] },
  { "name": "c", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "nested locals in unary, error and super contexts do not leak" {
  local items
  items="$(
    outline <<'EOF'
{
  u: !(local w = 1; w),
  e: error (local e = 1; e),
  s: super[local s = 1; s],
  plain: 1,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "u", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "e", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "s", "symbolType": "field", "isExported": true, "isImport": false, "members": [] },
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "nested local in assert and object-value contexts do not leak" {
  local items
  items="$(
    outline <<'EOF'
assert (local a = 1; a) > 0;
local o = { x: (local y = 1; y) };
{ plain: 1 }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  {
    "name": "o",
    "symbolType": "variable",
    "isExported": false,
    "isImport": false,
    "members": [
      { "name": "x", "symbolType": "field", "isPublic": true }
    ]
  },
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "multi-bind locals" {
  local items
  items="$(
    outline <<'EOF'
local a = 1, b = 2;
{ z: a + b }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "a", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "b", "symbolType": "variable", "isExported": false, "isImport": false, "members": [] },
  { "name": "z", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "deep nesting keeps one member level" {
  local items
  items="$(
    outline <<'EOF'
{
  a: {
    b: {
      c: 1,
    },
  },
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  {
    "name": "a",
    "symbolType": "field",
    "isExported": true,
    "isImport": false,
    "members": [
      { "name": "b", "symbolType": "field", "isPublic": true }
    ]
  }
]
EOF
}

@test "verbatim import" {
  local items
  items="$(
    outline --items imports <<'EOF'
local v = import @'foo.libsonnet';
{ z: 1 }
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "foo.libsonnet", "symbolType": "module", "isExported": false, "isImport": true, "members": [] }
]
EOF
}

@test "object comprehension template field" {
  local items
  items="$(
    outline <<'EOF'
{
  comp: { [k]: k for k in ['a', 'b'] },
  plain: 1,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  {
    "name": "comp",
    "symbolType": "field",
    "isExported": true,
    "isImport": false,
    "members": [
      { "name": "[k]", "symbolType": "field", "isPublic": true }
    ]
  },
  { "name": "plain", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "exports view excludes file-scope and object locals" {
  local items
  items="$(
    outline --items exports <<'EOF'
local helper = 1;
local f(x) = x;
{
  pub: 1,
  hidden:: 2,
  local oL = 3,
  local oF(y) = y,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  { "name": "pub", "symbolType": "field", "isExported": true, "isImport": false, "members": [] }
]
EOF
}

@test "pub-members hides nested hidden fields" {
  local items
  items="$(
    outline --pub-members <<'EOF'
{
  n: {
    visible: 1,
    hidden:: 2,
    forced::: 3,
    vm(x): x,
    hm(x):: x,
    fm(x)::: x,
  },
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[
  {
    "name": "n",
    "symbolType": "field",
    "isExported": true,
    "isImport": false,
    "members": [
      { "name": "visible", "symbolType": "field", "isPublic": true },
      { "name": "forced", "symbolType": "field", "isPublic": true },
      { "name": "vm", "symbolType": "method", "isPublic": true },
      { "name": "fm", "symbolType": "method", "isPublic": true }
    ]
  }
]
EOF
}

@test "exports view is empty when only hidden fields" {
  local items
  items="$(
    outline --items exports <<'EOF'
{
  hidden:: 2,
}
EOF
  )"
  assert_items "${items}" <<'EOF'
[]
EOF
}
