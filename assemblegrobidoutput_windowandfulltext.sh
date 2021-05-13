#parsed the windows output
cd window
rm -f window_*/*_parsed-*
qsub sge_parsewindowoutput_gocr.sh
qsub sge_parsewindowoutput_g19762004.sh
qsub sge_parsewindowoutput_u20052019.sh
cd ../fulltext
rm -f *PARSED/*
qsub sge_parsefulltextoutput_gocr.sh
qsub sge_parsefulltextoutput_g19762004.sh
qsub sge_parsefulltextoutput_u20052019.sh
cd ..
qsub -hold_jid parsegrobid,parsegrobidwin collectgrobidoutput.sh
#cat fulltext/*PARSED/*parsed* window/window_*/*_parsed-* | sed -e 's/^__US0*/__US/' | sort -u > grobidwindowfulltextparsed_ulc.txt
# create a lowercase version for the non-journal match
#cat grobidwindowfulltextparsed_ulc.txt | tr [:upper:] [:lower:] | sort -u > grobidwindowfulltextparsed_lc.txt
#cp grobidwindowfulltextparsed_ulc.txt grobidwindowfulltextparsed_lc.txt ../inputs/body/
