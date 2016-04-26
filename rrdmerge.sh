#!/bin/bash
# First argument is new rrd folder and second argument is
# the old rrd folder

SAVEIFS=$IFS
IFS=$(echo -en '\n\b')
echo $1 $2
cd $1
filelist=`ls | grep ^.*rrd$`
cd -
mkdir $1/backup

process_file(){
        file=$3
        a=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10`
        b=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10`
        c=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10`
        mergedump=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10`
        cp $1/$file /tmp/$a
        cp $1/$file /tmp/$b
        cp $2/$file /tmp/$c
        python ./rrdmerge.py /tmp/$c /tmp/$b /tmp/$a  > $mergedump
        rrdtool restore $mergedump $file
# move new file after backing up old file
        mv $1/$file $1/backup/${file}.origin
        mv ./$file $1/$file
        echo "chown ganglia $1/$file"
        chown ganglia $1/$file

# cleanup
        rm /tmp/$a /tmp/$b /tmp/$c
        rm ./$mergedump
}


for file in $filelist
do
        echo "processing $file"
        process_file $1 $2 $file &
        while (( $(jobs | wc -l ) >= 8 )); do
        sleep 0.5
        done
done
wait
FS=$SAVEIFS
