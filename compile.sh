#!/bin/sh
currentDirectory=`pwd`
echo "compiling ..."
system -i "CRTSQLRPGI OBJ($2) SRCSTMF('$currentDirectory/$1') OBJTYPE(*PGM)" > $currentDirectory/$1.Spool
i=0;
while IFS='' read -r line || [[ -n "$line" ]]; do
    
    ((i=i+1))
    if [[ $line == RNS* ]] ;
    then
        echo "\t $line"
        break
    fi
done < "$currentDirectory/$1.Spool"
echo "spoolfile: $currentDirectory/$1.Spool"
echo "done"