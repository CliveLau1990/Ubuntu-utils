#!/bin/bash
##
# Name: android_envsetup.sh
#
# Purpose: Setup environment for building Android source code.
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

LOCAL_PATH=`pwd`
ASSETS_PATH=${LOCAL_PATH}/assets

TARGET_OS_VERSION=`lsb_release -a  2> /dev/null | sed -n '3p' | sed s/[[:space:]]//g | cut -d : -f 2`
SUPPORT_OS_VERSION="12.04 14.04 16.04"

function info()
{
    echo -e "\033[33m$1\033[0m"
}

function error()
{
    echo -e "\033[31m$1\033[0m"
    exit 255
}

function is_support()
{
    # Check support OS version
    ret=false
    for version in ${SUPPORT_OS_VERSION}
    do
        [ ${TARGET_OS_VERSION} == ${version} ] && ret=true
    done

    [ ${ret} == "false" ] && error "Don't support your Ubuntu version"
}

function ubuntu_1204_setup_env()
{
    apt-get install -y git gnupg flex bison gperf build-essential \
                       zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
                       libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx-lts-quantal:i386 libgl1-mesa-dev-lts-quantal \
                       g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386
    ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
}

function ubuntu_1404_setup_env()
{
    apt-get install -y git-core gnupg flex bison gperf build-essential \
                       zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
                       lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
                       libg11-mesa-dev libxml2-utils xsltproc unzip
}

function ubuntu_1604_setup_env()
{
    ubuntu_1404_setup_env
}

function install_jdk()
{
    info "==>Installing JDK<=="

    # Install jdk-6
    cd ${ASSETS_PATH}
    chmod a+x jdk-6u45-linux-x64.bin
    ./jdk-6u45-linux-x64.bin
    mv ./jdk1.6.0_45 /usr/lib/jvm/java-6-sun
    cd -

    # Install openjdk-7
    apt-get install -y openjdk-7-jdk

    # Install openjdk-8
    case ${TARGET_OS_VERSION} in
        12.04)
        14.04)
            dpkg -i ${ASSETS_PATH}/openjdk-8-jdk_8u45-b14-1_amd64.deb
            apt-get -f install
            ;;
        16.04)
            apt-get install -y openjdk-8-jdk
            ;;
        *)
            error "==>Invalid OS version<=="
            ;;
    esac

    ## Update symbolic links for Java
    #update-alternatives --install "/usr/bin/java" "java" "/opt/jdk1.6.0_45/bin/java" 1
    #update-alternatives --install "/usr/bin/javac" "javac" "/opt/jdk1.6.0_45/bin/javac" 1
    #update-alternatives --install "/usr/bin/javadoc" "javadoc" "/opt/jdk1.6.0_45/bin/javadoc" 1
    #update-alternatives --install "/usr/bin/javaws" "javaws" "/opt/jdk1.6.0_45/bin/javaws" 1
    #update-alternatives --install "/usr/bin/jar" "jar" "/opt/jdk1.6.0_45/bin/jar" 1
    #update-alternatives --install "/usr/bin/javap" "javap" "/opt/jdk1.6.0_45/bin/javap" 1
    #update-alternatives --install "/usr/bin/javah" "javah" "/opt/jdk1.6.0_45/bin/javah" 1
    #
    ## Choose the java you installed as default
    #update-alternatives --config java
    #update-alternatives --config javac
    #update-alternatives --config javadoc
    #update-alternatives --config javaws
    #update-alternatives --config jar
    #update-alternatives --config javap
    #update-alternatives --config javah
}


#function main()
#{

# Check support OS version
is_support

# Add git repository ppa
add-apt-repository -y ppa:git-core/ppa

# Update source list
apt-get update

# Install jdk
install_jdk

# Standard Android Build Environment
case ${TARGET_OS_VERSION} in
    12.04)
        ubuntu_1204_setup_env
        ;;
    14.04)
        ubuntu_1404_setup_env
        ;;
    16.04)
        ubuntu_1604_setup_env
        ;;
    *)
        error "==>Invalid OS version<=="
        ;;
esac

# Freescale Android-4.4.3 Required Environment
apt-get install -y uuid uuid-dev zlib1g-dev liblz-dev liblzo2-2 liblzo2-dev lzop
apt-get install -y u-boot-tools mtd-utils

# kernel "make menuconfig" command Required Packages
apt-get install -y libncurses5 libncurses5-dev

# Configuring USB Access
cat ${ASSETS_PATH}/51-android.txt | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules

#}
