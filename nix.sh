#!/usr/bin/env bash
set -e

if ! command -v nix > /dev/null; then
    . ~/.nix-profile/etc/profile.d/nix.sh || true
fi

if ! command -v nix > /dev/null; then
    echo No nix found. Installing...
    mkdir -p -m 0755 /nix
    groupadd nixbld -g 30000 || true
    for i in {1..10}; do
        useradd -c "Nix build user $i" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" "nixbld$i" || true
    done
    sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install) --no-daemon --no-channel-add
    echo ". ~/.nix-profile/etc/profile.d/nix.sh" >>~/.bashrc
    if [[ -f ~/.zshrc ]]; then
        echo ". ~/.nix-profile/etc/profile.d/nix.sh" >>~/.zshrc
    fi
    . ~/.nix-profile/etc/profile.d/nix.sh
    mkdir -p /etc/nix
fi

echo "substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://nix-bin.hydro.ac/ https://nix-bin.hydro.ac/ https://nix.hydro.ac/cache" >/etc/nix/nix.conf
echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydro.ac:EytfvyReWHFwhY9MCGimCIn46KQNfmv9y8E2NqlNfxQ=" >>/etc/nix/nix.conf
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
nix-channel --add https://nix.hydro.ac/ hydro
echo "Now unpacking channel. might take a long time."
nix-channel --update
