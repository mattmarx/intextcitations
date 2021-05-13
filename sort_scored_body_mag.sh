#<ctrl v><tab> to do the tab
echo "sorting internally"
sort -t"	" -k19,20 scored_body_mag.tsv | uniq > scored_body_mag_sorted.tsv
echo "picking best for each pat/mag/line"
findbest_match.pl scored_body_mag_sorted.tsv > scored_body_mag_bestonly.tsv
#rm -f scored_body_mag_sorted.tsv
echo "picking best whether grobid or us"
cat scored_body_mag_bestonly.tsv | cut -f1,2,10,19,21 | sort -k4,4 -k3,3 -k2,2 | findbestofbest_grobid.pl > scored_body_mag_bestonlywgrobid.tsv
