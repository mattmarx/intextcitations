#/bin/bash -l

#$ -t 1800-2019
#$ -j y
#$ -N terracejournal
#$ -P marxnsf1

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH

cat matchedjournals_magnameNODUPES.tsv | terracenpl.pl $SGE_TASK_ID > journalbodybyrefyear/journalbody_$SGE_TASK_ID.tsv 


