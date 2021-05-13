cat fulltext/*PARSED/*parsed* window/window_*/*_parsed-* | sed -e 's/^__US0*/__US/' | sort -u > grobidwindowfulltextparsed_ulc.txt
# create a lowercase version for the non-journal match
cat grobidwindowfulltextparsed_ulc.txt | tr [:upper:] [:lower:] | sort -u > grobidwindowfulltextparsed_lc.txt
cp grobidwindowfulltextparsed_ulc.txt grobidwindowfulltextparsed_lc.txt ../inputs/body/
