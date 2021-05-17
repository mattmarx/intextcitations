# intextcitations

The files provided include source code for generating the in-text patent-to-article citations as described in https://www.nber.org/papers/w27987. Languages used include Bash shell, Perl, and Stata.

The code is unsupported and is largely undocumented. It is provided primarily for those interested in understanding the details behind  the algorithms, especially the extraction of citation "snippets" (frankenfilter.pl) and the scoring of extracted matches against scientific articles (score_matches.pl). Moreover, it is executable only in a Sun Grid Engine environment on CentOS with Stata 14 installed as well as several packages including ftools and gtools and the Perl module Text::LevenshteinXS. It requires approximately 20 terabytes of storage, perhaps more. In order to execute end-to-end in less than 4 days, one must be able to parallelize at least 1,000 simultaneous processes.

Here are step by step instructions. They assume  a parallel filesystem structure with 'bigdata' and 'nplmatch' at the top level, which is set to NPL_BASE.

## collecting Papers
refer to the section "prepare MAG files" from https://github.com/mattmarx/reliance_on_science

## collecting full text of Patents
* to go bigdata/rsp_prod
* run python3 get_patents.py body <date range>
  * copy (don't combine) those files into nplmatch/inputs/body/fulltext
 * run nplbody/gensoftlinks.pl
 * count the # of files in fulltext with a numerical extension
 * update sge_{cleanparas*,windows*,npl*}.sh to have the # of files in fulltext as the upper bound on the array job
 * qsub sge_cleanparas_*.sh
 * qsub sge_windows_*.sh
 * qsub sge_npls_*.sh
 *  run assemblebody.sh
 ### bodytext - grobid
 *  go to the nplmatch/grobid/fulltext directory
 *  qsub sge_addpatnumtotext_*.sh
 *  go to nplmatch/grobid/window
 *  qsub sge_patwinoneline*.sh
 *  reserve a machine with 16-28 cores for 96 hours: qrsh -pe omp 16 -l h_rt=96:00:00
 *  from the original window, launch another xterm and run /share/pkg.7.grovid/0.5.6/install/bin/run_grobid.sh
 *  from the new xterm, go to npmatch/grobid and run
 *  module load python3/3.6.9
 *  export NSLOTS=16 (or 28)
 *  <wait a long time>
 *    go to grobid/fulltext and run extractgrobidfulltextpiecewise.sh
 *    then go up a level and run assemblegrobidoutput_windowandfulltext.sh
 *    go to nplmatch/inputs/body and 
  *   qsub sge_terracebody.sh
    * go to nplmatch/inputs/body/checkeveryjournal
    * run checkjournalsinlines.sh (does not have to be qsub)

# Processing Data
at this point make sure NPL_BASE is set to where nplmatch sits. it must find $NPL_BASE/config.pl

go to splittitle_patent
* make sure the dir' body'  exists
* qsub sge_splittitle_body.sh

go to splitpagevol_patent
* make sure the dir' body'  exists
* qsub sge_splitpagevol_body.sh

go to splittitle_journal
* make sure the dir' body'  exists
* qsub sge_splitjournal_body.sh

go to splittitle_articles
* qsub sge_buildtitleregex_body_mag_lev.sh
* set_sge_running_body_mag_lev.sh
* qsub set_sge_scoring_body_mag_lev.sh

go to splitpagevol_articles
* qsub sge_buildsplitregex_body_mag_lev.sh
* qsub set_sge_running_body_mag_lev.sh
* qsub set_sge_scoring_body_mag_lev.sh

go to splitjournal_articles
* qsub sge_buildjournalregex_body_mag.sh
* qsub set_sge_running_body_mag.sh
* qsub set_sge_scoring_body_mag.sh

go to process_matches
* qsub collectscoredmatches_body_mag.sh
* qsub sort_scored_body_mag.sh scored_body_mag.tsv

the resulting file scored_body_mag_bestonlywgrobid.tsv is the resulting in-text citations.


