#!/usr/local/bin/perl

$infile=$ARGV[0];
if (!$infile) { die "Usage: rmspaces.pl INFILE\n"; }

open(INFILE,"$infile");
while(<INFILE>) {
    $line=$_;
    $line=~s/\n//;
    ($journal,$patent,$window)=split(/\t/,$line);
    $journal=~s/^\s+//;
    $journal=~s/\s+$//;
    print "$journal\t$patent\t$window\n";
}
