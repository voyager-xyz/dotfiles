/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
xcode-select --install
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install --cask font-jetbrains-mono-nerd-font font-caskaydia-cove-nerd-font font-iosevka-term-nerd-font font-fira-mono-nerd-font
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

brew install --cask $(brew search font-.*-nerd-font | awk '{ print $1 }')\n
brew install --cask cardinal-search
apps=(stow pyenv go zoxide rbenv fzf carapace xz neovim gh openssl@3 starship bat lazygit yazi stow tmux carapace pyenv fontconfig libpng rbenv fzf neovim ripgrep zoxide)
for app in "${apps[@]}"; do
    echo "Installing $app."
done

pyenv install 3.13.11
RUBY_CONFIGURE_OPTS=--with-openssl-dir=/opt/homebrew/Cellar/openssl@3/3.6.0 rbenv install
