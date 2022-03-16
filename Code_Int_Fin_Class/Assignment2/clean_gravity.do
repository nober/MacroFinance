

import delimited using "${cpis_alt}/CEPII_Gravity/Gravity_V202102.csv", varn(1) clear

** Merge on the country names for investor countries
ren iso3_o iso3
merge m:1 iso3 using "${Code_Int_Fin_Class}/Assignment2/imf_iso_xwalk"
drop dup country _merge
ren countryname countryname_o

** Now do the same for issuer countries
ren iso3 iso3_o
ren iso3_d iso3
merge m:1 iso3 using "${Code_Int_Fin_Class}/Assignment2/imf_iso_xwalk"
drop dup country _merge
ren (countryname_o countryname) (countryname counterpartcountryname)

** Keep only the required variables
keep countryname counterpartcountryname year distw comlang_off gdp_d gdpcap_d
drop if mi(countryname) | mi(counterpartcountryname)
isid countryname counterpartcountryname year
save "${output}/imf/gravity_vars", replace


/*

gen issuer = inlist(iso3num_o, 111,156,112,122,124,128,172,132,134,136,436,138,142,182,184,144,146,193,532,158,196,576,924,233,935,174,944,534,548,273,566,964,922,199,542,578)
gen investor = issuer | inlist(iso3num_o,223,228,469,536,564,293,186,319,377,113,178,118,117,137,353,914,213,314,313,419,316,913,218,918,238,355,423,939,823,268,176,916,967) | ///
	inlist(iso3num_o,443,941,446,946,546,962,181,684,948,283,968,456,936,961,926,298,846,299,487)
	
keep if investor
keep year iso3num_o iso3num_d distw comlang_off gdp_d gdpcap_d
keep if year >= 1997 & year <= 2021
ren (iso3num_o iso3num_d) (countrycode counterpartcountrycode)

