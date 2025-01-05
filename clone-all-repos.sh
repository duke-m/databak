# will clone all repos from a github org
# probably not 100% POSIX compliant

# pre-requisites:
# install gh cli
# and run gh auth login

# mario duhanic

gh=gh
org=$1
target_dir=$2
max_repos=500 # max repos to clone
dry_run=0

# check if the gh cli is installed by calling it and checking the exit code
$gh --version >/dev/null
if [ $? -ne 0 ]; then
    echo "$gh cli is not installed"
    exit 1
fi

# check if the gh cli is authenticated
$gh auth status >/dev/null
if [ $? -ne 0 ]; then
    echo "gh cli is not authenticated"
    exit 1
fi

# check if both org and target directory is provided:
if [ -z "$org" ] || [ -z "$target_dir" ]; then
    echo "Usage: $0 <org> <target_dir> [--dry-run]"
    echo "--dry-run will only print the repositories that would be cloned"
    exit 1
fi

# set target directory to have current timestamp:
target_dir="$target_dir/github-$(date +%Y-%m-%d-%H-%M-%S)"
mkdir -p $target_dir

# 4000 is the hard upper limit
total=$(gh repo list $org --limit 4000 | wc -l)
i=0

# is total bigger than max_repos? if so, set total to max_repos
if [ $total -gt $max_repos ]; then
    echo "WARNING: More repositories found than max_repos, only cloning $max_repos!"
    sleep 3
fi

# dry-run mode?
if [ "$3" == "--dry-run" ]; then
    dry_run=1
    echo "Dry-run mode enabled, will not clone repositories"
fi

# start timer
start=$(date +%s)

$gh repo list $org --limit $max_repos | while read -r repo _; do
    ((i++))
    # no dry-run mode?
    if [ $dry_run -eq 0 ]; then
        $gh repo clone "$repo" "$target_dir/$repo" -- -q
    fi
    percent=$(((i * 100) / total))
    bar_percent=$((percent / 4))
    # erases current line (needs VT100 terminal) and prints the progress bar, drops $org from $repo:
    printf "\33[2K\r\r[%-25s] %d%% %s %d/%d" "$(printf '#%.0s' $(seq 1 $bar_percent))" "$percent" "${repo##*/}" $i $total
done
echo ""

# end timer
end=$(date +%s)

# calculate time taken
echo "Finished. Elapsed time: $((end - start)) s"
