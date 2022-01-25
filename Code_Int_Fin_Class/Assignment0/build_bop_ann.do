import delimited using "${imf}/BOP_01-17-2022 11-56-47-03_timeSeries_Annual.csv", clear varn(1)
drop v88
foreach var of varlist v6-v87 {
	local yr : var label `var'
	ren `var' val`yr'
}
cap mkdir "${output}/imf"
save "${output}/imf/BOP_timeSeries_Annual_cleaned", replace
