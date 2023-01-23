set more off

capture log close
global wd "FILEPATH\21-057056 _BlueCabin"
quietly do "$wd\Syntax\2_Variables.do"
log using "$wd\Outputs\5_Impact_Analysis", text replace
keep if ineligible == "NA"
drop if treat == 0 & treat_type !="NA"


*Merging with IMD file (for the exploratory analysis we want to use IMD as control variable)
merge m:1 postcode using "$wd\Data\imd_lsoa_postcode"
drop if _merge == 2
drop    _merge

/*Note that the following postcodes cannot be merged to the imd dataset (these postcodes are missing from the lookup file)
 DD109TW	Gateshead
 FK14NP	    Gateshead
 ML126RS	South Tyneside
 SY175QG	Darlington
So we will lose some observations in the exploratory analysis*/


*FOR THE EXPLORATORY ANALYSIS WE COMBINE CATEGORIES THAT HAVE FEWER THAN 10% OBSERVATIONS - THIS HAPPENS ONLY FOR THE VAR clsw_received_household2, SO FOR THE REGRESSION WE CREATE ANOTHER VARIABLE THAT AGGREGATES UNKNOWNS / MISSING TO NO - THE RESULTS ARE THE SAME IF WE USE THIS OR THE ORIGINAL VARIABLE.
 
clonevar clsw_received_household3 = clsw_received_household2
replace  clsw_received_household3 = 2 if clsw_received_household3 == 4

******PRIMARY OUTCOME - SDQ********

*ONLY STRUCTURAL VARIABLES 
*The regression uses  377 observations, because 146 observations do not have sdq_2
*and 28 observations have no sdq_1 but have sdq_2

gen age_strat = . 
replace age_strat = 0 if age_group == 1 | age_group == 2
replace age_strat = 1 if age_group == 3 | age_group == 4

asdoc reg sdq_2 i.treat sdq_1 b2.LA age_strat, r replace save(Impact.doc)

*Glass' Delta - USING THE REGRESSION COEFFICIENT AS MEAN DIFFERENCE BETWEEN TREATMENT AND CONTROL
su sdq_2 if treat == 0
scalar  sd_control = `r(sd)'
asdoc lincom _b[1.treat]/sd_control, append save(Impact.doc)


*ADJUSTING FOR MISSING SDQ1 SCORES - USING SDQ 1 AS CATEGORICAL VARIABLE (WITH A MISSING CATEGORY)
asdoc reg sdq_2 treat i.sdq_1_cat b2.LA age_strat, r append save(Impact.doc)


*EXPLORATORY ANALYSIS - ADDING OTHER COVARIATES
asdoc reg sdq_2 treat sdq_1 female b1.age_group white_british b1.nr_child_group  b1.clsw_received_household3 b1.sdq_2_informant2 imd_score b2.LA i.age_strat, r append save(Impact.doc)

**********************************************************SECONDARY OUTCOME 1: NUMBER OF SCHOOL MOVES *****************************
*ONLY STRUCTURAL VARIABLES 
asdoc logit school_moves_incl_binary i.treat b2.LA age_strat, r append save(Impact.doc)
asdoc margins, dydx(treat) atmeans post append save(Impact.doc)
*Glass' Delta - USING THE REGRESSION COEFFICIENT AS MEAN DIFFERENCE BETWEEN TREATMENT AND CONTROL
su school_moves_incl_binary if treat == 0
scalar sd_control = `r(sd)'
asdoc lincom _b[1.treat]/sd_control, append save(Impact.doc)


*EXPLORATORY ANALYSIS
asdoc logit school_moves_incl_binary treat female b1.age_group white_british b1.nr_child_group  b1.clsw_received_household3 b1.sdq_2_informant2 imd_score b2.LA i.age_strat, r append save(Impact.doc)
asdoc margins, dydx(treat) atmeans append save(Impact.doc)

*********************************************************SECONDARY OUTCOMES 2: NUMBER OF PLACEMENT CHANGES*******************************
*QUASI-POISSON REGRESSION
*Only structural variables
asdoc glm nr_placement_changes i.treat b2.LA age_strat, scale(x2) family(poisson) append save(Impact.doc)
asdoc margins, dydx(treat) atmeans post append save(Impact.doc)
su nr_placement_changes if treat == 0
scalar sd_control = `r(sd)'
asdoc lincom _b[1.treat]/sd_control, append save(Impact.doc)

*Exploratory analysis
asdoc glm nr_placement_changes treat female b1.age_group white_british b1.nr_child_group  b1.clsw_received_household3 b1.sdq_2_informant2 imd_score b2.LA i.age_strat, scale(x2) family(poisson) append save(Impact.doc)
asdoc margins, dydx(treat) atmeans post append save(Impact.doc)

****************************************************ON-TREATED ANALYSIS*************************************************************
ta nr_attended if treat == 1
*OLS REGRESSION
asdoc reg sdq_2 nr_attended sdq_1 b2.LA i.age_strat if treat == 1, r append save(Impact.doc)

*LOGIT ON NUMBER OF SCHOOL MOVES
asdoc logit school_moves_incl_binary nr_attended b2.LA age_strat if treat == 1, r append save(Impact.doc)
asdoc margins, dydx(nr_attended)  atmeans append save(Impact.doc)

*POISSON NUMBER OF PLACEMENT CHANGE
asdoc glm nr_placement_changes nr_attended b2.LA age_strat if treat == 1, family(poisson) scale(x2) append save(Impact.doc)
asdoc margins, dydx(nr_attended) atmeans append save(Impact.doc)

*USING MODEL WITH INTERACTION TERM
*NOTE: IN THIS MODEL WE CANNOT ESTIMATE THE TREATMENT AND NR ATTENDED VARIABLES MAIN EFFECTS AS THEY ARE PERFECTLY COLLINEAR WITH THE INTERACTION TERM
*IN FACT TREAT = 0 PERFECTLY PREDICTS THE VALUE OF THE INTERACTION FOR THE NON-TREATED, WHILE NR ATTENDED PERFECTLY PREDICTS THE VALUE OF THE INTERACTION FOR THE TREATED.
*WE NOTE THAT THE RESULTS OF THIS MODEL ARE COMPARABLE TO THE RESULTS ABOVE ONLY ON THE TREATED GROUP.

*OLS regression
reg sdq_2 i.treat#c.nr_attended sdq_1 b2.LA i.age_strat, r 

*Logit
logit school_moves_incl_binary i.treat#c.nr_attended b2.LA age_strat, r 

*Poisson
glm nr_placement_changes i.treat#c.nr_attended b2.LA age_strat, scale(x2) family(poisson)

**********************************************COMPLIER AVERAGE CAUSAL EFFECTS***********************
*USING BLOOM'S (2006) FORMULA

*SDQ 2
reg sdq_2 i.treat sdq_1 b2.LA i.age_strat, r
su complier if treat == 1 & e(sample)
asdoc lincom  _b[1.treat] /`r(mean)', append save(Impact.doc)

*School moves
logit school_moves_incl_binary i.treat b2.LA age_strat, r
margins, dydx(treat) atmeans post
su complier if treat == 1 & e(sample)
asdoc lincom  _b[1.treat] /`r(mean)', append save(Impact.doc)


*Placement changes
glm nr_placement_changes i.treat b2.LA age_strat, scale(x2) family(poisson)
margins, dydx(treat) atmeans post
su complier if treat == 1 & e(sample)
asdoc lincom  _b[1.treat] /`r(mean)', append save(Impact.doc)

capture log close


