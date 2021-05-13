#/bin/bash -l

#$ -t 1800-2019
#$ -j y
#$ -N terracebody
#$ -P marxnsf1
#$ -hold_jid assemblebody

chmod 664 $SGE_STDOUT_PATH
chmod 664 $SGE_STDERR_PATH

cat bodynpl_ocr.tsv bodynpl_digitized.tsv grobidwindowfulltextparsed_lc.txt | terracenpl.pl $SGE_TASK_ID | sed -e 's/^__us0*/__us/' > bodybyrefyear/body_$SGE_TASK_ID.tsv 
##cat bodynpl_ocr.tsv bodynpl_digitized.tsv grobidwindowfulltextparsed_lc.txt | terracenpl.pl $SGE_TASK_ID | sed -e 's/^_*us//' | sed -e 's/^0*//'  > bodybyrefyear/body_$SGE_TASK_ID.tsv 
