# https://wiki.archlinux.org/title/XDG_Base_Directory
# https://github.com/b3nj5m1n/xdg-ninja

BIN_HOME="${HOME}/.local/bin"
CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

# Bin
export GOBIN="${BIN_HOME}"

# Cache
export TF_PLUGIN_CACHE_DIR="${CACHE_HOME}/terraform/plugins"

# Config
export AWS_CONFIG_FILE="${CONFIG_HOME}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${CONFIG_HOME}/aws/credentials"
export OCI_CONFIG_FILE="${CONFIG_HOME}/oci/config"

# Data
export ANSIBLE_HOME="${DATA_HOME}/ansible"
export CARGO_HOME="${DATA_HOME}/cargo"
export GOPATH="${DATA_HOME}/go"
export LESSHISTFILE="${DATA_HOME}/less/history"
export NODE_REPL_HISTORY="${DATA_HOME}/node/repl_history"
export PIPX_HOME="${DATA_HOME}/pipx"
export RUSTUP_HOME="${DATA_HOME}/rustup"
export VAGRANT_HOME="${DATA_HOME}/vagrant"
export WORKON_HOME="${DATA_HOME}/virtualenvs"

unset BIN_HOME CACHE_HOME CONFIG_HOME DATA_HOME STATE_HOME
