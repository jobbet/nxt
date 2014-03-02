#!/usr/bin/env bash

export wget_bin=$(which wget);
export gpg_bin=$(which gpg);
export git_bin=$(which git);

if [[ -z "$wget_bin" ]]; then
    echo "Could not find wget binary. Exiting.";
    exit 1;
fi

if [[ -z "$gpg_bin" ]]; then
    echo "Could not find gpg binary. Exiting.";
    exit 1;
fi

if [[ -z "$gpg_bin" ]]; then
    echo "Could not find git binary. Exiting.";
    exit 1;
fi

$wget_bin -r -np -nc http://download.nxtcrypto.org/ >/dev/null 2>&1 ||
            { echo "There was an error while downloading nxt client files from mirror." ; exit 1;}

echo -n "Verifying sha256sum..";

$gpg_bin --recv-keys 0xFF2A19FA > /dev/null 2>&1 || { echo "Could not recieve public key for file verification. Exiting."; exit 1; }

for sign in $(ls download.nxtcrypto.org/*.txt.asc)
do
    $gpg_bin --verify "$sign"  > /dev/null 2>&1 || 
        { echo "Failed to verify the file containing sha256sum for $sign"; exit 1;}
done

echo "done." && echo -n "Copying clients to corresponding version directory.."

for version in $(ls download.nxtcrypto.org/ |sort -V |tail -n 20)
do
    
    ver_tag=$(echo $version | egrep 'zip$' |sed 's/\(\-\|\.zip\)/ /g' |awk {'print $3'});

    if [[ -n "$ver_tag" ]]; then

        if [[ ! -d "$ver_tag" ]]; then

            mkdir $ver_tag || { echo -n "Could not create version directory, $ver_tag ."; }
        fi

        mv -n download.nxtcrypto.org/nxt-client-$ver_tag* $ver_tag && echo -n "$ver_tag : " ||
        { echo "Could not copy $ver_tag to version directory."; }

        $git_bin add $ver_tag  || { echo "Could not add $ver_tag to git repo."; }
        $git_bin commit -m "$ver_tag" > /dev/null 2>&1 || { echo "Could not commit $ver_tag to repo"; }
    fi

done

echo -n "Pushing changes to git..";
$git_bin push > /dev/null 2>&1 || { echo "Could not push changes to git, critical."; }
echo "done.";

exit 0;
