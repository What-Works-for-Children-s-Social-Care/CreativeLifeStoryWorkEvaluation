set more off 
capture log close

global wd "FILEPATH\21-057056 _BlueCabin"

quietly do "$wd\Syntax\1_import.do"

log using "$wd\Outputs\2_Variables", text replace

*TREATMENT DUMMY
gen treat = . 
replace treat = 1 if randomisation_outcome == "Offer CLSW"
replace treat = 0 if randomisation_outcome == "Do not offer"

ta   treat randomisation_outcome, m

*TREATMENT TYPE DUMMY
gen     treat_type_d = . 
replace treat_type_d = 1 if treat_type ! = "NA"  
replace treat_type_d = 0 if treat_type == "NA"

*COMPLIER DUMMY
gen complier = .
replace complier = 1 if treat == 1   & treat_type !="NA"
replace complier = 1 if treat == 0   & treat_type =="NA"
replace complier = 0 if treat == 1   & treat_type =="NA"
replace complier = 0 if treat == 0   & treat_type !="NA"

table treat_type_d (treat complier), statistic(freq)

*ERASE SPACES FROM POSTCODE VARIABLE (Needed for merging with the IMD dataset)
replace postcode = subinstr(postcode, " ", "", .)

*REFORMATTING ALL DATES

*Date of birth
gen    dob2 = date(dob, "MDY")
format dob2 %td

drop dob
rename dob2 dob

*Date randomised
gen    date_randomised2 = date(date_randomised, "MDY")
format date_randomised2 %td

drop   date_randomised
rename date_randomised2 date_randomised

*Date LAC end 
gen    date_lac_end2 = date(date_lac_end, "MDY")
format date_lac_end2 %td

drop   date_lac_end
ren    date_lac_end2 date_lac_end

*Date of the first session
gen    date_1st_session2 = date(date_1st_session, "MDY")
format date_1st_session2 %td

drop   date_1st_session
ren    date_1st_session2 date_1st_session

*Date of endline SDQ measure
gen    sdq_2_date2 = date(sdq_2_date, "MDY")
format sdq_2_date2 %td

drop   sdq_2_date
ren    sdq_2_date2 sdq_2_date


*Note that from the protocol we expected to have only Jan / March / Feb 2022, while here we have also months in 2021 where the follow up sdq_2 was taken (112 observations have it in 2021). 


*Date of baseline SDQ measure
gen    sdq_1_date2 = date(sdq_1_date, "MDY")
format sdq_1_date2 %td

drop   sdq_1_date
ren    sdq_1_date2 sdq_1_date


*LOCAL AUTHORITY (NUMERIC)
gen LA = . 
replace LA = 1 if local_authority  == "Darlington"
replace LA = 2 if local_authority  == "Gateshead"
replace LA = 3 if local_authority  == "South Tyneside"

label define LA 1 "Darlington" 2 "Gateshead" 3 "South Tyneside"
label values LA LA


*GENDER
gen     female = .
replace female = 1 if gender == "2: Female"
replace female = 0 if gender == "1: Male"

ta female gender,m 
drop gender


*AGE
gen age = (date_randomised - dob)/365.25

gen age_group = . 
replace age_group = 1 if int(age) > = 5  & int(age) < = 7
replace age_group = 2 if int(age) > = 8  & int(age) < = 11
replace age_group = 3 if int(age) > = 12 & int(age) < = 15
replace age_group = 4 if int(age) > = 16 & int(age) < = 17
replace age_group = 5 if age == . 

*There are five children who techinically are a few months younger than 5, but they are eligible based on DoB, so we include it in the first category
replace age_group = 1 if int(age) < 5

label define age_group 1 "5-7" 2 "8-11" 3 "12-15" 4 "16-17" 5 "Unknown"
label values age_group age_group

*ETHNICITY (BINARY)
gen      white_british = 0 
replace  white_british = 1 if ethnicity == "WBRI: White British"

ta ethnicity white_british, m

*NUMBER OF RANDOMISED CHILDREN PER FAMILY
sort id_family id_child
egen family_nr = group(id_family)
by family_nr, sort: egen nr_children = count(id_child)

gen     nr_child_group = . 
replace nr_child_group = nr_children 
replace nr_child_group = 3 if nr_children > =3 

label define nr_child_group 3 "3+"
label values nr_child_group nr_child_group


*WHETHER OTHER CHILDREN IN THE FAMILY RECEIVED CLSW
*Note that I have merged unknown with "No" with Unknown / NA (15 + 7 observations respectively)

gen     clsw_received_household2 = . 

replace clsw_received_household2 = 1 if clsw_received_household == "1: Yes, at least one other looked-after child in the household received CLSW"

replace clsw_received_household2 = 2 if clsw_received_household == "2: No - other looked-after child or children did not receive CLSW"

replace clsw_received_household2 = 3 if clsw_received_household == "3: No - no other LAC in household" 

replace clsw_received_household2 = 4 if clsw_received_household == "4: Unknown" | clsw_received_household == "NA"

label def clsw_received_household2 1 "Yes, at least one LAC" 2 "No" 3 "No other LAC in household" 4 "Unknown/NA"

label values clsw_received_household2 clsw_received_household2 


*GROUPED CASE STATUS (REDUCE THE NUMBER OF GROUPS AND MAKE CATEGORICAL)
*Here I am grouping in one category all those case status categories that have less than 5% cases. 
gen grouped_case_status2 = 5 
replace grouped_case_status2 = 1 if grouped_case_status == "Foster care"
replace grouped_case_status2 = 2 if grouped_case_status == "Kinship care"
replace grouped_case_status2 = 3 if grouped_case_status == "Parent/Person with parental responsibility"
replace grouped_case_status2 = 4 if grouped_case_status == "Residential care"
replace grouped_case_status2 = 6 if grouped_case_status == "NA"

ta   grouped_case_status grouped_case_status2, m
drop grouped_case_status
ren  grouped_case_status2 grouped_case_status

capture label drop grouped_case_status
label def grouped_case_status 1 "Foster care" 2 "Kinship care" 3 "Parent/Person with parental responsibility" 4 "Residential care" 5 "Other" 6 "Missing"

label values grouped_case_status grouped_case_status

*NUMBER OF SESSIONS ATTENDED (NUMERIC)

gen      number_attended_num = number_attended
replace  number_attended_num = "." if number_attended_num == "NA"
destring number_attended_num, replace
replace  number_attended_num = 0 if number_attended_num == . & complier == 0 & treat == 1

drop number_attended
ren  number_attended_num nr_attended


*NUMBER OF SESSIONS VIRTUALLY ATTENDED (NUMERIC)

gen      number_virtually_attended_num = number_virtually_attended
replace  number_virtually_attended_num = "." if number_virtually_attended == "NA"
destring number_virtually_attended_num, replace

drop number_virtually_attended
ren  number_virtually_attended_num number_virtually_attended

*REFORMAT SDQ AS NUMERIC
forvalue i = 1/2{
gen sdq_`i'_num = sdq_`i'
replace sdq_`i'_num = "." if sdq_`i'_num == "NA"
destring sdq_`i'_num ,replace
}

drop sdq_1 sdq_2
ren  sdq_1_num sdq_1 
ren  sdq_2_num sdq_2

*TRANSFORM SDQ1 INTO CATEGORICAL - TO INCLUDE MISSINGS
gen sdq_1_cat = 0
replace sdq_1_cat = 1 if sdq_1 > = 0  & sdq_1 <  5
replace sdq_1_cat = 2 if sdq_1 > = 5  & sdq_1 <  10
replace sdq_1_cat = 3 if sdq_1 > = 10 & sdq_1 <  15
replace sdq_1_cat = 4 if sdq_1 > = 15 & sdq_1 <  20
replace sdq_1_cat = 5 if sdq_1 > = 20 & sdq_1 <  25
replace sdq_1_cat = 6 if sdq_1 > = 25 & sdq_1 ! =.  
replace sdq_1_cat = 7 if sdq_1 == . 

label def    sdq_1_cat 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 ">=25" 7 "Missing"
label values sdq_1_cat sdq_1_cat


*SDQ INFORMANT (BASELINE) AS CATEGORICAL VARIABLE
gen sdq_1_informant2 = . 
replace sdq_1_informant2 = 1 if sdq_1_informant == "1: Child or young person"
replace sdq_1_informant2 = 2 if sdq_1_informant == "2: Child or young person's social worker"
replace sdq_1_informant2 = 3 if sdq_1_informant == "3: Child or young person's foster carer"
replace sdq_1_informant2 = 4 if sdq_1_informant == "4: Other (please explain)" | sdq_1_informant == "4: Other - not clear from form role of person completing" 
replace sdq_1_informant2 = 5 if sdq_1_informant == "5: Unknown" | sdq_1_informant == "NA"


label def informant_sdq1 1 "Child / YP" 2 "Social worker" 3 "Foster carer" 4 "Other" 5 "Unknown"
label values sdq_1_informant2 informant_sdq1 

*SDQ INFORMANT (ENDLINE) AS CATEGORICAL VARIABLE
gen sdq_2_informant2 = . 
replace sdq_2_informant2 = 1 if sdq_2_informant == "2: Child or young person's social worker"
replace sdq_2_informant2 = 2 if sdq_2_informant == "3: Child or young person's foster carer"
replace sdq_2_informant2 = 3 if sdq_2_informant == "4: Other (please explain)" | sdq_2_informant == "4: Other - not clear from form role of person completing" 
replace sdq_2_informant2 = 4 if sdq_2_informant == "5: Unknown" | sdq_2_informant == "NA"


label def informant 1 "Social worker" 2 "foster carer" 3 "Other" 4 "Unknown"
label values sdq_2_informant2 informant 

*NUMBER OF PLACEMENTS AND CHANGES (NUMERIC)
gen      nr_placements_num = nr_placements
replace  nr_placements_num = "." if nr_placements_num == "NA"
destring nr_placements_num, replace

drop     nr_placements 
rename   nr_placements_num nr_placements 

gen     nincludedplacechange2 = nincludedplacechange
replace nincludedplacechange2 = "." if nincludedplacechange2 == "NA"
ren     nincludedplacechange2   nr_placement_changes

destring nr_placement_changes, replace
label var nr_placement_changes "Number of placement changes after excluding non-relevant changes"

*NUMBER OF SCHOOL AND SCHOOL MOVES (NUMERIC)
gen      nr_school_moves = number_school_moves
replace  nr_school_moves = "." if number_school_moves == "NA"
destring nr_school_moves, replace

drop     number_school_moves 


gen      nincludedschoolmove2 = nincludedschoolmove
replace  nincludedschoolmove2 = "." if nincludedschoolmove2 == "NA"
ren      nincludedschoolmove2 nr_school_moves_incl
destring nr_school_moves_incl, replace

label var nr_school_moves_incl "Number of school moves to be included"

*Transform school moves into binary variable
ta      nr_school_moves 
gen     school_moves_binary = 0 
replace school_moves_binary = 1 if nr_school_moves > 0 
replace school_moves_binary = . if nr_school_moves == .

ta      nr_school_moves_incl 
gen     school_moves_incl_binary = 0 
replace school_moves_incl_binary = 1 if nr_school_moves_incl > 0 
replace school_moves_incl_binary = . if nr_school_moves_incl == .

capture log close