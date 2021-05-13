#!/usr/local/bin/perl

$debug=0;

$abbrevsfile="/projectnb/marxnsf1/dropbox/bigdata/xwalkwosmag/wosmagjournalxwalk.tsv";
open(ABBREVS,"$abbrevsfile")||die("Can't open abbreviations file $abbrevsfile\n");

$journalmatchesfile="/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/checkeveryjournal/matchedjournalscolor.tsv";
#$journalmatchesfile="/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/checkeveryjournal/temp";
open(JOURNALMATCHES,"$journalmatchesfile")||die("Can't open Journal Matches file $journalmatchesfile\n");

$outfile="/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/checkeveryjournal/matchedjournals_magname.tsv";
open(OUTFILE,">$outfile")||die("Can't open output file $outfile\n");

# Read in Abbrevs file and make an associative array matching abbreviations to full names.
while(<ABBREVS>) {
    $line=$_;
    $line=~s/\n//;
    ($magname,$wosjournalabbrev)=split(/\t/,$line);
    if (!$FullName{$wosjournalabbrev}) {
	$FullName{$wosjournalabbrev}=$magname;
    }
    else {
	$FullName{$wosjournalabbrev}.="\t$magname";
    }
}

# Read in journal matches file and replace abbreviations with MAG full names.
while(<JOURNALMATCHES>) {
    $line=$_;
    $line=~s/\n//;
    ($patent,$npl)=split(/\t/,$line);

    print "considering patent >$patent<\n" if ($debug);

    # Add a leading and trailing space so we can be sure each colored section is preceded and followed by a character.
    $npl=" $npl ";
    $priornpl=$npl;

    $npl=~s/(.)\[01\;31m\[k([^\[]*)\[m\[k(.)/$1$2$3/;
    $priorchar=$1;
    $journal=$2;
    $followingchar=$3;
    $matches=0;
    while ($priornpl ne $npl) {
        print "checking >$journal<\n" if $debug;
	# If colored string is preceded or followed by a letter, skip it.
	if ((!($priorchar=~/[a-zA-Z]/))&&
	    (!($followingchar=~/[a-zA-Z]/))) {
print "got >$journal< matched\n" if $debug;
	    $journal[$matches]=$journal;
	    $matches++;
	}
	$priornpl=$npl;
	$npl=~s/(.)\[01\;31m\[k([^\[]*)\[m\[k(.)/$1$2$3/;
	$priorchar=$1;
	$journal=$2;
	$followingchar=$3;
    }

    # Remove leading and trailing spaces, particularly the ones added above.
    $npl=~s/^\s+//;
    $npl=~s/\s+$//;
    if ($matches==0) {
	print "NO MATCH found in line $line\n" if ($debug);
    }
    for($i=0;$i<$matches;$i++)  {
	$journalabbrev=$journal[$i];
	# Skip duplicate journal names in a single line.  Only handles consecutive duplicates.
	if (($i>0)&&($journalabbrev eq $journal[$i-1])) { next; }
	print "ABBREV: $journalabbrev -- $npl\n" if $debug;
    
	$journalabbrev=~s/^\s+//;
	$journalabbrev=~s/\s+$//;
	
	$journalabbrev=~s/^\(//;
	
	$fullnames=$FullName{$journalabbrev};
	if (!$fullnames) {
	  $journalabbrevnodots = $journalabbrev;
	  $journalabbrevnodots =~ s/\.//g;
	  $fullnames=$FullName{$journalabbrevnoots};
	}
	if (!$fullnames) { 
	    if ($debug) { print "No MAG full name match found for $journalabbrev --- $line -- MATCHES: $matches\n";  }
	    next; 
	}
	
	@parts="";
	@parts=split(/\t/,$fullnames);
	$numparts=@parts;
	for($j=0;$j<$numparts;$j++) {
	    print OUTFILE "$parts[$j]\t$patent\t$npl\n";
#	    print "$parts[$j]\t$patent\t$npl\n";
	    if ($debug) {
		print "$i $j --- $journalabbrev --- $parts[$j]\t$patent\t$npl\n";
	    }
	}
    }
}
