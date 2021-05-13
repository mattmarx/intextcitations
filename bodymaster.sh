# clean parasgraphs
# sge tag is "cleanparas"
rm -f fulltext_*/cleanparas-* 
qsub sge_cleanparas_g19762004.sh
qsub sge_cleanparas_gocr.sh
qsub sge_cleanparas_u20052019.sh

# generate windows
# sge tag is "genwindow"
rm -f fulltext_*/windows-*
qsub sge_windows_gocr.sh
qsub sge_windows_g19762004.sh
qsub sge_windows_u20052019.sh

#frankenfilter
#sge tag is "frankenfilter"
rm -f fulltext_*/filtered-*
qsub sge_npls_gocr.sh
qsub sge_npls_g19762004.sh
qsub sge_npls_u20052019.sh

# assemble
qsub -N assemblebody -hold_jid frankenfilter assemblebody.sh

# terrace
rm -f bodybyrefyear/*.tsv
qsub sge_terracebody.sh

