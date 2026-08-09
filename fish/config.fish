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


# Added by Antigravity CLI installer
set -gx PATH "/home/mark/.local/bin" $PATH
fish_add_path $HOME/trek/bin

# opencode
fish_add_path /home/mark/.opencode/bin

# pnpm
set -gx PNPM_HOME "/home/mark/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# Wasmer
export WASMER_DIR="/home/mark/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

set -gx WASMTIME_HOME "$HOME/.wasmtime"

string match -r ".wasmtime" "$PATH" > /dev/null; or set -gx PATH "$WASMTIME_HOME/bin" $PATH
