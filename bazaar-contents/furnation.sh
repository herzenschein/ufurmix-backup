#!/bin/bash

# Set dialog program for UI
DIALOG=${DIALOG=zenity}

errmsg() {
    $DIALOG --error --text="$1" > /dev/stderr  #graphical error message
}

cerrmsg() {
    echo -e "$1" > /dev/stderr   #console error message
}

usage() {
    cerrmsg "\033[43;30m ----------- furnation.sh: FurNation gallery grabber 0.2 ------------ \033[0m"
    cerrmsg "\033[32mScripted by Мышонак <valkur@gmail.com>\033[0m"
    cerrmsg "\033[32mWebsite: http://rodent.dyndns.org/\033[0m"
    cerrmsg "\033[32mGUI by Shnatsel <shnatsel@gmail.com>\033[0m"
    cerrmsg
    cerrmsg "\033[37mLogin and password fields are optional. You will have to\033[0m "
    cerrmsg "\033[37mspecify login and password if you want to download mature art.\033[0m "
    cerrmsg "\033[37mFiles will be downloaded to the specified directory.\033[0m "
    cerrmsg "\033[37mAlso file furnation_links.txt will be created with all URLs.\033[0m "
    cerrmsg "\033[43;30m -------------------------------------------------------------------- \033[0m"

    #exit 1
}

usage

# Init
favorites="1"

# Get parameters
target=$($DIALOG --entry --text="Specify a user whose gallery will be mirrored: ")
retval=$?
case $retval in #check if the request was interrupted
  1)
    exit 1;;    #exit if the request was interrupted
esac

# Ask if we mirror art of favorites
if $DIALOG --question --text="Mirror art or favorites?" --ok-label="Art" --cancel-label="Favorites"; then
	favorites="0"
fi

if $DIALOG --question --text="Would you like to login to your FurNation.ru account?" --ok-label="Login" --cancel-label="Skip"; then #To log in or not to log in? That is the question.
	user=$($DIALOG --entry --text="Enter your FurNation.ru username: ")   #ask for username
	retval=$?
	case $retval in #check if the request was not interrupted
	  0)
	    pass=$($DIALOG --entry --text="Enter your FurNation.ru password: " --hide-text);;  #ask for password
	esac
fi

# DEBUG: Check if target user is specified
if test -z $target; then
	errmsg "Error: Target user is unspecified"
	usage
	exit 1;
fi

# Prompt for output folder
outfolder=$($DIALOG --file-selection --directory --title="Where to save the images?")
retval=$?
case $retval in #check if the request was interrupted
  1)
    exit 1;;    #exit if the request was interrupted
esac

# Debug stuff
echo -e "\033[43;30m ----------- furnation.sh: FurNation gallery grabber 0.1 ------------ \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1mChecking data: \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m**** \033[34mUser:\033[36m $user \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m**** \033[34mPassword:\033[36m $pass \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m**** \033[34mTarget user:\033[36m $target \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m**** \033[34mSection to download:\033[36m $section \033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m**** \033[34mTargets favorites:\033[36m $favorites \033[0m"
echo -e "\033[43m                                                                      \033[0m"
echo
sleep 1
#exit 1

# Login to furnation
if test -n "$user"; then
    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1mLogging in! \033[0m"
    SESSION_ID=`wget \
       --post-data="a=login&username=$user&password=$pass&login=1&referer=/&Submit=Войти!" \
       --referer="http://furnation.ru/" \
       "http://furnation.ru/index.php" \
       -O - | grep -e "var _sessid" | perl -p -e "s/^.*var _sessid = \"([^\"]*)\".*$/\\$1/"`

    # Cookie debug
    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1mYour Session ID: $SESSION_ID\033[0m"
else
    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[31m*** \033[1mNot logging in. Guest mode. \033[0m"
fi

echo -e "\033[43m                                                                      \033[0m"
echo

# getdirectory() is a recursive function which dowloads all directories
getdirectory() {
    directory=$1
    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[35m*** \033[1m[Dir #$directory]: Starting to download directory #$directory\033[0m"
    #mkdir -v $target_$directory

    for (( i[$directory]=1; ${i[$directory]} < 200; i[$directory]=`expr ${i[$directory]} + 1` )); do

        echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1m[Dir #$directory]: Downloading page #${i[$directory]}\033[0m"

        # Dowload page
        DATA[$directory]=`wget \
           --no-cookies \
           --header "Cookie: PHPSESSID=$SESSION_ID" \
           --referer="http://furnation.ru/?user=$target&section=$section" \
           "http://furnation.ru/gallery/?user=$target&section=$section&pageFrom=${i[$directory]}&fav=$favorites&d=$directory" \
           -O -`
        #DATA=`cat furaffinity.html`

        # Check if gallery end
        ART_LINES=`echo "${DATA[$directory]}" | grep -e "fur:art"`
        if test -z "$ART_LINES"; then
            echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1m[Dir #$directory]: End of gallery!\033[0m"

            # Check for directories
            #if test "${i[$directory]}" = "1"; then
                # Get folders
                # <a href="/gallery/?section=art&user=bert&d=18">
                echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1m[Dir #$directory]: Checking for available directories on page #${i[$directory]}\033[0m"

                #DIRECTORIES[$directory]=`echo "${DATA[$directory]}" | \
                #grep "<a href=\"/gallery/?section=$section&user=$target&d=[0-9]*\">\$" | \
                #grep -v ">\.\.<" | \
                #perl -p -e "s/^.*d=([0-9]*)\">\$/\\$1/"`

                DIRECTORIES[$directory]=`echo "${DATA[$directory]}" | \
                grep "<a href=\"/gallery/?section=$section&user=$target&d=[0-9]*\">[^<]*</a>\$" | \
                grep -v ">\.\.<" | \
                perl -p -e "s/^.*d=([0-9]*)\">[^<]*<\/a>\$/\\$1/"`

                if test -n "${DIRECTORIES[$directory]}"; then
                    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1m[Dir #$directory]: Found directories: ${DIRECTORIES[$directory]}\033[0m"

                    # Download each folder
                    for dir in ${DIRECTORIES[$directory]}; do
                        getdirectory $dir
                    done
                else
                    echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1m[Dir #$directory]: No directories found\033[0m"
                fi

                sleep 1
            #fi

            break
        fi

        NUM_OF_ART=`echo "$ART_LINES" | wc -l`
        echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[34m*** \033[1m[Dir #$directory]: Got $NUM_OF_ART pictures\033[0m"

        # <img fur:art="43049" src="http://img.furry.su/thumbs/small_a_1252452704_eldi_-_koshachii_obraz_ryjeei_brodyagi.jpg"
        # a_1252452704_eldi_-_koshachii_obraz_ryjeei_brodyagi.jpg
        # http://img.furry.su/files/a_1252452704_eldi_-_koshachii_obraz_ryjeei_brodyagi.jpg

        # Grab art links
        echo "${DATA[$directory]}" | \
        grep -e "fur:art" | \
        perl -p -e "s/^.*thumbs\/small_([^\"]*).*$/\$1/" | \
        perl -p -e "s/(.*)/http:\/\/img.furry.su\/files\/\$1/" >> furnation_links.txt
    done
}

# Grab pages and collect all URLs into "furnation_links.txt" file
echo "" > furnation_links.txt
getdirectory 0

# Batch download all URLs
sleep 1
echo -e "\033[43m                                                                      \033[0m"
echo
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1mNow URLs are collected\033[0m"
echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[32m*** \033[1mStarting to download\033[0m"
sleep 1

wget -c --timeout=30 \
    --no-cookies \
    --header "Cookie: PHPSESSID=$SESSION_ID" \
    --connect-timeout=30 \
    --read-timeout=30 \
    --wait=1 \
    --tries=3 \
    --directory-prefix=$outfolder \
    -i furnation_links.txt
sleep 1

$DIALOG --info --title="FurNation download" --text="Downloading finished successfully."

echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[36m*** \033[1mEverything is downloaded!\033[0m"
echo -e "\033[43m                                                                      \033[0m"
echo
sleep 1
