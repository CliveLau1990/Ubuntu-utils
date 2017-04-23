#!/bin/bash
##
# Name: android_download.sh
#
# Purpose: Download Android source code.
#
# Copyright (C) 2017 Shenzhen Auto-Link World CO.,Ltd.
# Subject to the GNU Public License, version 2.
#
# Created By:      Clive Liu <liuxusheng@auto-link.com.cn>
# Created Date:    2017-04-23
#
# ChangeList:
# Created in 2017-04-23 by Clive Liu;
##

ANDROID_BRANCH=$1

function info()
{
    echo -e "\033[33m$1\033[0m"
}

function error()
{
    echo -e "\033[31m$1\033[0m"
    exit 255
}

#function main()
#{

[ ${ANDROID_BRANCH}x == x ] && ANDROID_BRANCH=android-7.1.1_r13

mkdir -p ~/origin-$ANDROID_BRANCH
cd ~/origin-$ANDROID_BRANCH

#curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
curl https://storage-googleapis.proxy.ustclug.org/git-repo-downloads/repo > repo
[ $? -ne 0 ] && error "Abort! Can not download the repo script"
chmod a+x ~/origin-$ANDROID_BRANCH/repo

#./repo init -u https://android.googlesource.com/platform/manifest -b $ANDROID_BRANCH
./repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b $ANDROID_BRANCH
[ $? -ne 0 ] && error "Abort! Fail to repo init command"

info "repo sync ......"
./repo sync
while [ $? -ne 0 ]
do
    info "repo sync again!"
    ./repo sync
done

echo "Thanks for your help.(^_^)"

#}
