global Data_Int_Fin_Class "$macrofinpath/Data_Int_Fin_Class"
global Code_Int_Fin_Class "$macrofinpath/MacroFinance/Code_Int_Fin_Class"

global raw "${Data_Int_Fin_Class}/rawdata"
global imf "${raw}/imf"
global bis "${raw}/bis"
global gcap "${raw}/gcap/DTA"
global fx "${raw}/fx"
global output "${Data_Int_Fin_Class}/output"
global temp "${Data_Int_Fin_Class}/temp"

cap mkdir "${Data_Int_Fin_Class}/output"
cap mkdir "${Data_Int_Fin_Class}/temp"


***************************************
** Assignment 0 do files
***************************************
local build_cpis = 0
local build_bop_qtr = 0
local build_bop_ann = 0
local build_bis = 0

foreach dofile in build_cpis build_bop_qtr build_bop_ann build_bis {
	if ``dofile'' == 1 do "${Code_Int_Fin_Class}/Assignment0/`dofile'.do"
}
	
		
***************************************
** Assignment 1 do files
***************************************
local import_reuters = 0
local clean_monthly_data = 1

foreach dofile in import_reuters clean_monthly_data {
	if ``dofile'' == 1 do "${Code_Int_Fin_Class}/Assignment1/`dofile'.do"
}
