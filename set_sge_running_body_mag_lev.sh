#!/bin/bash

mkdir year_regex_output_body_mag_lev/old
mv year_regex_output_body_mag_lev/*.txt year_regex_output_body_mag/old

for year in {1800..2019}
do
 echo
 echo "doing $year."
 num=$(ls -l year_regex_scripts_body_mag_lev/year$year-* | wc -l)
 echo "found $num files for $year."
 maxnum=$((num+999))
 #echo "qsub -t 1000-$maxnum sge_runlevpieces.sh $year"
 #for jobnum in {1000..$maxnum}
 for jobnum in $(eval echo "{1000..$maxnum}")
 do
  #qsub -N xc_mg_bd -m a -hold_jid bc_mg_bd -o year_regex_output_body_mag_lev/year$year-$jobnum.txt -b y year_regex_scripts_body_mag_lev/year$year-$jobnum.pl
  qsub -V -N xc_mg_bd -hold_jid bc_mg_bd -l h_rt=196:00:00 -o year_regex_output_body_mag_lev/year$year-$jobnum.txt -b y year_regex_scripts_body_mag_lev/year$year-$jobnum.pl
 done
done

