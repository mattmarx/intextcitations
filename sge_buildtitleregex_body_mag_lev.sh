#!/bin/bash -l

#$ -t 1800-2019
#$ -j y
#$ -N bt_mg_bd
#$ -hold_jid splittitle_body
#$ -P marxnsf1
#$ -V

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH


$NPL_BASE/nplmatch/splittitle_articles/buildtitleregex_byyear_body_lev.pl mag $SGE_TASK_ID


