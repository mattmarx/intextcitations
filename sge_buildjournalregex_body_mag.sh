#!/bin/bash -l

#$ -t 1800-2019
#$ -j y
#$ -N bj_mg_bd
#$ -P marxnsf1
#$ -hold_jid splitjournalbody
#$ -V

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


$NPL_BASE/nplmatch/splitjournal_articles/buildjournalregex_byyear_body.pl mag $SGE_TASK_ID


