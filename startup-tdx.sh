#!/bin/bash

WDIR=/workdir

# Check if machine is set otherwise exit
if [ -z "$MACHINE" ]
then
    echo "Please set MACHINE variable"
    exit 1
fi

# Check if default build directory is setup
if [ -z "$1" ]
then
    BDDIR=build
else
    BDDIR="$1"
fi

# Check if branch is passed as argument
if [ -z "$BRANCH" ]
then
    BRANCH=dunfell-5.x.y
fi

if [ -z "$MANIFEST" ]
then
    MANIFEST=tdxref/default.xml
fi

# Configure Git if not configured
if [ ! $(git config --global --get user.email) ]; then
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    git config --global color.ui false
fi

# Create a directory for yocto setup
mkdir -p $WDIR/yocto
cd $WDIR/yocto

# Initialize if repo not yet initialized
repo status 2> /dev/null
if [ "$?" = "1" ]
then
    repo init -u https://git.toradex.com/toradex-manifest.git -b $BRANCH -m $MANIFEST
    export http_proxy=$PROXY
    export https_proxy=$PROXY
    repo sync
fi # Do not sync automatically if repo is setup already

# Initialize build environment
if [ -z "$DISTRO"  ]
then
    MACHINE=$MACHINE source export
else
    DISTRO=$DISTRO MACHINE=$MACHINE source export
fi

# Accept Freescale/NXP EULA
if ! grep -q ACCEPT_FSL_EULA $WDIR/yocto/$BDDIR/conf/local.conf
then
    echo 'You have to accept freescale EULA. Read it carefully and then accept it.'
    echo 'Press "space" to scroll down and "q" to exit'
    sleep 3
    less $WDIR/yocto/layers/meta-freescale/EULA
    while true; do
        read -p "Do you accept the EULA? [y/n] " yn
        case $yn in
            [Yy]* ) echo 'EULA accepted'
                echo 'ACCEPT_FSL_EULA="1"' >> $WDIR/yocto/$BDDIR/conf/local.conf
                break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done    
fi

# Only start build if requested
if [ -z "$IMAGE" ]
then
    echo "Build environment configured"
else
    echo "Build environment configured. Building target image $IMAGE"
    echo "> DISTRO=$DISTRO MACHINE=$MACHINE bitbake $IMAGE"
    bitbake $IMAGE
fi

# Only start build if requested
if [ -n "$SDK" ]
then
    echo "Build a SDK"
    echo "> DISTRO=$DISTRO MACHINE=$MACHINE bitbake $IMAGE -c populate_sdk"
    bitbake $IMAGE -c populate_sdk
fi



# Spawn a shell
exec bash -i
