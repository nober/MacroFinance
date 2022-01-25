import delimited using "${bis}/WEBSTATS_DEBTSEC_DATAFLOW_csv_col.csv", clear varn(1)

ren v30 measure_desc
foreach var of varlist q4-v331 {
	local yr : var label `var'
	local yrlab = regexr("`yr'", "\-", "")
	ren `var' val`yrlab'
}
cap mkdir "${output}/bis"
save "${output}/bis/BIS_debtsecurities_cleaned", replace
