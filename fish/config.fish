# ==== sources ==== #

source (dirname (status filename))/functions/alias_cmd.fish
source (dirname (status filename))/functions/zoxide.fish

# ==== env variables ==== #

set -gx FZF_DEFAULT_OPTS_FILE "~/.config/fzf/fzfrc"

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'

set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

set -gx RUSTC_WRAPPER sccache

# ==== greeting ==== #

if status is-interactive
    # fastfetch
    echo "merzen-sh@arch"
end

# ==== env paths ==== #

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# starship
starship init fish | source

# Cargo
set -gx PATH "~/.cargo/bin" $PATH

# Added by Antigravity CLI installer
set -gx PATH "~/.local/bin" $PATH

# opencode
set -gx PATH ~/.opencode/bin $PATH
