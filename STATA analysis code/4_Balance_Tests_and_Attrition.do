set more off

capture log close

global wd "FILEPATH\21-057056 _BlueCabin"

quietly do "$wd\Syntax\2_Variables.do"

log using "$wd\Outputs\4_Balance_Tests_and_Attrition", text replace

keep if ineligible == "NA"
drop if treat == 0 & treat_type !="NA"


***************************************BALANCE TESTS*********************************
ttest age, unequal by(treat)

prtest female, by(treat)

prtest white_british, by(treat)

ttest sdq_1, unequal by(treat)

tab grouped_case_status treat, column chi2

ttest nr_children, unequal by(treat)

tab sdq_2_informant2 treat, chi2

tab sdq_1_informant2 treat, chi2


tab clsw_received_household2 treat, column chi

gen     missing_baseline = . 
replace missing_baseline = 1 if sdq_1 ==. 
replace missing_baseline = 0 if sdq_1 !=. 

ta missing_baseline treat, chi2

************************************** ATTRITION **************************************
*Attrition defined as missing sdq_2 variable
*there are also 27 cases where we do not have sdq_1 but we have sdq_2, included in the below as missing_followup = 0. 

gen     missing_followup = . 
replace missing_followup = 1 if sdq_1 !=. & sdq_2 == . 
replace missing_followup = 0 if sdq_1 !=. & sdq_2 != .
replace missing_followup = 0 if sdq_1 ==. & sdq_2 != .

ta missing_followup treat
prtest missing_followup, by(treat)


*Checking relationship between missing follow-up, treatment status and baseline primary outcome
gen age_strat = . 
replace age_strat = 0 if age_group == 1 | age_group == 2
replace age_strat = 1 if age_group == 3 | age_group == 4

*Adding interaction between structural var and treatment 
logit missing_followup i.treat sdq_1 i.LA age_strat c.sdq_1#i.treat age_strat#i.treat i.LA#i.treat 
estimates store m1

logit missing_followup i.treat sdq_1 i.LA i.age_strat 
estimates store m2

lrtest m1 m2


capture log close