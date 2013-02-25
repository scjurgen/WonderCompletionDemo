#!/bin/bash
#Ask Jurgen Schwietering if you need help on this
#you need to install doxygen, graphviz and mscgen you can do this using home brew
#or follow my guide on www.nerdware.net/xcode

doxyapp="doxygen"

shopt -s nocasematch

if [ $USER = juergen ]
then
    if [ $HOSTNAME == Jurgens-mac-mini.local ]
    then
        doxypath=~/Documents/WonderCompletionDemo/Documentation
    elif [ $HOSTNAME == Jurgens-Mac-air.local ]
    then
        doxypath=~/Documents/WonderCompletionDemo/Documentation
    fi
fi

shopt -u nocasematch



doxyfile=$doxypath/Doxyfile
echo $doxyfile

if [ -f $doxyapp ]
    then
    if [ -f $doxyfile ]
    then
        cd $doxypath
        $doxyapp $doxyfile
        open $doxypath/html/index.html
    else
        echo -e "\n\nWARNING! \nYou need to download doxygen and drop it in the application folder:\nhttp://www.stack.nl/~dimitri/doxygen\n\n"
        echo -e "You need also install graphviz and mscgen\n\n"
    fi
fi
read -t 30 -p "Hit ENTER or wait some seconds" ; echo ;
