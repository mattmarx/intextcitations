#!/bin/bash -l

#$ -t 10001-10410
#$ -m a
#$ -j y
#$ -N genwindows
#$ -hold_jid cleanparas
#$ -l h_rt=12:00:00
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/parajustdumpyearwindows.pl /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_g19762004/cleanparas-$SGE_TASK_ID > /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_g19762004/windows-$SGE_TASK_ID


