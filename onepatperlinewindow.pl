#!/usr/local/bin/perl
while (<>) {
 if (/(.*)\t(.*)/) {
  $patent = $1;
  $line = $2;
  #print "$patent\t$line\n";
  $lines = $lines . " " . $line;
  #print "$patent\t$lines\n";
  if (!($patent eq $lastpat)) {
   print "$patent\t$lines\n";
   #print "\n";
   $lines = "";
  }
  $lastpat = $patent;
 }
}
print "$patent\t$lines\n";
