#!/usr/bin/env bash

# If you're looking for the variables, please go to bin/.preload.sh

# Make sure we're on project root
cd $(dirname $0)/..

# Execute preload script
source bin/.preload.sh

while getopts ":Id" opt; do
    case $opt in
        I)
            SKIP_INSTALL_CHECK=1
            ;;
        d)
            SKIP_WAITING=1
            ;;
        \?)
            echo "Usage: $0 [options...]"
            echo -e " -I\tIgnore installation config"
            echo -e " -d\tSkip waiting for Loklak"
            exit 1
            ;;
    esac
done

# installation
if [ ! -f $INSTALLATIONCONFIG ] && [[ $SKIP_INSTALL_CHECK -eq 0 ]]; then
    echo "Loklak detected that you did not yet run the installation wizard."
    echo "It let's you setup an administrator account and a number of settings, but is not mandatory."
    echo "You can manually start it by running bin/installation.sh"

:<<'OPTIONAL'
    while [ true ]; do
        echo "Would you like to start the installation now? (y)es, (n)o, (r)emind me next time"
        read -n 1 -s -t 20 input
        if  [ $? = 0 ]; then
            if [ "$input" = "y" ]; then
                bin/installation.sh
                if [ $? -ne 0 ]; then
                    exit 1
                fi
                break
            elif [ "$input" = "n" ]; then
                echo "Installation wizard skipped."
                echo 'skipped' > $INSTALLATIONCONFIG
                break
            elif [ "$input" = "r" ]; then
                break
            fi
        else
            echo "Timeout, skipping installation wizard."
            echo 'skipped' > $INSTALLATIONCONFIG
            break
        fi
    done
OPTIONAL
fi

echo "starting loklak"
echo "startup" > $STARTUPFILE

cmdline="$cmdline -server -classpath $CLASSPATH -Dlog4j.configurationFile=$LOGCONFIG org.loklak.LoklakServer >> data/loklak.log 2>&1 &";

eval $cmdline
PID=$!
echo $PID > $PIDFILE

if [[ $SKIP_WAITING -eq 0 ]]; then
    while [ -f $STARTUPFILE ] && kill -0 $PID > /dev/null 2>&1; do
        if [ $(cat $STARTUPFILE) = 'done' ]; then
            break
        else
            sleep 1
        fi
    done
fi

if [ -f $STARTUPFILE ] && kill -0 $PID > /dev/null 2>&1; then
    CUSTOMPORT=$(grep -iw 'port.http' conf/config.properties | sed 's/^[^=]*=//' );
    LOCALHOST=$(grep -iw 'shortlink.urlstub' conf/config.properties | sed 's/^[^=]*=//');
    echo "loklak server started at port $CUSTOMPORT, open your browser at $LOCALHOST"
    rm -f $STARTUPFILE
    exit 0
else
    echo "loklak server failed to start. See data/loklag.log for details. Here are the last logs:"
    tail data/loklak.log
    rm -f $STARTUPFILE
    exit 1
fi
