#!/usr/bin/env nix-shell
#!nix-shell -i bash ../shell.nix

set -eux

git-crypt unlock

git-crypt status

fetchrepo() {
    dest=$1
    src=$2
    branch=$3
    remote=$(echo "$src" | md5sum | cut -d' ' -f1)

    if [ ! -d "$dest" ]; then
        git clone "$src" "$dest"
    fi

    (
        cd "$dest"
        if ! git remote | grep -q "$remote"; then
            git remote add "$remote" "$src"
        fi

        git fetch "$remote"
        git clean -dfx
        git checkout "$remote/$branch"
    )
}

mkdir -p repos
fetchrepo repos/ofborg https://github.com/nixos/ofborg.git released
fetchrepo repos/log-viewer https://github.com/samueldr/ofborg-viewer.git master

nixops deploy --dry-activate
