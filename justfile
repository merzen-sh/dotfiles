DOTFILES_DIR := `pwd`

tmux:
    rm -f ~/.tmux.conf
    ln -sfn {{DOTFILES_DIR}}/.tmux.conf ~/.tmux.conf

tools:
    curl -s https://ohmyposh.dev/install.sh | bash -s
    sudo pacman -S lazygit github-cli neovim vim keyd yay paru flatpak

keyd:
    sudo mkdir -p /etc/keyd
    sudo rm -f /etc/keyd/default.conf
    sudo ln -sfn {{DOTFILES_DIR}}/etc/keyd/default.conf /etc/keyd/default.conf

fish:
    rm -rf ~/.config/fish
    ln -sfn {{DOTFILES_DIR}}/fish ~/.config/fish

nvim:
    rm -rf ~/.config/nvim
    ln -sfn {{DOTFILES_DIR}}/nvim ~/.config/nvim

hypr:
    rm -rf ~/.config/hypr
    ln -sfn {{DOTFILES_DIR}}/hypr ~/.config/hypr

kitty:
    rm -rf ~/.config/kitty
    ln -sfn {{DOTFILES_DIR}}/kitty ~/.config/kitty

lazygit:
    rm -rf ~/.config/lazygit
    ln -sfn {{DOTFILES_DIR}}/lazygit ~/.config/lazygit

opencode:
    rm -rf ~/.config/opencode
    ln -sfn {{DOTFILES_DIR}}/opencode ~/.config/opencode

mark:
    rm -rf ~/.mark
    ln -sfn {{DOTFILES_DIR}}/.mark ~/.mark

niri:
    rm -rf ~/.config/niri
    ln -sfn {{DOTFILES_DIR}}/niri ~/.config/niri

link: tmux fish nvim hypr kitty lazygit mark keyd opencode niri

install: link
