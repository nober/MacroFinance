use "${output}/imf/CPIS_omegas", clear
merge 1:1 countryname counterpartcountryname year using "${output}/imf/gravity_vars", gen(gravity_match) keep(match master)
gsort countryname -omega
gen omega_base = omega
replace omega = omega_base/(1-outside)

********************************************************************************
** Question 1: gravity regressions
********************************************************************************
cap estimates clear
gen omega_share = log(omega_base/outside)
** replace some gravity components with logs
gen ldistw = log(distw)
gen lgdp_d = log(gdp_d)
gen lgdpcap_d = log(gdpcap_d)
eststo ols: reg omega_share ldistw comlang_off lgdp_d lgdpcap_d
** predict delta
predict delta_pred
replace delta_pred = exp(delta_pred)

********************************************************************************
** Question 2: matrix of portfolio shares
********************************************************************************
bys countrycode : egen denom = total(delta_pred)
replace denom = denom + 1
gen omega_pred = delta_pred/denom
twoway (scatter omega_base omega_pred if countrycode == 111 & counterpartcountryname=="Japan") ///
	(scatter omega_base omega_pred if countrycode == 111 & counterpartcountryname=="India")

levelsof counterpartcountryname if countryname == "Japan" & !mi(omega), local(counts)
local n=1
while `n' < 6 {
	local c : word `n' of `counts'
	local line`n' `"line omega year if countryname==`"Japan"' & counterpartcountryname == `"`c'"' "'
	di "`line`n''"
	local n = `n'+1
}

gsort countryname counterpartcountryname year
local investor "Japan"
local c1 "United States"
local c2 "Germany"
local c3 "United Kingdom"
local c4 "France"
local yvar omega

twoway (line `yvar' year if countryname==`"`investor'"' & counterpartcountryname == `"`c1'"' & !mi(omega)) ///
	(line `yvar' year if countryname==`"`investor'"' & counterpartcountryname == `"`c2'"' & !mi(omega)) ///
	(line `yvar' year if countryname==`"`investor'"' & counterpartcountryname == `"`c3'"' & !mi(omega)) ///
	(line `yvar' year if countryname==`"`investor'"' & counterpartcountryname == `"`c4'"' & !mi(omega)) ///
	, legend(order(1 "`c1'" 2 "`c2'" 3 "`c3'" 4 "`c4'"))
	
	

reg omega_share 

