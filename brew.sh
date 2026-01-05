apps=(gh openssl@3 starship bat lazygit stow tmux carapace pyenv fontconfig libpng rbenv fzf neovim ripgrep zoxide)
for app in "${apps[@]}"; do
    echo "Installing $app."
done
