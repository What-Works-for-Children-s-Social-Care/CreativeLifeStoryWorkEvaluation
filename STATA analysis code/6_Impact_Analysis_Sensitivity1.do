set more off

capture log close
global wd "FILEPATH\21-057056 _BlueCabin"
quietly do "$wd\Syntax\2_Variables.do"
log using "$wd\Outputs\6_Impact_Analysis_Sensitivity1", text replace
keep if ineligible == "NA"
drop if treat == 0 & treat_type !="NA"

*EXCLUDING THOSE CASES WITH SDQ-POST DATE BEFORE THE INTERVENTION OR BEFORE RANDOMISATION (FOR THOSE THAT HAVE DATE OF THE 1ST SESSION MISSING BECAUSE MISSING OR CONTROLS)

count if sdq_2_date < date_1st_session &  date_1st_session !=.
drop if  sdq_2_date < date_1st_session &  date_1st_session !=.

count if  sdq_2_date < date_randomised
drop  if  sdq_2_date < date_randomised

******PRIMARY OUTCOME - SDQ********

gen age_strat = . 
replace age_strat = 0 if age_group == 1 | age_group == 2
replace age_strat = 1 if age_group == 3 | age_group == 4


*REGRESSION
asdoc reg sdq_2 i.treat sdq_1 b2.LA age_strat, r replace save(Sensitivity_1.doc)

capture log close


