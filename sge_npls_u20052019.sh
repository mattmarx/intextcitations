#!/bin/bash -l

#$ -t 10001-10783
#$ -j y
#$ -N frankenfilter
#$ -hold_jid genwindows
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/frankenfilter.pl /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_u20052019/windows-$SGE_TASK_ID > /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_u20052019/filtered-$SGE_TASK_ID 2> /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_u20052019/skipped-$SGE_TASK_ID


