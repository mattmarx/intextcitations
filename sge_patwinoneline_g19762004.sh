#!/bin/bash -l

#$ -t 10001-10410
#$ -j y
#$ -N win_oneline
#$ -l h_rt=12:00:00
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


/projectnb/marxnsf1/dropbox/bigdata/nplmatch/grobid/window/onepatperlinewindow.pl /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_g19762004/windows-$SGE_TASK_ID > /projectnb/marxnsf1/dropbox/bigdata/nplmatch/grobid/window/window_g19762004/grobidwindowinput-$SGE_TASK_ID


