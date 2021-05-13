#!/usr/local/bin/perl 
$patent = "";
#@npls = ();
$prewindowsize = 250;
$postwindowsize = 250;
$stepdebug = 0;

$date=`date +%F`;
$date=~s/\s+//g;
$titledir="/projectnb/marxnsf1/dropbox/bigdata/nplmatch/inputs/body/titles_noyear/";
$inputfile=$ARGV[0];
$titlefile=$inputfile;
@dirparts=split(/\//,$titlefile);
$numparts=@dirparts;
$finaldir=$dirparts[$numparts-2];
if ($finaldir) {
    $finaldir=~s/fulltext_//;
    $titlefile=~s/.*\///;
    $titlefile="$titledir" . "$finaldir" . "-$titlefile" . "-title";

}
else {
    $titlefile=~s/.*\///;
    $titlefile="$titledir" . "$titlefile" . "-title";
}

open(TITLES,">",$titlefile);

while (<>) {
    chop;

    next if (/official citations:/) | (/npl citations:/);
    # New Patent ID found
    if (/^(__.*)/) {
	print "patent $1\n" if $stepdebug==1;
	$patent = $1;
	#$patent=~s/\-//g;
    }
    # Go through one parargaph at a time
    else {
	$para = $_;
	print ">>>>>>>>>>>>>>>>>>>>>>>>>>>>$para<<<\n" if $stepdebug==1;
	# remove HTML formatting tags
	$para=~s#\<[\/A-Z]+\>##g;
	$para=~s/^__description//;

	# Replace HTML entity for double quote with actual double quote ".
	$para=~s/\&\#34\;/\"/g;

	@yearpos = ();
	$numyears = 0;
	@chars = split(//,$para); 
	for my $i (0 .. $#chars) {
            #it's a year
	    if ((($chars[$i]=~/2/ && $chars[$i+1]=~/0/ && $chars[$i+2]=~/[012]/ && $chars[$i+3]=~/\d/) || #20[012]
		 ($chars[$i]=~/1/ && $chars[$i+1]=~/[89]/ && $chars[$i+2]=~/\d/ && $chars[$i+3]=~/\d/)) #18xx, 19xx
		&&
		# not preceded or followed by digit or dash (as in page range)
		# Modified by Aaron to allow including of years at the end of the paragraph. (+3 and +4 items at end)
		($chars[$i-1]=~/[^\d\w\-\/]/ && (($chars[$i+4]=~/[abcdef]/ && $chars[$i+5]=~/[^\d\w\-\/]/) || $chars[$i+4]=~/[^\d\w\-\/]/ || ($i+3==$#chars) || ($i+4==$#chars)))) {
		print "adding yearpos $i\n" if $stepdebug==1;
		push @yearpos, $i;
	    }
	}
	
	print "There are $#yearpos+1 in the string\n" if $stepdebug==1;
	if ($#yearpos>=0) {
	    print "\n\n****************************\nORIGINAL PARAGRAPH>>$para<<\n\n" if $#yearpos>=0 && $stepdebug==1;
	    foreach my $yearmarker (@yearpos) {
		if ($yearmarker>32000) { 
		    if ($stepdebug) { print "Skipping yearmarker $yearmarker as paragraph greater than 32,000 characters.\n"; }
		    last; 
		}
		$startpos = $yearmarker-$prewindowsize;
		$startpos = 0 if $startpos<0;
		$stoppos = $yearmarker+$postwindowsize;
		$stoppos = $#chars if $stoppos>$#chars;
		$length = $stoppos - $startpos;
		$year = substr $para, $yearmarker, 4;
		$yearplus10 = substr $para, $yearmarker, 14;
		$extract = substr $para, $startpos, $length;

		if ($yearmarker<$prewindowsize) { $yearoffset=$yearmarker; }
		else { $yearoffset=$prewindowsize; }
		
		print "YEARMARKER: $yearmarker\n" if $stepdebug==1;
		print "YEAR: $year\n" if $stepdebug==1;
		print "YEARPLUS10: $yearplus10\n" if $stepdebug==1;
		print "PREFILT: $extract\n" if $stepdebug==1;
		print "YEAROFFSET: $yearoffset\n" if $stepdebug==1;
		$year=substr($extract,$yearoffset,4);

		# Trim Preceding and Following Extra Years material.  Don't drop if apparent year is preceded or followed by a hyphen or preceded by page, p., pg., pp., v., vol. (case insensitive, . optional)
		$preyearextract=substr($extract,0,$yearoffset);
		$postyearextract=substr($extract,$yearoffset+4);
		
		$oldpreyearextract=$preyearextract;
		$preyearextract=~s/.*[^-0-9](1[89]\d\d)[^-0-9]//;
		$delyear=$1;
		if (($preyearextract ne $oldpreyearextract)&&
		    (($oldpreyearextract=~/\Wpage $delyear/i)||
		     ($oldpreyearextract=~/\Wpg\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wpp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wv\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wvol\.* $delyear/i))) {
		    $preyearextract=$oldpreyearextract;
		}
		$preyearextract=~s/.*[^-0-9](20[012])\d[^-0-9]//;
		$delyear=$1;
		if (($preyearextract ne $oldpreyearextract)&&
		    (($oldpreyearextract=~/\Wpage $delyear/i)||
		     ($oldpreyearextract=~/\Wpg\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wpp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wv\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wvol\.* $delyear/i))) {
		    $preyearextract=$oldpreyearextract;
		}

		$oldpostyearextract=$postyearextract;
		$postyearextract=~s/[^-0-9](1[89]\d\d)[^-0-9].*//;
		$delyear=$1;
		if (($postyearextract ne $oldpostyearextract)&&
		    (($oldpostyearextract=~/\Wpage $delyear/i)||
		     ($oldpostyearextract=~/\Wpg\.* $delyear/i)||
		     ($oldpostyearextract=~/\Wpp\.* $delyear/i)||
		     ($oldpostyearextract=~/\Wp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wv\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wvol\.* $delyear/i))) {
		    $postyearextract=$oldpostyearextract;
		}
		$postyearextract=~s/[^-0-9](20[012]\d)[^-0-9].*//;
		$delyear=$1;
		if (($postyearextract ne $oldpostyearextract)&&
		    (($oldpostyearextract=~/\Wpage $delyear/i)||
		     ($oldpostyearextract=~/\Wpg\.* $delyear/i)||
		     ($oldpostyearextract=~/\Wpp\.* $delyear/i)||
		     ($oldpostyearextract=~/\Wp\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wv\.* $delyear/i)||
		     ($oldpreyearextract=~/\Wvol\.* $delyear/i))) {
		    $postyearextract=$oldpostyearextract;
		}

		$extract="$preyearextract" . "$year" . "$postyearextract";

		# Drop letter in cases of 2014a or 2016c.
		$extract =~ s/$year[abcdef]/$year/;

		print "POSTTRIM: $extract\n" if ($stepdebug==1);

    		# get rid of "ibid and anything after, when following a year"
    		$extract =~ s/(.*)$year(.*)ibid.*/$1$year$2/;
		if ($startpos>0) {
		    $prevchar=substr($para, $startpos-1, 1);
		    if ($prevchar=~/\w/) { $extract=~s/^(\S+)/" " x length($1)/e }
		}
		if ($stoppos<$#chars) {
		    $postchar=substr($para, $startpos+$length, 1);
		    if ($postchar=~/\w/) { $extract=~s/(\S+)$/" " x length($1)/e }
		}
                # if there's an ibid before the focal year, replace everything up until that point (including the ibid) with the previous line, except leave out the year
                if ($extract =~ m/ibid.*$year/) {
                    # first remove any numbers
                    $prevextract=~s/\d//g;
     		    # next, replace  everything through ibid with previous extraction
     		    $extract =~ s/^.*ibid/$prevextract/;
		}
		
		print "$patent\t$year\t$yearmarker\t$extract\n" if length($extract)>10 && $extract=~/$year/;
                $prevextract = $extract;
		print "\n" if $stepdebug==1;
	    }
	}

	#Look for quoted titles with no years nearby.
	$oldpos=0;
	$possible_title="";
	$position=index($para,"\"",0);
	while($position!=-1) {
	    $nextchar=substr($para,$position+1,1);

	    # Found a possible pairing to examine
	    if ($oldpos) {
		$possible_title=substr($para,$oldpos+1,($position-$oldpos-1));

		# Determine if we have already gotten this item based on the year.
		$fulltitle_included_already=0;
#		print "Possible title: $possible_title  Oldpos: $oldpos Position: $position\n";
		foreach $yearmarker (@yearpos) {
#		    print "Testing Yearmarker $yearmarker\n";
		    if ((($oldpos>($yearmarker-250))&&($oldpos<($yearmarker+250)))&&
			(($position>($yearmarker-250))&&($position<($yearmarker+250)))) {
			$fulltitle_included_already=1;
			print "Skipping \"$possible_title\" as in already found window\n" if $stepdebug==1;
			last;
		    }
		}
		
		if (!$fulltitle_included_already) {
		    print "POSSIBLE TITLE: $possible_title\n" if $stepdebug==1;
		    @words=split(/\s+/,$possible_title);
		    $numwords=@words;
		    $capitalized=0;
		    foreach $word (@words) {
			if ($word=~/^[A-Z]/) { $capitalized++; }
		    }
		    if ($numwords!=0) {
			$percentcapitalized=$capitalized/$numwords*100;
		    }
		    else {
			$percentcapitalized=0;
		    }

		    # Require 2/3 of the words to be capitalized.  If so, save this window to titles file
		    if (($numwords>3)&&($percentcapitalized>=66)) {
			$startpos = $oldpos-$prewindowsize;
			$startpos = 0 if $startpos<0;
			$stoppos = $position+$postwindowsize;
			$stoppos = $#chars if $stoppos>$#chars;
			$length = $stoppos - $startpos + 1;
			$extract = substr $para, $startpos, $length;
			
			#print TITLES "__$patent\t\t$oldpos\t$extract\n" if length($extract)>10;
			$lctitle = lc $possible_title;
			$lctitle =~ s/[^ a-zA-Z0-9]+//g;
			$lctitle =~ s/^ +//;
			$lctitle =~ s/ +$//;
			print TITLES "$lctitle\t__$patent\t$extract\n" if length($extract)>10;
			if ($stepdebug>=1) {
			    print "POSSIBLE TITLE: $possible_title\n";
			    print "$lctitle\t__$patent\t$extract\n" if length($extract)>10;
			}
		    }
		}
	    }

	    # Only look at pairings of the format "[A-Z]....";
	    if ($nextchar=~/[A-Z]/) {
		$oldpos=$position;
	    }
	    else {
		$oldpos=0;
	    }
	    $position=index($para,"\"",$position+1);
	}
    }
}
