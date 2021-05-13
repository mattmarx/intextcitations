#parsed the windows output
cat fulltext/*OUT/*output* window/window_*/*_raw-* | perl extractcitestopatentsfromgrobid.pl > grobidrefstopatents.tsv
cat grobidrefstopatents.tsv | sed -e "s/__US0*/__US/" | sed -e "s/\-0*/\-/" | sed -e "s/__US/US\-/" | grep -v div |  sort -u > intext_refs_to_patents.tsv
