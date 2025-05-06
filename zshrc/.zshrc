export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

ss() {
    # Change to the target directory
    cd /Users/jarrod.folino/Code/ || { echo "Directory not found"; return 1; }

    # List all directories in the current folder
    echo "Directories in /Users/jarrod.folino/Code/"
    dirs=()
    i=1
    for dir in $(find . -maxdepth 1 -type d ! -name '.' | sort); do
        dir_name=$(basename "$dir")
        dirs+=("$dir_name")
        echo "$i) $dir_name"
        ((i++))
    done

    # Prompt the user to select a directory
    echo -n "Enter the number of the directory to change to: "
    read choice

    # Validate the input and change to the selected directory
    if [[ "$choice" -ge 1 && "$choice" -le "${#dirs[@]}" ]]; then
        selected_dir="${dirs[$((choice))]}"
        cd "/Users/jarrod.folino/Code/$selected_dir" || { echo "Failed to change directory"; return 1; }
        echo "Changed to directory: $selected_dir"
    else
        echo "Invalid choice"
        return 1
    fi
}

up() {
  NEWDIR=$(git rev-parse --show-toplevel)
  if [ -d "$NEWDIR" ]; then
    echo "cd to ${NEWDIR}"
    cd "$NEWDIR" || return
  else
    echo "Not a git repository (or any of the parent directories): .git"
  fi
}

ch() {
  up
  handlers_path="./handlers"
  
  # Check if the handlers directory exists
  if [[ ! -d $handlers_path ]]; then
    echo "The 'handlers' directory does not exist."
    exit 1
  fi
  
  # Find all directories containing a main.py file
  directories=($(find $handlers_path -type f -name "main.py" -exec dirname {} \; | sort | uniq))
  
  # Check if there are any directories with main.py
  if [[ ${#directories[@]} -eq 0 ]]; then
    echo "No directories with a 'main.py' file found in 'handlers'."
    exit 1
  fi
  
  # Use fzf to let the user select a directory
  selected_directory=$(printf "%s\n" "${directories[@]}" | fzf --prompt="Select a directory: ")
  
  # Check if a directory was selected
  if [[ -n $selected_directory ]]; then
    cd $selected_directory
    cd ..
    echo
    echo "To cd into the directory, run:"
    echo "cd $selected_directory"
  else
    echo "No directory selected."
    exit 1
  fi

}

export EDITOR='nvim'
export ARTIFACTORY_PASSWORD="cmVmdGtuOjAxOjE3NzYxNTcxMjE6NzEycW5BTzFjaDI0V1RXRHNJZ3d5blFtWk5X"
export ARTIFACTORY_USER="jarrod.folino@fundingcircle.com"

# alias refresh="python /Users/jarrod.folino/Code/cuiwork/scripts/src/get_lambdas.py > /Users/jarrod.folino/Code/public/data.json"
alias lg="lazygit"
alias m="make"
alias esb="cd /Users/jarrod.folino/Code/_sandbox"
alias esz="nvim  ~/.zshrc && . ~/.zshrc"
alias ee="exit"
alias ocds='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev_test" --disable-web-security'
alias me="/Users/jarrod.folino/Code/_cuiwork/me"
alias g="git status"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.atuin/bin/env"
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
