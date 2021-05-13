#!/share/pkg/perl/5.24.0/install/bin/perl

$prior_mag="";
$prior_patent="";
while(<>) {
    $line=$_;
    $line=~s/\n//;
    if (!($line=~/\d/)) { next; }
    ($examiner,$confidence,$mag,$patent,$grobidflag)=split(/\t/,$line);
    if (!$patent) { next; }
    if (!(($mag eq $prior_mag)&&($patent eq $prior_patent))) { 
	if ($prior_line) {
	    $prior_line=~s/GROBID/$indicator/;
	    $prior_line=~s/HEURISTICS/$indicator/;
	    print "$prior_line\n"; 
	}

	$prior_confidence=$confidence;
	$prior_mag=$mag;
	$prior_patent=$patent;
	$prior_line=$line;

	# Deal with flags.  Reset and then set appropraite one.
	$gflag=0;
	$hflag=0;
	if ($prior_line=~/GROBID/) { 
	    $gflag=$confidence; 
	    $indicator="G";
	}
	if ($prior_line=~/HEURISTICS/) { 
	    $hflag=$confidence; 
	    $indicator="H";
	}
    }
    # Found matching $mag/$patent line.  Choose better and adjust indicator.  There are sometimes 3 lines.
    else {
	# Adjust Line and Confidence only if Confidence Upgrade.
	if ($confidence>$prior_confidence) {
	    $prior_confidence=$confidence;
	    $prior_line=$line;
	}

	# Update flags.  Regardless.
	if (($line=~/GROBID/)&&($confidence>$gflag)) { $gflag=$confidence; }
	if (($line=~/HEURISTICS/)&&($confidence>$hflag)) { $hflag=$confidence; }

	# Update currently saved line based on relative flag values (could be new or old one)
	# E = Found by both, equal value
	# H = Found by Heuristics only
	# G = Found by Grobid only
	# HB = Found by both, Heuristics better
	# GB = Found by both, Grobid better
	if ($gflag==$hflag) {
	    $indicator="E";
	}
	elsif (!$gflag) {
	    $indicator="H";
	}
	elsif (!$hflag) {
	    $indicator="G";
	}
	elsif ($hflag>$gflag) {
	    $indicator="HB";
	}
	elsif ($gflag>$hflag) {
	    $indicator="GB";
	}
    }
}
$prior_line=~s/GROBID/$indicator/;
$prior_line=~s/HEURISTICS/$indicator/;
print "$prior_line\n";
