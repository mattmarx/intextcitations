#!/usr/local/bin/perl 
$patent = "";
$printjunk=1;

if ($ARGV[0]=~/^-d/) { 
    $stepdebug=1;
    print "***DEBUGGING ON***\n";
    $infile=$ARGV[1]
}
else {
    $stepdebug=0;
    $infile=$ARGV[0];
}
open(INFILE,"$infile")||die("Can't open infile $infile\n");

open(PREFIXES,"/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/prefixes.txt")||die("can't find prefixes file.\n");
my @prefixes;
while(<PREFIXES>) {
    my($line)=$_;
    #DON'T ignore case
    #$line=lc($line);
    chomp($line);
    #print "adding >$line< as a prefix\n" if $stepdebug=1;
    push @prefixes, $line;
    #print @prefixes if $stepdebug==1;
}
close(PREFIXES);

open(POSTFIXES,"/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/postfixes.txt")||die("can't find postfixes file.\n");
my @postfixes;
while(<POSTFIXES>) {
    my($line)=$_;
    #DON'T ignore case
    #$line=lc($line);
    chomp($line);
    #print "adding >$line< as a postfix\n" if $stepdebug=1;
    push @postfixes, $line;
    #print @postfixes if $stepdebug==1;
}
close(POSTFIXES);

open(JOURNALABBREVS,"/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/journalabbrev/journalabbrevs-extended.tsv")||die("can't find journals file\n");
my @journals;
while (<JOURNALABBREVS>) {
    chomp;
    if (/^([^\t\-\(\)]+)\t([^\t\-\(\)]+)/) {
	$journal = $1;
	$abbrev = $2;
	#print "adding journal >$journal< and abbrev >$abbrev<\n";
	push @journals, $journal if length($journal)>7 || $journal=~/ /;
	push @journals, $abbrev if length($abbrev)>7 || $abbrev=~/ /;
    }
}
#print STDERR join("\n", @journals);
close(JOURNALABBREVS);

# Read in file with list of words that are bad if following the focal year.
open(POSTYEARWORDS,"/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/postyearwords.txt")||die("Can't open postyearwords.txt\n");
while (<POSTYEARWORDS>) {
    chomp;
    $word=$_;
    push(@postyearwords,$word);
}
close(POSTYEARWORDS);

# Read in file with list of words that are bad if preceding the focal year.
open(PREYEARWORDS,"/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/preyearwords.txt")||die("Can't open preyearwords.txt\n");
while (<PREYEARWORDS>) {
    chomp;
    $word=$_;
    push(@preyearwords,$word);
}
close(PREYEARWORDS);

$linect=0; # Added just for debuggging purposes
# this strategy worked for front-page because the ref was on a single line. now sometimes they extracted lines are split across sentences and so you get junk AND a real reference. baby-with-the-bathwater problem
while (<INFILE>) {
    chop;

    $fullline=$_;
    $lineprinted=0;
    $linect++;

    next if (/official citations:/) | (/npl citations:/);

    #if (/(^_?_?[A-Z]{0,4}\d{1,10})\t(\d+)\t(\d+)\t(.*)/) {
    if (/(^__[^\t]+)\t(\d+)\t(\d+)\t(.*)/) {
	$patent = $1;
	$year = $2;
	$originaldocoffset = $3;
	$line = $4;

	print "patent $patent\t year $year\n" if $stepdebug==1;
	print "\n\n****************************\nORIGINAL LINE>>$line<<\n\n" if $#yearpos>=0 && $stepdebug==1;

	# Check if bad word precedes or follows the focal year such as "includes" (precedes) or "degrees" (follows).  Only do this check if the line does not include the word journal.
	if (!($line=~/journal/i)) {
	    if(&CheckWordsBeforeAndAfterYear($line,$year)) {
		# print "BAD WORD $bad Skipping >$fullline<\n" if $stepdebug==1; # Dropped because redundant with the STDERR print
		print STDERR "***STDERR*** ***$bad*** $fullline\n" if $printjunk;
		next;
	    }
	}

	# slice off extra years
	# this assumes there will only be up to 4 additional years appearing after or before the focal year. could up it to a larger #
	$npl = $line;
	$linebefore=$npl;
	for $i (0..4) {
	    ## after focal year
	    $npl=~s/(.*\D$year\D.*)(\D20[012]\d\D.*)/$1 . " " x length($2)/eg;
	    $npl=~s/(.*\D$year\D.*)(\D1[89]\d\d\D.*)/$1 . " " x length($2)/eg;

	    ## before focal year
	    ## note that you shouldn't split on a year preceded/followed by a hyphen, could be a page number. or preceded by "at"
	    $npl=~s/(.*[^\d\-]20[01]\d[^\d\-])(.*\D$year\D.*)/" " x length($1) . $2/eg;
	    $npl=~s/(.*[^\d\-]1[89]\d\d[^\d\-])(.*\D$year\D.*)/" " x length($1) . $2/eg;
	}
	if (($stepdebug==1)&&(!($npl eq $linebefore))) {
	    if ($lineprinted==0) {
		$lineprinted=1;
		print "PRECLEAN: >$line<\n";
	    }
	    print "NPLyrchop FOCAL YEAR: $year \nPSTCLEAN: >$npl<\n\n";
	}

	# Cut after semicolon unless followed by  numbers 
	## need to do the combos of years to make this work correctly, as in year slicing above
	$linebefore=$npl;
	my $semicount = $npl =~ tr/;//;
	# Only check for semicolons if less than 5.  Otherwise, may be being
	# used like a comma.
	if ($semicount<5) {
	    $npl=~s/(.\D$year)(;\D\D\D.*)/$1 . " " x length($2)/e;
	    $npl=~s/(.*);(.*\D$year\D.*)/" " x length($1). $2/e;
	    if (($stepdebug==1)&&(!($npl eq $linebefore))) {
		if ($lineprinted==0) {
		    $lineprinted=1;
		    print "PRECLEAN: >$line<\n";
		}
		print  "NPLsemi    PSTCLEAN: >$npl<\n" 
	    }
	}

	# Separate by prefixes
	$linebefore=$npl;
	foreach my $prefix (@prefixes) {
	    $npl=~s/(.*$prefix)(.*\D$year\D.*)/" " x length($1) . $2/e;
            #print "$prefix >$npl< >$linebefore<" if (!($npl eq $linebefore)); 
	} 
	if (($stepdebug==1)&&(!($npl eq $linebefore))) {
	    if ($lineprinted==0) {
		$lineprinted=1;
		print "PRECLEAN: >$line<\n";
	    }
	    print  "NPLprefix  PSTCLEAN: >$npl<\n" 
	}

	# Separate by postfixes
	$linebefore=$npl;
	foreach my $postfix (@postfixes) {
	    $npl=~s/(.*\D$year\D.*)($postfix.*)/$1 . " " x length($2)/e;
	} 
	if (($stepdebug==1)&&(!($npl eq $linebefore))) {
	    if ($lineprinted==0) {
		$lineprinted=1;
		print "PRECLEAN: >$line<\n";
	    }
	    print "NPLpostfix PSTCLEAN: >$npl<\n" 
	}

	# Remove leading/trailing spaces
	$npl=~s/^\s*//;
	$npl=~s/\s*$//;
#        print  "NPLend (year at $preyearlen) PSTCLEAN: >$npl<\n" if $stepdebug==1;

	# finishing touches
	$npl=~s/^see //;
	$npl=~s/^by //;
	$npl=~s/^\s*?[,\.]\s*//;
	$npl=~s/^and //;
	$npl=~s/and$//;
	$npl=~s/\sBy\s?$//;
	$npl=~s/\s\w\s?$//;
	$npl=~s/[,\.]$//;
	$npl=~s/also$//;
	# add requirement that npl have at least three consecutive letters
	print  "$patent\t$npl\n" if !($npl eq "") && ($npl=~/[a-z][a-z][a-z]/);
	#push @npls, $npl;
    }
}

#print "$_\n\n" for @npls;

# Return 0 if line should be tossed as a result of having a bad word preceding or following
# the focal year.
sub CheckWordsBeforeAndAfterYear {
    my($myline,$myyear)=@_;
    my($i);
    my($preword,$postword);
    my($retval)=0;
    my($yearpos,$stringpos);
    my($index);

    # Word immediately before
    $myline=~/(\w+)[^a-zA-Z0-9_.(]*[^0-9(]$myyear\D/;
    $preword=$1;
    $index=&mymemberindex($preword,@preyearwords);
    if (($preword)&&($index)) { $bad="PREWORD-$preyearwords[$index-1]"; $retval=1; }

    # Word immediately after
    $myline=~/\D$myyear\s+(\w+)/;
    $postword=$1;
    $index=&mymemberindex($postword,@postyearwords);
    if (($postword)&&($index)) { $bad="POSTWORD-$postyearwords[$index-1]"; $retval=1; }

    # Specific sequences
    if (($myline=~/from $myyear to/)|| 
	($myline=~/of $myyear to/)||
	($myline=~/speed of $myyear/)||
	($myline=~/ $myyear per minute/)|| 
	($myline=~/ $myyear c\./)||
	($myline=~/ $myyear f\./)||
	($myline=~/ $myyear\" c /)||
	($myline=~/ $myyear\" f /)||
	($myline=~/ $myyear g\./)||
	($myline=~/ $myyear r\.p\.m\./)||
	($myline=~/ filing date .{1,12} $myyear/) ||
	($myline=~/ filed on .{1,12} $myyear/) ||
	($myline=~/ issued as u.?s.? pat.{1,5} .{1,12} on .{1,12} $myyear/) ||
	($myline=~/ references cited in the file of this patent $myyear/) ||
	($myline=~/ $myyear r\. p\. m\./)||
	($myline=~/ $myyear horse power/)||
	($myline=~/temperature of $myyear/)) {
	$bad="SEQUENCE: Bad Word Seqence Around Focal Year";
	$retval=1;
    }

    # Sequence of numbers like 1500, 2000, 2500
    if (($myline=~/\d{3,}, $myyear, \d{3,}/)||
	($myline=~/\d{3,}, $myyear, and \d{3,}/)){
	$bad="NUMBER SEQUENCE";
	$retval=1;
    }

    # % Symbol following year.
    if ($myline=~/$myyear%/) { 
	$bad="PERCENT Symbol Found following focal year";
	$retval=1;
    }

    # Other checks for words or word sequences before focal year
    $yearpos=index($myline,$myyear);
    $myline=lc($myline);
    $stringpos=index($myline,"filed ");
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="filed"; $retval=1; }
    $stringpos=index($myline,"application "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="application"; $retval=1; }
    $stringpos=index($myline,"patented "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="patented"; $retval=1; }
    $stringpos=index($myline,"serial "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="serial"; $retval=1; }
    $stringpos=index($myline,"issued "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="issued"; $retval=1; }
    $stringpos=index($myline," isy "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="isy"; $retval=1; }
    $stringpos=index($myline," sheet "); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="sheet"; $retval=1; }
    $stringpos=index($myline,"in the winter"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in the winter"; $retval=1; }
    $stringpos=index($myline,"in the spring"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in the spring"; $retval=1; }
    $stringpos=index($myline,"in the fall"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in the fall"; $retval=1; }
    $stringpos=index($myline,"in the summer"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in the summer"; $retval=1; }
    $stringpos=index($myline," in winter"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in winter"; $retval=1; }
    $stringpos=index($myline," in spring"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in spring"; $retval=1; }
    $stringpos=index($myline," in fall"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in fall"; $retval=1; }
    $stringpos=index($myline," in summer"); 
    if (($stringpos>=0)&&($stringpos<$yearpos)&&(($stringpos+30)>$yearpos)) { $bad="in summer";$retval=1; }

    $retval;
}

#Called by the form &member($item,@list) and returns "yes" if $item is a member
#of the list @list.
sub member {
    my($search,@inlist)=@_;
    $retval="";
    foreach $item (@inlist) {
        if ("$item" eq "$search") { $retval="yes"; }
    }

    $retval;
}

# Returns index+1 if an item is a member of the list.  Returns 0 if it is not a member.
sub mymemberindex {
    my($matchitem,@myarray)=@_;
    my($numitems,$retval,$i);
    $retval=0;

    $numitems=@myarray;
    for($i=0;$i<$numitems;$i++) {
        if (($myarray[$i])&&("$matchitem" eq "$myarray[$i]")) {
            $retval=$i+1;
	    $i=$numitems;
        }
    }

    $retval;
}

