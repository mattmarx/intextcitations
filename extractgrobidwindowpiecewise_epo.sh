
#for x in {10095..10410}
for x in {10004..10039}
do
 echo "DOING epor $x"
 python ../multi_proc_prog.py window_epo/windows-$x window_epo/grobidwindowout_raw-$x
done
