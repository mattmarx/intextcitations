
#for x in {10095..10410}
for x in {10001..10410}
do
 echo "DOING gocr $x"
 python ../multi_proc_prog.py window_gocr/grobidwindowinput-$x window_gocr/grobidwindowout_raw-$x
done


for x in {10001..10410}
##for x in {10001..10001}
do
 echo "DOING g19762004 $x"
 python ../multi_proc_prog.py window_g19762004/grobidwindowinput-$x window_g19762004/grobidwindowout_raw-$x
done

for x in {10001..10783}
#for x in {10001..10001}
do
 echo "DOING u20052019 $x"
 python ../multi_proc_prog.py window_u20052019/grobidwindowinput-$x window_u20052019/grobidwindowout_raw-$x
done
