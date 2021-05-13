#/bin/bash -x
#loop from 1800 () until present
for year in {1800..2019}
do
 echo "looking for papers published in year $year"
 cat magoneline.tsv | grep "^$year" | sed -e 's/\\//g' |  sed -e 's/@//g' | sed -e 's/{//g' | sed -e 's/}//g' > magbyyear/mag_$year.tsv 
done

