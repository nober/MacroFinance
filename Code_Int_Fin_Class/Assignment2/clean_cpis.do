clear all
set more off
set type double

use "${output}/imf/CPIS_timeSeries_cleaned", clear

gen issuer = inlist(countrycode, 111,156,112,122,124,128,172,132,134,136,436,138,142,182,184,144,146,193,532,158,196,576,924,233,935,174,944,534,548,273,566,964,922,199,542,578)
gen investor = issuer | inlist(countrycode,223,228,469,536,564,293,186,319,377,113,178,118,117,137,353,914,213,314,313,419,316,913,218,918,238,355,423,939,823,268,176,916,967) | ///
	inlist(countrycode,443,941,446,946,546,962,181,684,948,283,968,456,936,961,926,298,846,299,487)
gen ofc = inlist(countrycode, 319,377,113,178,118,117,137,353)

// br if inlist(indicatorcode," I_A_D_L_T_BP6_USD","I_A_D_S_T_BP6_USD","I_A_D_T_T_BP6_USD","I_A_E_T_T_BP6_USD","I_A_T_T_T_BP6_USD")

foreach var of varlist val* {
	replace `var' = "0" if `var' == "C"
	destring `var', replace
}

forv yr = 2012/2013 {
// 	split val`yr' , parse(E) destring
// 	gen double wanted = val`yr'1 * (10^val`yr'2)
// 	drop `yr'*
// 	ren wanted val`yr'
// 	local after = `yr'-1
// 	order val`yr', after(val`after')
	drop val`yr'
}


** Only keep total debt assets and liabilities 
keep if inlist(indicatorcode,"I_A_D_T_T_BP6_USD","I_L_D_T_T_BP6_USD","I_L_D_T_T_BP6_DV_USD")
keep if investor
sort indicatorcode
** group together derived and non-derived liabilities
egen indtype = group(indicatorcode)
replace indtype = 2 if indtype == 3
** Get the dataset to the country-countercountry level and have wide fields for assets and liabilities
collapse (sum) val* (firstnm) countryname counterpartcountryname ofc investor issuer, by(countrycode counterpartcountrycode indtype)
reshape wide val*, i(countrycode counterpartcountrycode) j(indtype)
ren val*1 delta* // these variables give magnitude of debt holdings by country i issued by country j
ren val*2 L*

** Create variables giving shares of assets held from each issuing country
levelsof countrycode if issuer, local(issuers)
forv yr = 1997/2022 {
	cap confirm variable delta`yr'
	if _rc == 0 {	
		di "found delta`yr'"
		egen A`yr' = rowtotal(delta*)
		foreach issuer in `issuers' {
			gen omega`issuer'_`yr' = (delta`yr'/A`yr') if counterpartcountrycode == `issuer'
		}
	}
	else di "couldn't find delta`yr'"
}

collapse (sum) omega* (firstnm) countryname, by(countrycode)
forv yr = 1997/2022 {
	cap confirm variable omega111_`yr'
	if !_rc {
		egen omega000_`yr' = rowtotal(omega*_`yr')
		replace omega000_`yr' = 1-omega000_`yr'
	}
}
foreach issuer in `issuers' {
	
}
