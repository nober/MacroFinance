use "${output}/imf/CPIS_omegas", clear
merge 1:1 countryname counterpartcountryname year using "${output}/imf/gravity_vars", gen(gravity_match) keep(match master)
gsort countryname -omega
gen omega_base = omega
label var omega_base "Omega (Actual)"
replace omega = omega_base/(1-outside)

** Save this for Andrea
cap mkdir "~/Dropbox/macrofinance"
save "~/Dropbox/macrofinance/cleaned_data_ps2", replace

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
** Question 3: matrix of portfolio shares
********************************************************************************

