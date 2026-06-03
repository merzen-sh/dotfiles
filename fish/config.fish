source (dirname (status filename))/functions/alias.fish
source (dirname (status filename))/functions/zoxide.fish

set -U fish_greeting ""

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

#oh my posh
oh-my-posh init fish --config $HOME/dotfiles/mark.omp.json | source

set -U fish_user_paths ~/.cargo/bin $fish_user_paths

fastfetch

set -g fish_ambiguous_width 1
set -g fish_emoji_width 2
