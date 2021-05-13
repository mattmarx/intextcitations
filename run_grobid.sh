#!/bin/bash


####### This will take some work to get right,
####### when the grobid dirs are unpacked the
####### grobid-service/config/config.yaml needs to
####### be adjusted to use an available port and that
####### port should be written to a file in TMPDIR so it's accessible
####### in a Python client.  

cd $SCC_GROBID_BIN  

RUNDIR=$TMPDIR/gradlew_${RANDOM}

# Catch signals to clean this directory up
# automatically
clean_up() {
    echo Removing temp directory $RUNDIR.
    rm -rf $RUNDIR 
    echo Done. 
	exit
}
trap clean_up SIGHUP SIGINT SIGTERM

mkdir -p $RUNDIR

cd $RUNDIR

echo Unpacking Grobid.
$SCC_GROBID_BIN/../bin/snzip -dc $SCC_GROBID_BIN/../grobid-0.5.6.tar.sz | tar xf -

echo Done.

cd grobid-0.5.6
./gradlew run

clean_up

