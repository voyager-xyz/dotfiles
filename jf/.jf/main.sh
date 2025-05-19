#/bin/bash

# https://github.com/zdharma-continuum/zinit
# list tests
# go to lambda
# go to cw logs
# run cw insights
# open links
# reset chrome

BASE_DIR="/Users/jarrod.folino/Code"
SCRIPTS_DIR="${BASE_DIR}/_dotfiles/_scripts"
OUTPUT_DIR="/Users/jarrod.folino/Code/_dotfiles/_output"
LINKS_FILE="/Users/jarrod.folino/Code/_dotfiles/_links/links.json"



up () {
    NEWDIR=$(git rev-parse --show-toplevel)
    if [ -d "$NEWDIR" ]
    then
        echo "cd to ${NEWDIR}"
        cd "$NEWDIR" || return
    else
        echo "Not a git repository (or any of the parent directories): .git"
    fi
}

ch () {
    up
    handlers_path="./handlers"
    if [[ ! -d $handlers_path ]]
    then
        echo "The 'handlers' directory does not exist."
        exit 1
    fi
    directories=($(find $handlers_path -type f -name "main.py" -exec dirname {} \; | grep -v build | sort | uniq | sed 's/\/src//'))
    if [[ ${#directories[@]} -eq 0 ]]
    then
        echo "No directories with a 'main.py' file found in 'handlers'."
        exit 1
    fi
    selected_directory=$(printf "%s\n" "${directories[@]}" | fzf --prompt="Select a handler")
    if [[ -n $selected_directory ]]
    then
        cd $selected_directory
    else
        echo "No directory selected."
        exit 1
    fi
}

cd_proj () {
    cd "${BASE_DIR}" || {
        echo "Directory not found"
        return 1
    }

    selected_dir=$(find . -maxdepth 1 -type d ! -name '.' | sed 's|^\./||' | sort | fzf --height=40% --border --layout=reverse --prompt="Select a directory: ")

    if [[ -n "$selected_dir" ]]; then
    
       test -f "$selected_dir/.venv/bin/activate" && source "$selected_dir/.venv/bin/activate"
       cd "$selected_dir" || {
            echo "Failed to change directory"
            return 1
       }
    else
        echo "No directory selected"
        return 1
    fi
    eval "${1} ."
}

process_git_repos () {
    for dir in "${1}"/*; do
        if [ -d "$dir/.git" ]; then
            echo "Processing repository: $dir"
            cd "$dir" || continue
            git stash -u
            echo "Stashed changes in $dir"
            git checkout main
            git fetch --all
            git pull --rebase
            echo "Pulled and rebased in $dir"
            cd ..
        else
            echo "Skipping non-git directory: $dir"
        fi
    done

}

get_open_prs () {
    repos=("${@}")

    aggregated_prs=()

    for repo in "${repos[@]}"; do
        prs=$(gh pr list --repo "FundingCircle/$repo" --state open --json number,title,author,url 2>/dev/null)

        if [[ $? -ne 0 ]]; then
            echo "Failed to fetch PRs for $repo. Skipping..."
            continue
        fi

        # Parse and format PRs
        formatted_prs=$(echo "$prs" | jq -r --arg repo "$repo" '.[] | "- [" + $repo + "] #" + (.number|tostring) + " " + .title + " by " + .author.login + " (" + .url + ")"')
        if [[ -n "$formatted_prs" ]]; then
            aggregated_prs+=("$formatted_prs")
        fi
    done

    # Output aggregated PRs
    if [[ ${#aggregated_prs[@]} -eq 0 ]]; then
        echo "No open PRs found for any repository."
    else
        echo "Aggregated list of open PRs:"
        printf "%s\n" "${aggregated_prs[@]}"
    fi
}

open_handler () {
    cd "${BASE_DIR}/${1}"
    test -f "${BASE_DIR}/${1}/.venv/bin/activate" && source "${BASE_DIR}/${1}/.venv/bin/activate"
    cd "${BASE_DIR}/${1}"
    ch
    nvim .
}

get_tests () {
    cd "${1}"
    git stash
    git checkout main
    git reset --hard origin/main
    eval "python ${SCRIPTS_DIR}/get_tests.py ${1}" > "${OUTPUT_DIR}/main-tests.json"
    git checkout "${2}"
    git reset --hard "origin/${2}"
    eval "python ${SCRIPTS_DIR}/get_tests.py ${1}" > "${OUTPUT_DIR}/${2}-tests.json"
}

chistory () {
    python $SCRIPTS_DIR/chistory.py visit_count domain github.com url
}

list_links() {
    if [[ ! -f "$LINKS_FILE" ]]; then
        echo "links.json file not found at $LINKS_FILE"
        return 1
    fi

    jq -r '.[] | "\(.name)\t\(.url)"' "$LINKS_FILE" | while IFS=$'\t' read -r name url; do
        echo $'\033]8;;'"$url"$'\033\\'"$name"$'\033]8;;\033\\'
    done
}

select_handler () {
    options=(
        "a: rewards"
        "s: transactions"
        "d: pricing"
        "q: Quit"
    )
    formatted_options=$(printf "%s\n" "${options[@]}" | column -t -s ':')
    choice=$(echo "$formatted_options" | fzf --height=40% --border --layout=reverse --prompt="Select an option: " --expect=a,s,d,q --bind "j:down,k:up")
    key=$(head -n 1 <<< "$choice")
case "$key" in
        a)
            open_handler flexipay-rewards-api
            ;;
        s)
            open_handler stc-transactions-api
            ;;
        d)
            open_handler flexipay-pricing-api
            ;;
        q)
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac

}

menu () {
    options=(
        "f: CHistory"

        "h: handlers"
        "j: Open terminal in project root dir"
        "k: TBD"
        "l: TBD"
        ";: TBD"
        
        "r: Refresh all Git repositories"
        "k: Fetch open PRs for repositories"
        "l: Links"
        "q: Quit"
    )

    formatted_options=$(printf "%s\n" "${options[@]}" | column -t -s ':')
    choice=$(echo "$formatted_options" | fzf --height=40% --border --layout=reverse --prompt="Select an option: " --expect=f,h,j,r,k,q,l --bind "j:down,k:up")
    key=$(head -n 1 <<< "$choice")

    case "$key" in
        r)
            process_git_repos $BASE_DIR
            ;;
        # a)
        #     open_handler flexipay-rewards-api
        #     ;;
        # s)
        #     open_handler stc-transactions-api
        #     ;;
        # d)
        #     open_handler flexipay-pricing-api
        #     ;;
        f)
            chistory
            ;;
        h)
           select_handler 
            ;;

        j)
            cd_proj nvim
            ;;
        l)
            list_links
            ;;
        k)
            get_open_prs flexipay-rewards-and-pricing-shared flexipay-rewards-api \
                         flexipay-pricing-api \
                         stc-transactions-api \
                         uk-borrower-platform-transactions \
                         python-lambda-utils
            ;;
        q)
            echo "Goodbye!"
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

clear
menu
