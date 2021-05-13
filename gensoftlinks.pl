#!/usr/local/bin/perl

$filename_prefix=$ARGV[0];

if (!$filename_prefix) { die "Usage: gensoftlinks.pl ARRAYJOBFILE_PREFIX\n"; }

@files=glob("*");
$ctr=10001;
foreach $file (@files) {
    if (-l $file) { next; }
    $newfilename="$filename_prefix"."$ctr";
    $ctr++;
    symlink($file,$newfilename);
}
