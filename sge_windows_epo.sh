#!/bin/bash -l

#$ -t 10004-10039
#$ -m a
#$ -j y
#$ -N genwindows
#$ -hold_jid cleanparas
#$ -l h_rt=12:00:00
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/parajustdumpyearwindowsEPO.pl /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_epo/cleanparas-$SGE_TASK_ID > /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_epo/windows-$SGE_TASK_ID


