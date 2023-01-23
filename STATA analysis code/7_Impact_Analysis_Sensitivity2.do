set more off

capture log close
global wd "FILEPATH\21-057056 _BlueCabin"
quietly do "$wd\Syntax\2_Variables.do"
log using "$wd\Outputs\7_Impact_Analysis_Sensitivity2", text replace
keep if ineligible == "NA"
drop if treat == 0 & treat_type !="NA"

*ON TREATED ANALYSIS DIFFERENTIATING BETWEEN F2F / VIRTUAL / MIXED

gen age_strat = . 
replace age_strat = 0 if age_group == 1 | age_group == 2
replace age_strat = 1 if age_group == 3 | age_group == 4


ta nr_attended if treat == 1

gen     prop_virtual = number_virtually_attended / nr_attended 
gen     all_virtual = 0
replace all_virtual  = 1 if prop_virtual == 1
replace all_virtual  = . if prop_virtual == .

ta prop_virtual if treat == 1

ta all_virtual  if treat == 1 

*KEEP ONLY THOSE WHO ATTENDED VIRTUAL SESSIONS
keep if all_virtual == 1 
*OLS REGRESSION
asdoc reg sdq_2 nr_attended sdq_1 b2.LA i.age_strat if treat == 1, r replace save(Sensitivity_2.doc)


asdoc logit school_moves_incl_binary nr_attended b2.LA age_strat if treat == 1, r append save(Sensitivity_2.doc)
asdoc margins, dydx(nr_attended)  atmeans append save(Sensitivity_2.doc)

asdoc glm nr_placement_changes nr_attended b2.LA age_strat if treat == 1, scale(x2) family(poisson) append save(Sensitivity_2.doc)
asdoc margins, dydx(nr_attended) atmeans append save(Sensitivity_2.doc)


capture log close


