global pv "../../patents/patentsview"
global mag "../../mag/dta/"
global oecdfields "../../magoecdfields/"
global fung "../../patents/fung"
global googpat "../../patents/googpat"


import excel using pre1910byhandimtrii.xls, clear firstrow
keep magid patent check
keep if check=="x"
drop check
duplicates drop
compress
save illegitpre1911matches, replace

import delimited using scored_body_mag_bestonlywgrobid.tsv, clear
rename v1 reftype
drop if length(reftype)>3
replace reftype = "app" if reftype!="exm"
compress reftype
rename v2 confscore
rename v3 magid
rename v4 patent
replace patent = upper(patent)
gen uspto = regexm(patent, "__US")
// replace patent = "__US" + patent if !regexm(patent, "__US")
*drop if confscore<3
replace confscore = 10 if confscore>10
replace patent = lower(trim(patent))
drop if missing(patent)
compress
gen patnum = patent
replace patnum = regexs(1) if regexm(patnum, "__us(.*)")
replace patnum = regexs(1) if regexm(patnum, "us(.*)")
* downweight cites where paper is far in the future
merge m:1 patnum using $googpat/1835-2019patgrantyears, keep(1 3) nogen
destring patnum, gen(patint) force
replace grantyear = 2019 if patint>10165721 & patint<10524402
replace grantyear = 2020 if patint>10524402 & !missing(patnum)
drop patint
replace grantyear = . if uspto==0
merge m:1 magid using $mag/magyear, keep(1 3) nogen
gen patdigits = regexs(1) if regexm(patent, "__us([0-9]+)")
replace patent = "__uspp" + patdigits if length(patdigits)==5 & year>grantyear+3
replace grantyear = 2020 if length(patdigits)==5 & year>grantyear+3
replace patent = "__ush" + patdigits if length(patdigits)==4 & year>grantyear+3
replace grantyear = 2020 if length(patdigits)==4 & year>grantyear+3
replace confscore = confscore - 3 if year>grantyear+5 & !missing(grantyear) & !missing(year)
replace confscore = confscore - 5 if year>grantyear+10 & !missing(grantyear) & !missing(year)
* remove leading zeroes
replace patent = regexs(1) + regexs(2) if regexm(patent, "(__[a-zA-Z]+)0+(.*)")
* downweight cites where it is a really unusual cpc/oecd mapping and confidence is low
destring patnum, replace force
merge m:1 patnum using $pv/cpc, keep(1 3) nogen
drop patnum
rename cpc oldcpc
merge m:1 patent using $fung/patentcpcs19262017, keep(1 3) nogen
replace cpc = upper(cpc)
replace cpc = oldcpc if missing(cpc) & !missing(oldcpc)
drop oldcpc
compress
merge m:1 magid using $oecdfields/mag_field_extrapolation_final, keep(1 3) keepusing( oecd_field ) nogen
	* cpc A
	replace confscore = confscore - 1 if confscore<10 & cpc=="A" & (oecd_field==5)
	replace confscore = confscore - 2 if confscore<10 & cpc=="A" & (oecd_field==4 | oecd_field==6)
	* cpc B
	replace confscore = confscore - 1 if confscore<10 & cpc=="B" & (oecd_field==3 | oecd_field==6 | oecd_field==5)
	replace confscore = confscore - 4 if confscore<10 & cpc=="B" & (oecd_field==4)
	* cpc C
	replace confscore = confscore - 1 if confscore<10 & cpc=="C" & (oecd_field==5)
	replace confscore = confscore - 2 if confscore<10 & cpc=="C" & (oecd_field==4 | oecd_field==6)
	* cpc D
	replace confscore = confscore - 1 if confscore<10 & cpc=="D" & (oecd_field==3)
	replace confscore = confscore - 2 if confscore<10 & cpc=="D" & (oecd_field==4 | oecd_field==6)
	* cpc E
	replace confscore = confscore - 1 if confscore<10 & cpc=="E" & (oecd_field==3 | oecd_field==6)
	replace confscore = confscore - 2 if confscore<10 & cpc=="E" & (oecd_field==5)
	replace confscore = confscore - 4 if confscore<10 & cpc=="E" & (oecd_field==4)
	* cpc F
	replace confscore = confscore - 1 if confscore<10 & cpc=="F" & (oecd_field==3)
	replace confscore = confscore - 2 if confscore<10 & cpc=="F" & (oecd_field==5)
	replace confscore = confscore - 4 if confscore<10 & cpc=="F" & (oecd_field==4)
	* cpc G
	replace confscore = confscore - 2 if confscore<10 & cpc=="G" & (oecd_field==5 | oecd_field==6)
	replace confscore = confscore - 4 if confscore<10 & cpc=="G" & (oecd_field==4)
	* cpc H
	replace confscore = confscore - 1 if confscore<10 & cpc=="H" & (oecd_field==6 | oecd_field==3)
	replace confscore = confscore - 2 if confscore<10 & cpc=="H" & (oecd_field==5)
	replace confscore = confscore - 4 if confscore<10 & cpc=="H" & (oecd_field==4)
drop if confscore<1
capture drop grantyear 
capture drop year
drop patdigits
append using grobidauthoryearalsofront
sort magid patent confscore
drop if magid==magid[_n+1] & patent==patent[_n+1] & confscore<confscore[_n+1]
duplicates drop magid patent, force
drop if missing(patent)
drop if missing(magid)
drop v5 cpc oecd_field
* drop the pre-1911 ones Dmitrii found to be wrong
merge 1:1 magid patent using illegitpre1911matches, keep(1 2) nogen
replace patent = upper(patent)
// save scored_body_mag_bestonlyexportincludeconf12, replace
// use scored_body_mag_bestonlyexportincludeconf12, clear
// drop if confscore<3
drop year author
compress
save scored_body_mag_bestonlyexport, replace
/*
use scored_body_mag_bestonlyexport, clear
export delimited using scored_body_mag_bestonlyexport.tsv, replace delim(tab)
!cp scored_body_mag_bestonlyexport.tsv ~/sccpc/



