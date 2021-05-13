#!/bin/bash -l

#$ -j y
#$ -N bt_mg_ft
#$ -hold_jid splittitle_front
#$ -l h_rt=96:00:00
#$ -P marxnsf1
#$ -V

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH

$NPL_BASE/nplmatch/splittitle_articles/buildtitleregex_1799_front_lev.pl mag


