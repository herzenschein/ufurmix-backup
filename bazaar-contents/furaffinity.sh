#!/bin/bash

# Set dialog program for UI
DIALOG=${DIALOG=zenity}

errmsg() {
    $DIALOG --error --text="$1" > /dev/null  #graphical error message
}

cerrmsg() {
    echo -e "$1" > /dev/stderr   #console error message
}

usage() {
    cerrmsg
    cerrmsg "furaffinity.sh: FurAffinity gallery grabber 0.2"
    cerrmsg "Scripted by Мышонак <valkur@gmail.com>"
    cerrmsg "Website: http://rodent.dyndns.org/"
    cerrmsg "\033[32mGUI by Shnatsel <shnatsel@gmail.com>\033[0m"
    cerrmsg
    cerrmsg "Login and password fields are optional. You will have to"
    cerrmsg "specify login and password if you want to download mature art."
    cerrmsg "Files will be downloaded to the specified directory."
    cerrmsg "Also file links.txt will be created with all URLs."
    cerrmsg

#    exit 1
}

usage

# Get parameters
target=$($DIALOG --entry --text="Specify a user whose gallery will be mirrored: ")
retval=$?
case $retval in #check if the request was interrupted
  1)
    exit 1;;    #exit if the request was interrupted
esac

folder=$( $DIALOG --list --radiolist \
          --title="Which folder?" \
          --column="" --column="" \
            TRUE "gallery" \
            FALSE "scraps" \
            FALSE "favorites")

if $DIALOG --question --text="Would you like to login to your FurAffinity account?" --ok-label="Login" --cancel-label="Skip"; then #To log in or not to log in? That is the question.
	user=$($DIALOG --entry --text="Enter your FurAffinity username: ")
	retval=$?
	case $retval in #check if the request was not interrupted
	  0)
	    pass=$($DIALOG --entry --text="Enter your FurAffinity password: " --hide-text);;   #ask for password
	esac
fi

# Prompt for output folder
outfolder=$($DIALOG --file-selection --directory --title="Where to save the images?")
retval=$?
case $retval in #check if the request was interrupted
  1)
    exit 1;;    #exit if the request was interrupted
esac

cd $outfolder

# DEBUG: Check if folder is specified
if test -z $folder; then
	errmsg "Error: Target user is unspecified"
	usage
	exit 1;
fi

# DEBUG: Check if target user is specified
if test -z $target; then
	errmsg "Error: Target user is unspecified"
	usage
	exit 1;
fi

# Debug stuff
#echo $user
#echo $pass
#echo $target
#echo $folder xx
#exit 1

# Login to furaffinity
wget \
   --save-cookies furaffinity.txt \
   --post-data="name=$user&pass=$pass&login=1&action=login&retard_protection=1" \
   --referer="https://www.furaffinity.net/login/" \
   "https://www.furaffinity.net/login/?url=/" \
   -O -

# Grab pages and collect all URLs to pictures
i=1
echo "" > links.txt
for (( i = 1; i < 30; ++i )); do
    DATA=`wget \
       --load-cookies furaffinity.txt \
       --referer="https://www.furaffinity.net/login/" \
       "http://www.furaffinity.net/$folder/$target/$i/" \
       -O -`
    #DATA=`cat furaffinity.html`

    IS_END=`echo "$DATA" | grep -oe "There are no submissions to list"`
    if test -n "$IS_END"; then
        echo "End of gallery"
        break
    fi

    echo "$DATA" | \
    grep -e "http://d.*thumbnail" | \
    perl -p -e "s/^.*src=\"([^\"]*)\".*$/\$1/" | \
    perl -p -e "s/\.thumbnail//" >> links.txt
done

# Batch download all URLs
wget -c --timeout=30 --connect-timeout=30 --read-timeout=30 --wait=1 --tries=3 -i links.txt

$DIALOG --info --title="FurAffinity download" --text="Downloading finished successfully."

echo -e "\033[37m`date +%H:%M:%S`\033[0m \033[36m*** \033[1mEverything is downloaded!\033[0m"
echo -e "\033[43m                                                                      \033[0m"
echo
sleep 1
