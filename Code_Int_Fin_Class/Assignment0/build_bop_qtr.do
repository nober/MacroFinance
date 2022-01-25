import delimited using "${imf}/BOP_01-19-2022 00-05-44-00_timeSeries.csv", clear varn(1)
drop v334
foreach var of varlist q1-v333 {
	local yr : var label `var'
	ren `var' val`yr'
}
cap mkdir "${output}/imf"
save "${output}/imf/BOP_timeSeries_cleaned", replace
