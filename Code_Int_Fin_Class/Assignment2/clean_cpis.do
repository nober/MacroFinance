clear all
set more off
set type double

use "${output}/imf/CPIS_timeSeries_cleaned", clear

gen issuer = inlist(countrycode, 111,156,112,122,124,128,172,132,134,136,436,138,142,182,184,144,146,193,532,158,196,576,924,233,935,174,944,534,548,273,566,964,922,199,542,578)
gen investor = issuer | inlist(countrycode,223,228,469,536,564,293,186,319,377,113,178,118,117,137,353,914,213,314,313,419,316,913,218,918,238,355,423,939,823,268,176,916,967) | ///
	inlist(countrycode,443,941,446,946,546,962,181,684,948,283,968,456,936,961,926,298,846,299,487)
gen ofc = inlist(countrycode, 319,377,113,178,118,117,137,353)
gen from_issuer = inlist(counterpartcountrycode, 111,156,112,122,124,128,172,132,134,136,436,138,142,182,184,144,146,193,532,158,196,576,924,233,935,174,944,534,548,273,566,964,922,199,542,578)

// br if inlist(indicatorcode," I_A_D_L_T_BP6_USD","I_A_D_S_T_BP6_USD","I_A_D_T_T_BP6_USD","I_A_E_T_T_BP6_USD","I_A_T_T_T_BP6_USD")

foreach var of varlist val* {
	replace `var' = "0" if `var' == "C"
	if inlist("`var'", "val2012", "val2013") {
		replace `var' = "" if `var' == "-"
		replace `var' = "" if regexm(`var',"Ñ") // I don't wanna talk about this
	}
	destring `var', replace
}


** Only keep total debt assets and liabilities 
keep if inlist(indicatorcode,"I_A_D_T_T_BP6_USD","I_L_D_T_T_BP6_USD","I_L_D_T_T_BP6_DV_USD")
keep if investor
sort indicatorcode
** group together derived and non-derived liabilities
egen indtype = group(indicatorcode)
replace indtype = 2 if indtype == 3
** Get the dataset to the country-countercountry level and have wide fields for assets and liabilities
collapse (sum) val* (firstnm) countryname counterpartcountryname ofc investor issuer from_issuer, by(countrycode counterpartcountrycode indtype)
reshape wide val*, i(countrycode counterpartcountrycode) j(indtype) // now every line is a unique country-counterparty observation
ren val*1 delta* // these variables give magnitude of debt holdings by country i issued by country j
ren val*2 L*

** Create variables giving shares of assets held from each issuing country
levelsof countrycode if issuer, local(issuers)
forv yr = 1997/2022 {
	cap confirm variable delta`yr'
	if _rc == 0 {	
		di "found delta`yr'"
		** Get the total debt assets of country i
		bys countrycode : egen A`yr' = total(delta`yr')
		** Get the share of assets owned by i that are issued by j
		gen omega`yr' = (delta`yr'/A`yr') if from_issuer
		** Now make the outside share from the residual
		bys countrycode : egen outside`yr' = total(omega`yr')
		replace outside`yr' = 1-outside`yr'
	}
	else di "couldn't find delta`yr'"
}

reshape long A omega outside delta L, i(countrycode counterpartcountrycode) j(year)

** Some quick summary stats before saving
levelsof countrycode if issuer, local(issuers)
foreach issuer in `issuers' {
	qui summ omega2006 if counterpartcountrycode == `issuer'
	local mm = r(mean)
	di "mean exposure to `issuer': `mm'"
}

save "${output}/imf/CPIS_omegas", replace

