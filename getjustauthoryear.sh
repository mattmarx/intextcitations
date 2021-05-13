cat fulltext/*OUT/*output* window/window_*/*_raw-* | perl parsegrobidoutput.pl | grep "^777" | sed -e "s/^777//" | sort -u > patauthoryearonly.tsv
