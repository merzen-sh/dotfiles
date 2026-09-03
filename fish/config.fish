# ==== sources ==== #

source (dirname (status filename))/functions/alias_cmd.fish
source (dirname (status filename))/functions/zoxide.fish

set -U fish_greeting ""
# ==== env variables ==== #

set -gx FZF_DEFAULT_OPTS_FILE "$HOME/.config/fzf/fzfrc"

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'

set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

set -gx RUSTC_WRAPPER sccache

# ==== greeting ==== #

if status is-interactive
    # fastfetch
    # echo "merzen-sh@arch"
end

export QT_QPA_PLATFORMTHEME=qt6ct

# ==== env paths ==== #

# bun
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cache/.bun/bin

set --export PATH $BUN_INSTALL/bin $PATH

# starship
starship init fish | source
export PATH="$HOME/.local/bin:$PATH"
mise activate fish | source
