#!/usr/local/bin/perl

require "$ENV{'NPL_BASE'}/nplmatch/config.pl";

$filesize=100000000;

$inputyear="";
$file=0;
if ($ARGV[0]=~/^wos$/i) {
    $inputfilesbasepath="$INPUTDIR_WOS" . "wos_";
    $inputyear=$ARGV[1];
    $sourcefilecode="wos";

    $inputfile="$inputfilesbasepath"."$inputyear".".tsv";

    if (!$inputyear) {
	die("Usage: buildjournalregex_byyear_front.pl [mag YEAR]|[wos YEAR]|[filename_or_fullpath_of_file]\n");
    }
}
elsif ($ARGV[0]=~/^mag$/i) {
    $inputfilesbasepath="$INPUTDIR_MAG" . "mag_";
    $inputyear=$ARGV[1];
    $sourcefilecode="mag";

    $inputfile="$inputfilesbasepath"."$inputyear".".tsv";

    if (!$inputyear) {
	die("Usage: buildjournalregex_byyear_front.pl [mag YEAR]|[wos YEAR]|[filename_or_fullpath_of_file]\n");
    }
}
else {
    $inputfile=$ARGV[0];
    $sourcefilecode="file";
    $file=1;
    
    if (!(-e $inputfile)) {
	die("Usage: buildjournalregex_byyear_front.pl [mag YEAR]|[wos YEAR]|[filename_or_fullpath_of_file]\n");
    }
}

print "Using source directory/file: $inputfile  Sourcecode: $sourcefilecode\n\n";

open(INFILE,$inputfile)||die("Can't open input file $inputfile");

$outputdir="$NPL_BASE" . "nplmatch/splitjournal_articles/year_regex_scripts_front_" . "$sourcefilecode". "/";

$inputdir="$NPL_BASE" . "nplmatch/splitjournal_patent/front/";

$date=`date`;
print "$date";

$curdir="$NPL_BASE" . "nplmatch/splitjournal_articles";
chdir("$curdir");

$skipfilepath="$NPL_MISC" . "skipwords";
open(SKIPWORDSFILE,"$skipfilepath")||die("Couldn't open skipwords file.\n");
while(<SKIPWORDSFILE>) {
    $word=$_;
    $word=~s/\s+//g;
    $SkipWord{$word}=1;
}
close(SKIPWORDSFILE);

$skiptitlespath="$NPL_MISC" . "badtitles.txt";
open(SKIPTITLESFILE,"$skiptitlespath")||die("Couldn't open skiptitles file.\n");
while(<SKIPTITLESFILE>) {
    $title=$_;
    $title=~s/\n//;
    $SkipTitle{$title}=1;
}
close(SKIPTITLESFILE);


# Go through source (WOS|MAG|PUBMED|FILE) file
$linect=0;
while (<INFILE>) {
    $line=$_;

    $linect++;
    if (($linect % 100000)==0) {
	print "At line $linect\n";
    }

    chop($line);

    if (!$line) { next; }

    if ($line=~/^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)/) {
	$year = $1;
	$wosid = $2;
	$vol = $3;
	$issue = $4;
	$firstpage = $5;
	$lastpage = $6;
	$firstauthor = $7;
	$title=$8;
	$journal=$9;

	$year =~ s/\///;
	$wosid =~ s/\///;
	$vol =~ s/\///;
	$issue =~ s/\///;
	$firstpage =~ s/\///;
	$lastpage =~ s/\///;
	$firstpage =~ s/\?//g;
	$lastpage =~ s/\?//g;
	$title=~s/"//g;
	$journal=~s/"//g;

	# Journal is required for this process.  Skip if not present.
	if (!$journal) { 
          #print STDERR "<line $linect>$line<yr>$year<id>$wosid<vol>$vol<iss>$issue<pg1>$firstpage<pgn>$lastpage<auth>$firstauthor<ti>$title<jrn>$journal<\n"; 
          #print STDERR "LINE: $linect\tJOURNAL: $journal<\n"; 
          next; 
        }

	$journal_working=$journal;
	# In journal name, replace spaces with underscores and then drop all non alphanumerics from journal name except for underscore.
	# Must do this on the MAG end of things as well so that they match.
	$journal_working=~s/ /_/g;
	$journal_working=~s/\W//g;
	
	# If a single ? in firstauthor name, treat it as a wildcard (.) character.  This is being 
	# done in a two phase process.  Remove additional ? and most other non-alphanumeric 
	# characters.
	$firstauthor=~s/\?/TEMPORARY/;
	$firstauthor=~s/[^a-zA-z0-9-_,' ]//g; # Remove problematic characters in author name
	$firstauthor=~s/\[//g; # Remove problematic characters in author name
	$firstauthor=~s/\]//g; # Remove problematic characters in author name
	$firstauthor=~s/TEMPORARY/./;

	$firstauthor_lastname=$firstauthor;
	$firstauthor_lastname =~ tr/[A-Z]/[a-z]/;
	$firstauthor_lastname =~ s/,.*//;
	$firstauthor_lastname =~ s/\///;

	if (($file==0)&&($year!=$inputyear)) { 
	    print "ERROR: Mismatch of inputyear $inputyear and line: \n$line\n"; 
	}

	# Title_print variable is used in the output line.  We get rid of all strange characters.
	$title_print=$title;
	$title_print=~s/[^a-zA-Z0-9-,'.(): ]//g;

	# Skip items with No author, "[anonymous]" author, before 1800, or after 2019
	if (($firstauthor_lastname eq "")||($firstauthor_lastname eq "[anonymous]")||($year<1799)||($year>2019)) { next; }

	# Mytitle is the version we use to split the title up in to words in the same way done in 'splittitle_patent'
	$mytitle=lc($title);
	# Skip titles in badtitles file
	if ($SkipTitle{$mytitle}) { next; }
	# Skip all titles less than 8 letters except GenBank
	if ((!("$mytitle" eq "genbank"))&&(length($mytitle)<8)) { next; }
	$mytitle=~tr/"-:;.,'/ /;

	# Find longest and second longest good word in title.
	@words="";
	@words=split(/\s+/,$mytitle);
	$prevword="";
	$longest=0;
	$secondlongest=0;
	$longestword="";
	$secondlongestword="";
	foreach $word (sort(@words)) {
	    $word=~s/[^a-zA-Z]*//g;

	    # Avoid duplicates
	    if ($word eq $prevword) { next; }

	    # Avoid very common words
	    if ($SkipWord{$word}) { next; }

	    # Avoid genetic sequence words
	    if ($word=~/^[agtc]+$/) { next; }

	    if (length($word)>$longest) {
		if ($longestword) {
		    $secondlongest=$longest;
		    $secondlongestword=$longestword;
		}
		$longest=length($word);
		$longestword=$word;
	    }
	    elsif (length($word)>$secondlongest) {
		$secondlongest=length($word);
		$secondlongestword=$word;		
	    }

	    $prevword=$word;
	}


	$regex="\tif (";
	$orneeded=0;
	if (($longestword)&&(length($longestword)>=2)) {
	    $regex.= "/\[\^a\-zA\-Z0\-9\_\-\]$longestword\[\^a\-zA\-Z0\-9\_\-\]/";
	    $orneeded=1;
	}
	if (($secondlongestword)&&(length($secondlongestword)>=2)) {
	    if ($orneeded) { $regex.="||"; }
	    $regex.= "/\[\^a\-zA\-Z0\-9\_\-\]$secondlongestword\[\^a\-zA\-Z0\-9\_\-\]/";
	    $orneeded=1;
	}
	if ($firstpage) {
	    if ($orneeded) { $regex.="||"; }
	    $regex.= "/\[\^a\-zA\-Z0\-9\_\]$firstpage\[\^a\-zA\-Z0\-9\_\]/";
	}
	
        # No matches to work on.  Really should not happen.  Basically requires there not to be a title or first page.
	if (length($regex)<20) { next; } 

	$regex.=") { print \"$wosid\t$year\t$vol\t$issue\t$firstpage\t$lastpage\t$firstauthor\t$title\t$journal\t\$_\"; }\n";

	$Output{$year}{$journal_working}.=$regex;
	$Output{$year+1}{$journal_working}.=$regex;
	if ($year!=1800) {
	    $Output{$year-1}{$journal_working}.=$regex;
	}
    }
    else {
	print "No format match found for line $linect - $line\n";
    }
}

print "\n";

if ($file==0) {
    # Perl line 
    $template_contents="$PERL_LEVDAM_PATH\n\n";

    $sizect=$filesize;
    $filect=0;
    foreach $year (sort(keys %Output)) {
	foreach $myjournal (keys %{ $Output{$year} }) {
	    if ($sizect>=$filesize) {
		$sizect=0;
		$filenum=$filect+1000;
		if ($filect!=0) { 
		    close(OUTFILE); 
		    `chmod 775 $outputfile`;
		}
		$filect++;
		$outputfile="$outputdir"."year"."$inputyear"."-"."$filenum".".pl";
		open(OUTFILE,">$outputfile");
		print OUTFILE "$template_contents";
	    }
	    
	    $firstletter=substr($myjournal,0,1);
	    $secondletter=substr($myjournal,1,1);
	    $myjournalfilepath="$inputdir"."$year/"."$firstletter/" . "$secondletter/"."$myjournal";
	    # print "$myjournal $firstletter $secondletter $myjournalfilepath\n";
	    # Skip if this file does not exist.  Possibly notate this somewhere.
	    if (-e $myjournalfilepath) {
		print OUTFILE "open(INFILE,\"$myjournalfilepath\");\n";
		print OUTFILE "while (<INFILE>) {\n";
		print OUTFILE "$Output{$year}{$myjournal}";
		print OUTFILE "}\n";
		print OUTFILE "close(INFILE);\n\n";

		$sizect+=length($Output{$year}{$myjournal});
	    }
	}
    }
    close(OUTFILE);
    `chmod 775 $outputfile`;
}
else {
    foreach $year (sort(keys %Output)) {
	print "Year is $year\n";
	$outputfile="$outputdir"."year"."$year".".pl";
	open(OUTFILE,">$outputfile");
	
	# Perl line and fullcompare sub
	print OUTFILE "$PERL_LEVDAM_PATH\n\n";
	
	foreach $myjournal (keys %{ $Output{$year} }) {
	    $firstletter=substr($myjournal,0,1);
	    $secondletter=substr($myjournal,1,1);
	    $myjournalfilepath="$inputdir"."$year/"."$firstletter/" . "$secondletter/"."$myjournal";
#	    print "$myjournal $firstletter $secondletter $myjournalfilepath\n";
	    # Skip if this file does not exist.  Possibly notate this somewhere.
	    if (-e $myjournalfilepath) {
		print OUTFILE "open(INFILE,\"$myjournalfilepath\");\n";
		print OUTFILE "while (<INFILE>) {\n";
		print OUTFILE "$Output{$year}{$myjournal}";
		print OUTFILE "}\n";
		print OUTFILE "close(INFILE);\n\n";
	    }
	}
	close(OUTFILE);
	`chmod 775 $outputfile`;
    }
}

$date=`date`;
print "$date";
