#/bin/bash -x


echo "getting fulltext digitized"
cat  fulltext_g19762004/*filtered* fulltext_u20052019/*filtered* | sed -e 's/^__US0*/__US/' | sort -u > bodynpl_digitized_ulc.tsv
#cat  fulltext_g19762004/*filtered* fulltext_u20052019/*filtered* | tr [:upper:] [:lower:] | sort -u > bodynpl_digitized.tsv
# gather the OCR and run them through dash handling
echo "getting OCR and handling dash"
cat fulltext_gocr/*filtered* | ocrnpldash.pl | sed -e 's/^__US0*/__US/' | sort -u > bodynpl_ocr_ulc.tsv
#cat fulltext_gocr/*filtered* | ocrnpldash.pl | tr [:upper:] [:lower:] | sort -u > bodynpl_ocr.tsv


echo "combine all, preserving case"
cat bodynpl_digitized_ulc.tsv | tr [:upper:] [:lower:] > bodynpl_digitized.tsv
cat bodynpl_ocr_ulc.tsv | tr [:upper:] [:lower:] > bodynpl_ocr.tsv
