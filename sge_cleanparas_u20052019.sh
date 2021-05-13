#!/bin/bash -l

#$ -t 10001-10783
#$ -j y
#$ -N cleanparas
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/cleanparas.pl /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_u20052019/paras-$SGE_TASK_ID > /projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/fulltext_u20052019/cleanparas-$SGE_TASK_ID


