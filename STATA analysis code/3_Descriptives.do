set more off
capture log close 

global wd "FILEPATH\21-057056 _BlueCabin"

quietly do "$wd\Syntax\2_Variables.do"

log using  "$wd\Outputs\3_Descriptives", text replace

*Total number of children in the trial by local authority
ta local_authority

*Treatment status
tab treat 

*Treatment status by LA
ta treat LA

*Compliance with treatment assignment in the two groups
ta complier treat 

************************************************************************
*DESCRIPTIVES ONLY ON ELIGIBLE SAMPLE
*************************************************************************
keep if ineligible == "NA"

tab treat
ta complier treat

*Treatment status
tab treat 

*Treatment status by LA
ta treat LA

*AGE
su age, d
ta age_group

table treat, stat(mean age)
table treat LA, stat(mean age)

*GENDER 
ta female
table treat, stat(mean female)
table treat LA, stat(mean female)

*ETHNICITY
ta ethnicity
ta white_british

table treat, stat(mean white_british)
table treat LA, stat(mean white_british)

*NUMBER OF FAMILIES AND CHIDREN WITHIN FAMILIES
codebook family_nr

su nr_children
table treat LA, stat(mean nr_children)

*OTHER CHILDREN RECEIVED CLSW
tab clsw_received_household2
tab clsw_received_household2 treat, column
table clsw_received_household2 LA treat


*GROUPED CASE STATUS
ta grouped_case_status, m
tab grouped_case_status treat, chi column
table (grouped_case_status) (LA) (treat)

*NUMBER OF SESSIONS ATTENDED BY THOSE WHO COMPLIED (offered the intervention and took it)
su nr_attended    if    treat == 1 & complier == 1
ta nr_attended LA if    treat == 1 & complier == 1
gen nr_attended_group = . 
replace nr_attended_group = 1 if nr_attended > = 1 & nr_attended < = 6  
replace nr_attended_group = 2 if nr_attended > 6 & nr_attended <=7
ta nr_attended_group LA if treat == 1 & complier == 1 

capture drop nr_attended_group
clonevar nr_attended_group = nr_attended
recode nr_attended_group (3 4 = 4)
label define nr_attended_group 1 "1" 2 "2" 4 "3 or 4" 5 "5" 6 "6" 7 "7", modify
label values nr_attended_group nr_attended_group

hist nr_attended_group  if    treat == 1 & complier == 1, freq graphregion(color(white)) xtitle("Number of sessions attended") ytitle("Number of children and young people", margin(medium)) xlabel(1 2 4 5 6 7, valuelabel) ylabel(none) addlabels
graph export "$wd\Outputs\Hist_Nr_Sessions.png", replace



*HOW MANY FAMILIES WITH SOME CHILDREN RANDOMISED TO TREATMENT AND SOME NOT
gen    took_intervention = 0 
replace took_intervention = 1 if treat_type !="NA" 


preserve
collapse (mean) nr_children (sum) treat (sum) took_intervention, by(id_family) 
ta treat nr_children, cell
ta treat nr_children if took_intervention !=0, cell
restore

*SDQ
count if sdq_1 == .
count if sdq_1 !=. 
count if sdq_2 == .
count if sdq_2 !=.  
count if sdq_1 !=. & sdq_2 !=.
count if sdq_1 == .& sdq_2 == . 
codebook sdq_1
codebook sdq_2
su sdq_1, d
su sdq_2, d

*SDQ 1
table treat,    stat(mean sdq_1)
table treat LA, stat(mean sdq_1)

ta sdq_1_date
gen year_sdq_1 = year(sdq_1_date)
ta year_sdq_1

table LA, stat(mean sdq_1)


*SDQ 2
table treat,    stat(mean sdq_2)
table treat LA, stat(mean sdq_2)

table LA, stat(mean sdq_2)

ta sdq_2_date
gen year_sdq_2 = year(sdq_2_date)
ta year_sdq_2

*note that 32 cases have missing sdq at baseline and follow up (17 treatment group, 15 control group)
*This will reduce the sample size of the analysis on SDQ
ta treat if sdq_1 == . & sdq_2 == . 

*SDQ 1 INFORMANT (1: child, 2: social worker,3 : parent / carer, 4: other, 5: unknown)
tab sdq_1_informant2 treat
table treat sdq_1_informant2 LA 

*SDQ 2 INFORMANT (1: social worker 2: parent / carer, 3: other, 4: unknown)
tab sdq_2_informant2 treat
table treat sdq_2_informant2 LA 

twoway (scatter sdq_2 sdq_1, mcolor("black") mfcolor("none")) (lfit sdq_2 sdq_1, lcolor("black") lwidth(medium)), xtitle("Baseline SDQ score") ytitle("Endline SDQ score") graphregion(color("white")) legend(label (1 "Actual SDQ scores")) xlabel(0(10)33) ylabel(0(10)36) note("Fitted line: SDQ_2 =9.40+0.57*SDQ_1, R-squared: 0.280")
graph export "$wd\Outputs\Scatter_SDQ.png", replace

*Check distribution of SDQ2 in South Tyneside
hist sdq_2 if local_authority == "South Tyneside"

*NUMBER OF PLACEMENTS
ta       nr_placement_changes
ta       nr_placement_changes if nr_placement_changes ! = 0 

codebook nr_placement_changes
su       nr_placement_changes, d

table treat,    stat(mean nr_placement_changes)
table treat LA, stat(mean nr_placement_changes)

*NUMBER OF SCHOOL MOVES
ta nr_school_moves_incl
codebook nr_school_moves_incl
su       nr_school_moves_incl

table treat,    stat(mean nr_school_moves_incl)
table treat LA, stat(mean nr_school_moves_incl)


*OTHER DESCRIPTIVE INFORMATION
*There seems to be x children for whom the date of the follow up sdq is earlier than the date randomised.
count if date_randomised > sdq_2_date & date_randomised !=.

*There seems to be y children for whom the date of the follow up sdq is earlier than the date of the intervention.
count if date_1st_session > sdq_2_date & date_1st_session !=.

*There are no children for whom the date of the baseline sdq is after the date of the first session. 
count if sdq_1_date > date_1st_session & sdq_1_date !=.

capture log close