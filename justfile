DOTFILES_DIR := `pwd`

_default:
    @just link

tmux:
    rm -f ~/.tmux.conf
    ln -sfn {{DOTFILES_DIR}}/.tmux.conf ~/.tmux.conf

tools:
    sudo pacman -S starship lazygit github-cli neovim keyd paru flatpak btop docker docker-compose zoxide noctalia-shell noctalia

keyd:
    sudo pacman -S keyd
    sudo ln -sfn {{DOTFILES_DIR}}/etc/keyd/default.conf /etc/keyd/default.conf

fish:
    rm -rf ~/.config/fish
    ln -sfn {{DOTFILES_DIR}}/fish ~/.config/fish

fastfetch:
    rm -rf ~/.config/fastfetch
    ln -sfn {{DOTFILES_DIR}}/fastfetch ~/.config/fastfetch

nvim:
    rm -rf ~/.config/nvim
    ln -sfn {{DOTFILES_DIR}}/nvim ~/.config/nvim

vim:
    rm -f ~/.vimrc
    ln -sfn {{DOTFILES_DIR}}/.vimrc ~/.vimrc

lazygit:
    rm -rf ~/.config/lazygit
    ln -sfn {{DOTFILES_DIR}}/lazygit ~/.config/lazygit

niri:
    rm -rf ~/.config/niri
    ln -sfn {{DOTFILES_DIR}}/niri ~/.config/niri

ghostty:
    rm -rf ~/.config/ghostty
    ln -sfn {{DOTFILES_DIR}}/ghostty ~/.config/ghostty

noctalia:
    rm -rf ~/.local/state/noctalia/
    ln -sfn {{DOTFILES_DIR}}/noctalia ~/.local/state/noctalia/

hypr:
    rm -rf ~/.config/hypr
    ln -sfn {{DOTFILES_DIR}}/hypr ~/.config/hypr

starship:
    rm -f ~/.config/starship.toml
    ln -sfn {{DOTFILES_DIR}}/starship.toml ~/.config/starship.toml

link: tmux fish nvim vim lazygit keyd niri fastfetch noctalia starship

install: link
