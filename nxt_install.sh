#!/usr/bin/env bash

# Post install script for nxt-client

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:";

wget_bin=$(which wget);
unzip_bin=$(which unzip);
gpg_bin=$(which gpg);
shasum_bin=$(which sha256sum);

if [[ -z "$wget_bin" ]] || [[ -z "$unzip_bin" ]] || [[ -z "$gpg_bin" ]] || [[ -z "$shasum_bin" ]]; then
    echo "Unsatisfied binary dependencies. This script uses the following binarys: wget, unzip, gpg, sha256sum.";
    echo "These applications must be installed in order to run this script.";
    exit 1;
fi

function install {


    if [[ ! -d "/usr/local/bin/nxt/" ]]; then
    
        echo -n "Creating nxt client root directory.. ";
        mkdir -p /usr/local/bin/nxt/ && echo "done." || { echo "Could not create nxt client root directory." ; exit 1;}
    fi

    if [[ "$1" != "update" ]] && [[ "$(ls /usr/local/bin/nxt/ |wc -l)" -gt 0 ]]; then
        echo "nxt client root directory contain files. If you want to overwrite this, issue an update.";
        exit 0;
    fi


    if [[ ! -d "/etc/nxt/" ]]; then

        echo -n "Creating configuration directory for nxt client.. ";
        mkdir -p /etc/nxt && echo "done." || { echo "Could not create nxt client configuration directory." ; exit 1;}
        cp nxt.conf /etc/nxt/
    fi


    if ! id -u nxt >/dev/null 2>&1; then

        echo -n "Adding nxt user.. ";
        useradd -M -u 1167 -b /usr/local/bin -s /sbin/nologin nxt >/dev/null 2>&1 && echo "done." ||
        { echo "Could not add nxt user.  Add it manually after this installation has finished." && exit 1;}
    fi


    if [[ -z "$2" ]]; then
        client_version=$(wget -q -O -  http://download.nxtcrypto.org | sed 's/\(>\|<\)/ /g' |awk {'print $3 '} | 
                         egrep -v "(*e.zip*|changelog)" |egrep '(zip$)' |tail -n 1);
    else
        client_version=$2;
    fi
   
    echo -n "Downloading $client_version from http://download.nxtcrypto.org..";
    
    wget -P /tmp/ -q http://download.nxtcrypto.org/$client_version > /dev/null 2>&1 ||
    { echo "could not download nxt client. Exiting installation."; exit 1; }

    echo "done.";

    client_sign=$(wget -q -O -  http://download.nxtcrypto.org | sed 's/\(>\|<\)/ /g' |awk {'print $3 '} | 
                  egrep $client_version |grep "sha256" |grep "asc")

    if [[ -n "$client_sign" ]]; then
        echo -n "Downloading $client_version shasum signature..";

        wget -P /tmp/ -q http://download.nxtcrypto.org/$client_sign > /dev/null 2>&1 || 
        { echo "could not download nxt client shasum signature. Exiting installation." ; exit 1;}
        
        echo "done.";
    fi

    gpg --recv-keys 0xFF2A19FA > /dev/null 2>&1 || { echo "Could not recieve public key for file verification. Exiting."; exit 1; }
    gpg --verify /tmp/$client_sign > /dev/null 2>&1 || { echo "CRITICAL: Failed to verify the file containing sha256sum for nxt client."; exit 1; }
    cp nxtclient /etc/init.d/ > /dev/null 2>&1 || { echo "Could not copy nxt client init script into /etc/init.d/."; exit 1; }

    sha=$(grep "$client_version" /tmp/$client_sign | awk {'print $1'});

    if [[ -n "$sha" ]]; then
        echo -n "Verifying sha256sum for $client_version..";
        zip_sha=$(sha256sum /tmp/$client_version |awk {'print $1'});
        if [[ "$sha" == "$zip_sha" ]]; then
            echo "done."
            unzip -oq /tmp/$client_version -d /usr/local/bin/ && chown -R nxt:nxt /usr/local/bin/nxt/ > /dev/null 2>&1 ||
            { echo "Could not extract files into nxt client root directory."; exit 1; }
        else
            echo "CRITICAL: The shasum does not match!. Installation will not continue.";
            exit 1;
        fi
    fi

}


function update {

    if [[ -n "$1" ]]; then
        asked_version=$1;
        client_version=$(wget -q -O -  http://download.nxtcrypto.org | sed 's/\(>\|<\)/ /g' |awk {'print $3 '} |
                       egrep -v "(*e.zip*|changelog)" |egrep '(zip$)' |grep "$asked_version");

        if [[ -z "$client_version" ]]; then
            echo "$asked_version does not exist in current location.";
            exit 1;

        else
            if [[ -f "/etc/init.d/nxtclient" ]] && [[ "$(/etc/init.d/nxtclient status |grep 'started' |wc -l)" -gt 0 ]]; then
                /etc/init.d/nxtclient stop
            fi

            install update $client_version
            /etc/init.d/nxtclient start
        fi

    else

        if [[ -f "/etc/init.d/nxtclient" ]] && [[ "$(/etc/init.d/nxtclient status |grep 'started' |wc -l)" -gt 0 ]]; then
            /etc/init.d/nxtclient stop
        fi

        install update
        /etc/init.d/nxtclient start

    fi
}

case "$1" in

    install)
        if [[ -n "$2" ]]; then
            install $2
        else
            install
        fi

        echo "Installation done. Start nxt client with /etc/init.d/nxtclient start, then browse https://localhost:7875";
        echo "Be sure accept incoming tcp traffic to port 7874, else nxt client will not be able to communicate with p2p network.";

    ;;
    update)
        if [[ -n "$2" ]]; then
            update $2
        else
            update
        fi

        echo "Update done.";
        
    ;;

    *)

    N=${0##*/}
    echo "Usage: $N {install|update}" >&2
    exit 1
    ;;
esac

exit 0
