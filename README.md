# intextcitations

The files provided include source code for generating the in-text patent-to-article citations as described in https://www.nber.org/papers/w27987. Languages used include Bash shell, Perl, and Stata.

The code is unsupported and is largely undocumented. It is provided primarily for those interested in understanding the details behind  the algorithms, especially the extraction of citation "snippets" (frankenfilter.pl) and the scoring of extracted matches against scientific articles (score_matches.pl). Moreover, it is executable only in a Sun Grid Engine environment on CentOS with Stata 14 installed as well as several packages including ftools and gtools and the Perl module Text::LevenshteinXS. It requires approximately 20 terabytes of storage, perhaps more. In order to execute end-to-end in less than 4 days, one must be able to parallelize at least 1,000 simultaneous processes.

More documentation may be added, including a file structure schematic.
