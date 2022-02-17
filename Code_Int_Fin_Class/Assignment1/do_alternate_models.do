/*********************************************
clean_monthly_data.do
by: Will Nober
date created: 2/16/2022
purpose: Clean the excess returns data from Matlab 
and test it with CAPM, Fama-French, some other stuff
**********************************************/


***************** Section 1: Clean the LRV data *******************

** Clean the dates
import delimited using ${fx}/dates_stata.csv, clear delim(",")
local n = 1
foreach var of varlist * {
	tostring `var', replace
	ren `var' v`n'
	local n = `n'+1
}
egen date = concat(v*)
drop v*

** Generate a date in proper Stata format
gen date_monthly = date(date, "DMY")
gen n = _n
format %td date_monthly
tempfile dates 
save `dates'

** Load in the portfolio excess returns and clean them a bit
import delimited using ${fx}/portolfio_xr.csv, clear
drop v1
forv i = 2/7 {
	local j = `i'-1
	ren v`i' xr`j'
}
gen n = _n
merge 1:1 n using `dates', nogen assert(match)
order date* 
drop n

***************** Section 2: Clean the other data *******************







***************** Section 3: Run some GMM *******************
