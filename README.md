Packages for Gluon 2018.1 as used by Freifunk Kreis GT/Freifunk Müritz

The whole picture, i. e. that's how it's build via Jenkins:

```
ffgt@colosses:~/jenkins_data/build$ cat mk-ffgt-2018.sh
#!/bin/bash

if [ ! -d gluon-ffgt-v2018.1 ]; then
    git clone https://github.com/ffgtso/gluon-ffgt-v2018.1.git
fi

cd gluon-ffgt-v2018.1
git pull
if [ -d site ]; then
    /bin/rm -rf site
fi
git clone https://github.com/ffgtso/site-ffgt-v2018.1.git site

if [ ! -e baserelease.txt ]; then
    echo "1.0.0~" >baserelease.txt
fi

if [ ! -e buildnumber.txt ]; then
    echo "0" >buildnumber.txt
fi

MYBUILDNBR="`cat buildnumber.txt`"
RELEASE="`cat baserelease.txt`${MYBUILDNBR}"

export RELEASE
export USEnCORES=30 #22 #1 #22
export GLUON_RELEASE=${RELEASE}
export GLUON_ATH10K_MESH=ibss
export GLUON_BRANCH=stable
export GLUON_LANGS="en de"

make update
#if [ -d packages/ffgt ]; then
#    (cd packages; /bin/rm -rf ffgt ; git clone https://github.com/ffgtso/ffgt_packages-v2018.1.git ffgt)
#fi

FFGTPKGCOMMIT="n/a" #"`(cd packages/ffgt; git rev-parse HEAD)`"
FFGTSITECOMMIT="`(cd site; git rev-parse HEAD)`"
GLUONBASECOMMIT="`git rev-parse HEAD`"

# Valid GLUON_TARGET for 2018.1:
#
# ar71xx-generic ar71xx-tiny ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709
# mpc85xx-generic ramips-mt7621 sunxi x86-generic x86-geode x86-64 ipq806x
# ramips-mt7620 ramips-mt7628 ramips-rt305x

/bin/rm -rf output/images/factory/* #output/images/sysupdate/*
#make -clean GLUON_TARGET=ar71xx-generic && make -clean GLUON_TARGET=x86-kvm_guest
#make -j${USEnCORES} V=s GLUON_TARGET=x86-kvm_guest 2>&1 | tee build.log
make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=x86-64 2>&1 | tee build.log
NumImgKVM=`ls -lh output/images/factory/*x86-64.img* | grep gluon- | wc -l`
if [ ${NumImgKVM} -gt 0 ]; then
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=x86-generic 2>&1 | tee build-x86.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=mpc85xx-generic 2>&1 | tee build-mpc85xx.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=ar71xx-nand 2>&1 | tee build-nand.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=brcm2708-bcm2708 2>&1 | tee build-bcm2708.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=brcm2708-bcm2709 2>&1 | tee build-bcm2709.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=ar71xx-generic 2>&1 | tee build-ar71xx-generic.log
    echo
    make -j${USEnCORES} --output-sync=recurse BUILD_LOG=1 V=s GLUON_TARGET=ar71xx-tiny 2>&1 | tee build-ar71xx-tiny.log
fi

NumImg=`ls -lh output/images/factory/ | grep gluon- | wc -l`
if [ ${NumImg} -gt 0 ]; then
    touch output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Release: ${RELEASE}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "PACKAGES_FFGT_PACKAGES_COMMIT=${FFGTPKGCOMMIT}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "PACKAGES_GLUON_COMMIT=${GLUONPKGCOMMIT}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "GLUON_BASE_COMMIT=${GLUONBASECOMMIT}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Buildslave: ${NODE_NAME:-`uname -n`}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo "Buildjob: ${JOB_URL:-$$}" >>output/images/factory/ffgt-firmware-buildinfo-${RELEASE}
    echo $RELEASE >/tmp/build-2018.1-release.txt

    sed -e "s%@@RELEASE@@%${RELEASE}%g" <site/ReleaseNotes >output/images/factory/ReleaseNotes-${RELEASE}
    cat output/images/factory/ffgt-firmware-buildinfo-${RELEASE} >>output/images/factory/ReleaseNotes-${RELEASE}

    export RELEASE
    (echo "From: technik@guetersloh.freifunk.net (FFGT Technik)" ; \
     echo "To: replies+fw-buildlog@forum.freifunk-kreisgt.de" ; \
     echo "Content-Type: text/plain; charset=utf-8" ; \
     echo "Subject: Neuer Firmwarebuild - rawhide $RELEASE - fertig" ; \
     echo ; \
     echo "Unsere Firmware-Seite [1] wird sich binnen 15 Minuten aktualisieren." ; \
     echo ; \
     echo "*Erstellte Firmwares:*" ; \
     echo "<pre>" ; \
     ls -lh output/images/factory/ | grep gluon- ; \
     echo "</pre>" ; \
     echo ; \
     echo "[1] http://firmware.4830.org/") | /usr/sbin/sendmail wusel@uu.org #replies+fw-buildlog@forum.freifunk-kreisgt.de

    make manifest GLUON_BRANCH=rawhide
    make manifest GLUON_BRANCH=experimental
    make manifest GLUON_BRANCH=testing
    make manifest GLUON_BRANCH=stable
    contrib/sign.sh ../secret-build output/images/sysupgrade/rawhide.manifest
    contrib/sign.sh ../secret-build output/images/sysupgrade/experimental.manifest
    contrib/sign.sh ../secret-build output/images/sysupgrade/testing.manifest
    contrib/sign.sh ../secret-build output/images/sysupgrade/stable.manifest
    cp -p output/images/sysupgrade/rawhide.manifest output/images/sysupgrade/rawhide.manifest-$RELEASE
    mv output/images/sysupgrade/experimental.manifest output/images/sysupgrade/experimental.manifest-$RELEASE
    mv output/images/sysupgrade/testing.manifest output/images/sysupgrade/testing.manifest-$RELEASE
    mv output/images/sysupgrade/stable.manifest output/images/sysupgrade/stable.manifest-$RELEASE

    chmod g+w output/images/factory output/images/sysupgrade
    rsync -av --omit-dir-times --progress output/images/* /firmware/rawhide/
fi

MYBUILDNBR="`cat buildnumber.txt`"
MYBUILDNBR="`expr ${MYBUILDNBR} + 1`"
echo "${MYBUILDNBR}" >buildnumber.txt
```

This time, we use the feeds feature again ...