* all records on one line
use if authororder==1 using magauthororder, clear
count
compress
drop authororder
duplicates drop magid, force
merge m:1 authorid using magauthornamesurfirst, keep(1 3) nogen
count
drop if regexm(authorname, "patent") | regexm(authorname, "trademark")
compress
drop authorid
merge 1:1 magid using magyear, keep(1 3) nogen
merge 1:1 magid using magvolisspages, keep(1 3) nogen
count
merge 1:1 magid using magtitle, keep(1 3) nogen
count
merge 1:1 magid using magbooktitle, keep(1 3) nogen
count
replace papertitle = papertitle + " " + booktitle if !missing(booktitle)
drop booktitle
merge 1:1 magid using magconference, keep(1 3) nogen
count
merge 1:1 magid using magjournalid, keep(1 3) nogen
count
destring journalid, replace force
merge m:1 journalid using journalnames, keep(1 3) nogen
drop journalid
replace journalname = conferencename if missing(journalname) & !missing(conferencename)
drop conferencename
count
replace author = lower(author)
replace papertitle = lower(papertitle)
replace journalname = lower(journalname)
order year magid volume issue firstpage lastpage author papertitle journalname
keep year magid volume issue firstpage lastpage author papertitle journalname
compress
save magoneline, replace
export delimited using ../txt/magoneline.tsv, replace delim(tab)
