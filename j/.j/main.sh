#/bin/bash

# test coverage
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

# gh api "orgs/FundingCircle/members" --paginate --jq '.[].login'
# gh api graphql -f query='query { user(login: "AdamM-FC") { contributionsCollection { contributionCalendar { totalContributions } } } }' --jq '.data.user.contributionsCollection.contributionCalendar.totalContributions'


open_handler () {
    cd "${BASE_DIR}/${1}"
    test -f "${BASE_DIR}/${1}/.venv/bin/activate" && source "${BASE_DIR}/${1}/.venv/bin/activate"
    cd "${BASE_DIR}/${1}"
    ch
    code .
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
    DIRS=$(python $SCRIPTS_DIR/chistory.py visit_count domain github.com url)
    selected_directory=$(python $SCRIPTS_DIR/chistory.py visit_count domain github.com url | fzf --prompt="Select URL")
    open $selected_directory
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
        "k: "
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

        f)
            chistory
            ;;
        h)
           select_handler 
            ;;

        j)
            cd_proj nvim
            ;;
        # k)
        #     ss 
        #     ;;
        l)
            list_links
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
