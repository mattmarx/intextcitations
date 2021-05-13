#!/usr/local/bin/perl
$SGE_TASK_ID = $ARGV[0];
while (<STDIN>) {
#chomp;
 # year in the middle of something else
 print if /[\[\] ,;:_\.\(\)\{\}\n\"\'\<\>\?\@\#\~]$SGE_TASK_ID[\[\] ,;:_\.\(\)\{\}\n\"\'\<\>\?\@\#\~]/;
 # year at the start of the line
 print if /^$SGE_TASK_ID[\[\] ,;:_\.\(\)\{\}\n\"\'\<\>\?\@\#\~]/;
 ## year at the end of the line
 print if /[\[\] ,;:_\.\(\)\{\}\n\"\'\<\>\?\@\#\~]$SGE_TASK_ID$/;
}
