import delimited using "${imf}/CPIS_01-05-2022 23-13-48-80_timeSeries.csv", clear varn(1)
drop v33
foreach var of varlist v12-v32 {
	local yr : var label `var'
	ren `var' val`yr'
}
cap mkdir "${output}/imf"
save "${output}/imf/CPIS_timeSeries_cleaned", replace
