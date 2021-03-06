#! /bin/bash

ulimit -n 4096
ulimit -c unlimited

source $HOME/.bash_profile
export GOTRACEBACK=crash

function initWallet () {
    RANDOM_PASSWD=$(head -c 1024 /dev/urandom | shasum -a 512 -b | xxd -r -p | base64 | head -c 32)
    ./nknc wallet -c <<EOF
${RANDOM_PASSWD}
${RANDOM_PASSWD}
EOF
    echo ${RANDOM_PASSWD} > ./wallet.pswd
    chmod 0400 wallet.dat wallet.pswd
    return $?
}

function start () {
    WALLET_PASSWD=$(cat ./wallet.pswd)
    ./nknd --no-nat <<EOF
${WALLET_PASSWD}
${WALLET_PASSWD}
EOF
}

git fetch
LATEST_TAG=$(git tag --sort=-creatordate | head -1)
git checkout ${LATEST_TAG}
make

mkdir -p ./Log
[ -e "wallet.dat" ] || initWallet || ! echo "Init Wallet fail" || exit 1
start 1>./Log/nohup.out.$(date +%F_%T) 2>&1
