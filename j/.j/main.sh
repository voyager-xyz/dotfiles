#/bin/bash

# test coverage
# list tests
# go to lambda
# go to cw logs
# run cw insights
# open links
# reset chrome

BASE_DIR="/Users/jarrodfolino/Code"
SCRIPTS_DIR="${BASE_DIR}/dotfiles/_scripts"
OUTPUT_DIR="${BASE_DIR}/dotfiles/_output"
LINKS_FILE="${BASE_DIR}/dotfiles/_links/links.json"



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

clear
menu
