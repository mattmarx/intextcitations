#!/bin/bash
rm -f year_regex_scored_body_mag/*.txt
for year in {1800..2019}
#for year in {1979..1979}
do
 echo
 echo "doing $year."
 num=$(ls -l year_regex_output_body_mag/year$year-* | wc -l)
 echo "found $num files for $year."
 maxnum=$((num+999))
 for jobnum in $(eval echo "{1000..$maxnum}")
 do
  qsub -V -P marxnsf1 -N sj_mg_bd -hold_jid xj_mg_bd -o year_regex_scored_body_mag/scored$year-$jobnum.txt ../process_matches/score_matches.pl year_regex_output_body_mag/year$year-$jobnum.txt -body
 done
done

