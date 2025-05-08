#!/bin/bash

# export rom/device names from LUNCH
DEVICE="$(sed -e "s/^.*_//" -e "s/-.*//" <<< "$LUNCH")"
TARGET="$(sed -e "s/^.*-//" <<< "$LUNCH")"
FNAME="$(sed -e "s/-.*//" <<< "$LUNCH")"
USER="$(sed -e "s/@.*//" <<< "$TG_NAME")"
ROM="$(sed -e "s/_.*//" <<< "$LUNCH")"

# Telegram Bot
#CHATID="-1001458309391" #vmbyheart
CHATID="-1001458309391" #userbot
API_BOT="5382462017:AAFUNw4cB_gPYj0SJLztJWnYh7DhT-9rHG4" #NEW

# check source is avaiable or not
BUILD_DIR=/home/$USER/$FNAME
if [ "$REPO_SYNC" == false ]; then
     if [ -d $ROM ] || [ -d $BUILD_DIR ]; then
     echo ""
else
     echo -e "\nEither Source isn't synced or Wrong TG_NAME entered\n"
     exit 1
     fi
fi

# lets get into the directory
if [[ ! -z "$BUILD_URL" ]]; then
      if [ -d /home/$USER ]; then
      if [ -d $BUILD_DIR ]; then
        echo -e "\nSetting Build Permission into $BUILD_DIR"
        sudo chown -R jenkins:$USER $BUILD_DIR
        sudo chmod -R 770 $BUILD_DIR
        cd $BUILD_DIR
        echo -e "Entering directory $BUILD_DIR...."
      else
        echo -e "\nCreating directory $BUILD_DIR...."
        sudo mkdir $BUILD_DIR && cd $BUILD_DIR
        sudo chown -R jenkins:$USER $BUILD_DIR
        sudo chmod -R 770 $BUILD_DIR
      fi
      else
        echo -e "User not found, Lets build in Jenkins workspace"
      if [ -d $ROM ]; then
        cd $ROM
        echo -e "\nEntering directory $ROM...."
      else
        mkdir $ROM && cd $ROM
        echo -e "\nCreating directory $ROM...."
      fi
      fi
else
      if [ -d $ROM ]; then
        cd $ROM
        echo -e "\nEntering directory $ROM...."
      else
        mkdir $ROM && cd $ROM
        echo -e "\nCreating directory $ROM...."
      fi
fi

# Init
FOLDER="${PWD}"
OUT="${FOLDER}/out/target/product/$DEVICE"

# Setup Telegram Env
export BOT_MSG_URL="https://api.telegram.org/bot$API_BOT/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$API_BOT/sendDocument"

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$CHATID" \
        -d "parse_mode=html" \
        -d text="$1"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$CHATID" \
        -F caption="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}

#Repo Sync
if [ "$REPO_SYNC" == true ]; then
      if [[ $BUILD_URL == "" ]]; then
            tg_post_msg "♦️|---𝗥𝗘𝗣𝗢 𝗦𝗬𝗡𝗖 𝗦𝗧𝗔𝗥𝗧𝗘𝗗---|♦️️%0A%0A•➤ Started By: @$USER %0A•➤ Rom: $FNAME %0A•➤ Build Directory: ${PWD}" > /dev/null
            echo -e "\nRepo Syncing  on SSH. . .\n"
      else
            tg_post_msg "♦️|---𝗥𝗘𝗣𝗢 𝗦𝗬𝗡𝗖 𝗦𝗧𝗔𝗥𝗧𝗘𝗗---|♦️️%0A%0A•➤ Started By: @$USER %0A•➤ Rom: $FNAME %0A•➤ Console Output: ${BUILD_URL}console" > /dev/null
            echo -e "\nRepo Syncing. . .\n"
      fi
            #rm -rf hardware/qcom-caf/* frameworks/* packages/apps/* prebuilts/clang
            START_REPO=$(date +"%s")
            repo init --depth=1 -u $MANIFEST_URL
            repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags 2<&1 | tee sync.log
            REPO_SYNC_STATUS=${?}
            if ! [ -d $FOLDER ] && [ ${REPO_SYNC_STATUS} != 0 ]; then
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            tg_error sync.log "Sync for $FNAME failed in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" > /dev/null
            echo -e "\n$(date +"%Y-%m-%d") $(date +"%T") E: Repo Sync isn't completed successfully...\n"
            else
            END_REPO=$(date +"%s")
            DIFF_REPO=$((END_REPO-START_REPO))
            echo -e "\n$(date +"%Y-%m-%d") $(date +"%T") I: Sync has been completed successfully, starting to build...\n"
            tg_post_msg "Repo sync completed for $FNAME in $((DIFF_REPO / 3600)) hours, $((DIFF_REPO % 3600 / 60)) minutes and $((DIFF_REPO % 60)) seconds!" > /dev/null
            fi
fi

#Clone_Trees
if [ "$SYNC_TREES" == true ]; then
 echo -e "\nTrees Syncing. . .\n"
         if [ -f clone.sh ] || [ -d script ]; then
         rm -rf clone.sh script
         fi
         git clone $TREE_MANIFEST script
         mv script/clone.sh clone.sh
         source clone.sh
         rm -rf clone.sh script
fi

# CleanUp
cleanup() {
    zips=("$OUT"/*$(date +%Y)*.zip*)
    if [[ -f ${zips} ]]; then
        rm -rf -v "$OUT"/*$(date +%Y)*.zip*
    echo "OLD files found & and got cleared"
    else
    echo "No OLD files found to remove"
    fi
    if [ -f log.txt ]; then
        rm -rf log.txt
    fi
    if [ -f  out/error.log ]; then
        rm -rf out/error.log
    fi
    echo -e "\nOLD logs cleared...\n"
}

# Upload Build
upload() {
    cd $OUT
    file=$(ls *$(date +%Y)*.zip | grep -v ota | tail -n -1)
    if [ -f $file ]; then
        rm -rf *$(date +%Y)*.zip.md5sum
        rm -rf *$(date +%Y)*.zip.sha256sum
    if [ -f *$(date +%Y)*.json ]; then
    jsonfile=$(ls *$(date +%Y)*.json | grep -v ota | tail -n -1)
    tg_error $jsonfile > /dev/null
    fi
    export tag=$(date +"%Y-%m-%d_%H-%M-%S")
    echo $tag
    source /magic.sh
    echo $file
    export repo="https://github.com/BulletFlux/scripts"
    git init > /dev/null
    git remote add origin "$repo" &> /dev/null
    gh release create "$tag" $file -t $file
    export gitdl="https://github.com/BulletFlux/scripts/releases/download/"$tag"/$file"
    md5sum=$(md5sum $file | awk '{print $1}')
    size=$(ls -sh $file | awk '{print $1}')
    END=$(TZ=Asia/Kolkata date +"%s")
    DIFF=$(( END - START ))
    HOURS=$(($DIFF / 3600 ))
    MINS=$((($DIFF % 3600) / 60))
    read -r -d '' finalpost <<EOT
    ✅|----𝗕𝗨𝗜𝗟𝗗 𝗖𝗢𝗠𝗣𝗟𝗘𝗧𝗘𝗗----|✅%0A%0A<b>Hey @$USER your build took $HOURS hours and $MINS minutes and $((DIFF % 60)) seconds</b>%0A%0A<b>🔸 Rom: </b> <code>$FNAME</code>%0A<b>🔸 Build Type: </b> <code>$BUILD_VARIANT</code>%0A<b>🔸 Date: </b> <code>$BUILD_DATE</code>%0A<b>🔸 Size: </b> <code>$size</code>%0A<b>🔸 Md5sum: </b> <code>$md5sum</code>%0A<b>🔻 Download: </b> <a href="$gitdl">${file}</a>
EOT
    tg_post_msg "$finalpost" > /dev/null
    cd ../../..
    fi
}

# Lest Go
letsgo() {
if [[ $BUILD_URL == "" ]]; then
      tg_post_msg "♦️|-----𝗦𝗧𝗔𝗥𝗧𝗜𝗡𝗚 𝗕𝗨𝗜𝗟𝗗-----|♦️%0A%0A<b>•➤ Started By: </b> @$USER %0A<b>•➤ Rom: </b> <code>$FNAME</code>%0A<b>•➤ Device: </b> <code>$DEVICE</code>%0A<b>•➤ Build Type: </b> <code>$BUILD_VARIANT</code>%0A<b>•➤ Target: </b> <code>$TARGET</code>%0A<b>•➤ Build Start: </b> <code>$BUILD_DATE</code>%0A<b>•➤ Build Directory: </b> ${PWD}" > /dev/null
else
      tg_post_msg "♦️|-----𝗦𝗧𝗔𝗥𝗧𝗜𝗡𝗚 𝗕𝗨𝗜𝗟𝗗-----|♦️%0A%0A<b>•➤ Started By: </b> @$USER %0A<b>•➤ Rom: </b> <code>$FNAME</code>%0A<b>•➤ Device: </b> <code>$DEVICE</code>%0A<b>•➤ Build Type: </b> <code>$BUILD_VARIANT</code>%0A<b>•➤ Target: </b> <code>$TARGET</code>%0A<b>•➤ Build Start: </b> <code>$BUILD_DATE</code>%0A<b>•➤ Console Output: </b> ${BUILD_URL}console" > /dev/null
fi
}

#letsgo
# Build
build() {
letsgo
. build/envsetup.sh


# cache
if [[ $(whoami) == jenkins ]]; then
        if [[ ! -d /var/lib/jenkins/workspace/.ccache ]]; then
                mkdir /var/lib/jenkins/workspace/.ccache
        elif [[ ! -d /mnt/ccache ]]; then
                sudo mkdir /mnt/ccache
        fi
        sudo mount --bind /var/lib/jenkins/workspace/.ccache /mnt/ccache
else
        if [[ ! -d /home/$(whoami)/.ccache ]]; then
                mkdir /home/$(whoami)/.ccache
        elif [[ ! -d /mnt/ccache ]]; then
                sudo mkdir /mnt/ccache
        fi
        sudo mount --bind /home/$(whoami)/.ccache /mnt/ccache
fi
        export USE_CCACHE=1
        export CCACHE_EXEC=/usr/bin/ccache
        export CCACHE_DIR=/mnt/ccache
        ccache -M 50G && ccache -o compression=true && ccache -z


# lunch
lunch "$LUNCH"
lunch "$LUNCH"

# make clean
if [ "$MAKE_CLEAN" == clean ]; then
        echo -e "\nCleaning OUT dir....\n"
        rm -rf out
        fi
if [ "$MAKE_CLEAN" == installclean ]; then
        echo -e "\nCleaning Images from OUT....\n"
        make installclean #&& make deviceclean
        fi

# mka build
$BUILD_COMMAND -j$(nproc --all) | tee log.txt
}

# Checker
check() {
    if [[ ! -z "$BUILD_URL" ]] && [[ -d /home/$USER ]]; then
    echo -e "\nSetting back permissions to $BUILD_DIR"
    sudo chown -R jenkins:$USER $BUILD_DIR
    echo -e "Done"
    fi
    rom_zip=("$OUT"/*$(date +%Y)*.zip)
    if [[ ! -f ${rom_zip} ]]; then
    echo "No ROM Zip found"
         END=$(TZ=Asia/Kolkata date +"%s")
         DIFF=$(( END - START ))
         HOURS=$(($DIFF / 3600 ))
         MINS=$((($DIFF % 3600) / 60))
    if [[ $BUILD_URL == "" ]]; then
          tg_post_msg "❌|-----𝗕𝗨𝗜𝗟𝗗 𝗙𝗔𝗜𝗟𝗘𝗗-----|❌%0A%0A@$USER Your $FNAME Build for $DEVICE <b>failed</b> in $HOURS hours and $MINS minutes and $((DIFF % 60)) seconds!" > /dev/null
    else
          tg_post_msg "❌|-----𝗕𝗨𝗜𝗟𝗗 𝗙𝗔𝗜𝗟𝗘𝗗-----|❌%0A%0A@$USER Your $FNAME Build for $DEVICE <b>failed</b> in $HOURS hours and $MINS minutes and $((DIFF % 60)) seconds!%0A%0A<b>•➤ Console Output: </b> ${BUILD_URL}console" > /dev/null
    fi
          tg_error log.txt > /dev/null
    else
          upload
    fi
}

cleanup
BUILD_DATE="$(TZ=Asia/Kolkata date)"
START=$(TZ=Asia/Kolkata date +"%s")
build
check
