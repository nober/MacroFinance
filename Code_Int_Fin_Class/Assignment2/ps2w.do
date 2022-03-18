use "${output}/imf/CPIS_omegas", clear
merge 1:1 countryname counterpartcountryname year using "${output}/imf/gravity_vars", gen(gravity_match) keep(match master)
gsort countryname -omega
gen omega_base = omega
label var omega_base "Omega (Actual)"
replace omega = omega_base/(1-outside)

** Save this for Andrea
cap mkdir "~/Dropbox/macrofinance"
save "~/Dropbox/macrofinance/cleaned_data_ps2", replace

use "{output}/factset_fx/factset_fx_quarter.dta", clear

format quarter %tq
gen year = yofd(dofq(quarter))
collapse fx_per_usd, by(year iso_currency)
save "{output}/factset_fx/fx_cleaned.dta", replace

********************************************************************************
** Question 1: gravity regressions
********************************************************************************
cap estimates clear
cap drop delta_pred
cap drop omega_share
gen omega_share = log(omega_base/outside)
** replace some gravity components with logs
gen ldistw = log(distw)
gen lgdp_d = log(gdp_d)
gen lgdpcap_d = log(gdpcap_d)
label var ldistw "Log Distance"
label var lgdp_d "Log Issuer GDP"
label var lgdpcap_d "Log Issuer GDP Per Capita"
label var comlang_off "Common Language"
eststo ols: reg omega_share ldistw comlang_off lgdp_d lgdpcap_d
** predict delta from the standard OLS
predict delta_pred
replace delta_pred = exp(delta_pred)
** Try some alternative specifications
eststo fe1: reghdfe omega_share ldistw comlang_off lgdp_d lgdpcap_d, absorb(i.year)
eststo fe2: reghdfe omega_share ldistw comlang_off lgdp_d lgdpcap_d, absorb(i.countrycode)
esttab *, label mtitle("Base Model" "Year FE" "Investor FE") nonum nocons booktabs

********************************************************************************
** Question 2: matrix of portfolio shares
********************************************************************************
bys countrycode year: egen denom = total(delta_pred*from_issuer)
replace denom = denom + 1
gen omega_pred = delta_pred/denom
label var omega_pred "Omega (Predicted)"
set graphics off
local n=1
foreach country in "Japan" "United Kingdom" "France" "China, P.R.: Mainland" {
	local cname = regexr("`country'", ",.*", "")
	twoway (scatter omega_base omega_pred if countrycode == 111 & counterpartcountryname=="`country'", msize(vsmall)) ///
		(lfit omega_base omega_pred if countrycode == 111 & counterpartcountryname=="`country'") ///
		, title("`cname'") name(g`n', replace) 
	local n = `n'+1
}
set graphics on
gr combine g1 g2 g3 g4
gr export "${output}/omega_graph.pdf", replace as(pdf)

levelsof counterpartcountryname if countryname == "Japan" & !mi(omega), local(counts)
local n=1
while `n' < 6 {
	local c : word `n' of `counts'
	local line`n' `"line omega year if countryname==`"Japan"' & counterpartcountryname == `"`c'"' "'
	di "`line`n''"
	local n = `n'+1
}

********************************************************************************
** Question 3: predicted exchange rates
********************************************************************************

merge m:1 countryname  using "${Code_Int_Fin_Class}/Assignment2/imf_iso_xwalk"
drop _merge
rename iso3 iso_country_code 
merge m:1 iso_country_code using "${output}/country_currency.dta"
drop _merge

rename iso_currency_code iso_currency
merge m:m year iso_currency using "{output}/factset_fx/fx_cleaned.dta"
drop _merge
replace fx_per_usd=1 if countrycode==111

bysort counterpartcountrycode year : egen denPQ = total(A*omega_base) 
gen overPQ = fx_per_usd/denPQ

gen O = A*outside 
gen nom_e = O*omega_pred
bys countrycode year : egen denom_e = total(omega_pred*from_issuer)
bys counterpartcountrycode year : egen E_semi = total(nom_e/(1-denom_e))
gen e_pred = E_semi*overPQ

drop denPQ O overPQ nom_e denom_e E_semi 
order fx_per_usd, after(e_pred)

********************************************************************************
** Question 4: distance and Switzerland experiment
********************************************************************************

preserve
keep if countryname == "Switzerland"
keep counterpartcountrycode year ldistw distw 
save "{output}/Switz_dist", replace
restore

preserve
keep if countryname == "New Zealand"
drop ldistw distw
merge m:1 counterpartcountrycode year  using "/Users/ac4790/Desktop/Assignment2_data/Switz_dist"
drop _merge 
save "{output}/Switz_dist/NZ_new_dist", replace
restore

drop if countryname=="New Zealand" 
append using "{output}/Switz_dist/NZ_new_dist"
eststo ols: reg omega_share ldistw comlang_off lgdp_d lgdpcap_d
predict delta_pred_new
replace delta_pred_new = exp(delta_pred_new)
order delta_pred, after(delta_pred_new)

bys countrycode year: egen denom_new = total(delta_pred*from_issuer)
replace denom_new = denom_new + 1
gen omega_pred_new = delta_pred_new/denom_new

local n=1
label var omega_pred_new "Omega (Switzerland distance)"
foreach country in "Australia" "Japan" "France" "China, P.R.: Mainland" {
	local cname = regexr("`country'", ",.*", "")
	 scatter omega_pred_new omega_pred if countrycode == 196 & counterpartcountryname=="`country'", msize(vsmall) , title(		"`cname'") name(g`n', replace) 
	local n = `n'+1
}
set graphics on
gr combine g1 g2 g3 g4
gr export "{output}/omega_graph_moddist.pdf", replace as(pdf)

bysort counterpartcountrycode year : egen denPQ = total(A*omega_base) 
gen overPQ = fx_per_usd/denPQ

gen O = A*outside 
gen nom_e = O*omega_pred_new
bys countrycode year : egen denom_e = total(omega_pred_new*from_issuer)
bys counterpartcountrycode year : egen E_semi = total(nom_e/(1-denom_e))
gen e_pred_new = E_semi*overPQ

order e_pred_new, after(e_pred)


