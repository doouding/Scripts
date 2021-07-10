#!/bin/zsh

print_current() {
    local node_path=`readlink $(which node)`

    if [ -z "$node_path" ]
    then
        echo "Node is currently not active"
    else
        local node_version=`echo "$node_path" | egrep -o 'node@[[:digit:]]{2}'`
        echo "Current node version is $node_version"
    fi
}

print_installed() {
    echo `ls /usr/local/Cellar | egrep -o '[[:<:]]node@[[:digit:]]{2}[[:>:]]'`
}

print_remote() {
    echo `brew search node | egrep -o '[[:<:]]node@[[:digit:]]{2}[[:>:]]( ✔)?'` 2> /dev/null
}

use_version() {
    if [[ "$1" =~ ^node@[0-9]{2}$ ]]
    then
        version="$1"
    elif [[ "$1" =~ ^[0-9]{1}$ ]]
    then
        version="node@${1}"
    else
        echo "Unrecognized current version, the correct ones are like:

bnvm use node@12
bnvm use 12"
        return
    fi

    local node_path=`brew info $version | egrep -o '/usr/local/Cellar/node@[[:digit:]]{1,}/[[:digit:]]{1,}\.[[:digit:]]{1,}\.[[:digit:]]{1,}'` 2> /dev/null

    if [ -z "$node_path" ]
    then
        echo "$version is not installed!"
    else
        rm /usr/local/bin/node > /dev/null
        rm /usr/local/bin/npm > /dev/null
        rm /usr/local/bin/npx > /dev/null

        ln -s "$node_path/bin/node" /usr/local/bin/node
        ln -s "$node_path/bin/npm" /usr/local/bin/npm
        ln -s "$node_path/bin/npx" /usr/local/bin/npx

        echo "Current active node version has switch to node@$1"
    fi
}

print_help () {
    echo "bnvm is used to switch between different version of nodes that installed by brew

Usage:
    bnvm current         Show currently active node version
    bnvm ls              Show currently installed node version
    bnvm remote          Show available node version
    bnvm use <version>   Switch current version, e.g. bnvm use 12, bnvm use node@12
    bnvm [help]          Show this help text"
}

main() {
    if [ "$1" = "current" ]
    then
        print_current
    elif [ "$1" = "ls" ]
    then
        print_installed
    elif [ "$1" = "use" ]
    then
        use_version $2
    elif [ "$1" = "remote" ]
    then
        print_remote
    else
        print_help
    fi
}

main $1 $2
