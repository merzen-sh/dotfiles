# ==== sources ==== #

set -l dotfiles "$HOME/dotfiles"

source "$dotfiles/fish/functions/alias_cmd.fish"
source "$dotfiles/fish/functions/zoxide.fish"
source "$dotfiles/fzf/themes/noctalia.fish"

set -U fish_greeting ""
# ==== env variables ==== #

set -gx RUSTC_WRAPPER kache

# ==== greeting ==== #

if status is-interactive
    # fastfetch
end

export QT_QPA_PLATFORMTHEME=qt6ct

# ==== env paths ==== #

# bun
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cache/.bun/bin
fish_add_path $HOME/.opencode/bin

# starship
starship init fish | source
export PATH="$HOME/.local/bin:$PATH"
mise activate fish | source
