*Importing and labelling variables in preparation for analysis

set more off
capture log close
global wd "FILEPATH"
import excel "$wd\Data\Merged_for Stata import.xlsx", sheet("Merged_for Stata import") firstrow case(lower) clear


*Labelling variables
label var local_authority                 "Local Authority (provided by Coram)"
label var date_randomised                 "Date of randomiseation (provided by Coram)"
label var randomisation_outcome           "Randomisation outcome (provided by Coram)"
label var id_child                        "Child unique ID (provided by Coram)"
label var id_family                       "Family unique ID (provided by Coram)"
label var dob                             "Date of birth of child or young person"
label var gender                          "Gender"
label var ethnicity                       "Ethnic group of child or young person"
label var postcode                        "Child's postcode"
label var legal_status                    "Child or young person's legal status"
label var case_status                     "Child or young person's case status"
label var reason                          "Reason for randomisation outcome and delivery mismatch (if appl.)"
label var date_1st_session                "Date of first CLSW session (if applicable)"
label var treat_type                      "Nature of CLSW received (if applicable)"
label var number_attended                 "Number of 'all about me' sessions attended"
label var number_virtually_attended       "Of number of AAM sessions attended, nr attended online"
label var clsw_received_household         "CLSW received by other LAC in household"
label var previous_received_clsw          "South Tyneside only: previously received CLSW?"
label var sdq_1                           "First SDQ total difficulties score"
label var sdq_1_version                   "Version of first SDQ used"
label var sdq_1_date                      "Date of first SDQ total difficulties score"
label var sdq_1_informant                 "First SDQ total difficulties score informant"
label var sdq_1_id                        "First SDQ total difficulties score - unique number"
label var sdq_2                           "Second SDQ total difficulties score"
label var sdq_2_version                   "Version of second SDQ used"
label var sdq_2_date                      "Date of second SDQ total difficulties score"
label var sdq_2_informant                 "Second SDQ total difficulties score informant"
label var sdq_2_id                        "Second SDQ total difficulties score - unique number"
label var nr_placements                   "Number of placements, April 2021 to March 2022"
label var reason_placement_change_1       "Reason for placement change(s) 1"
label var reason_placement_change_2       "Reason for placement change(s) 2"
label var reason_placement_change_3       "Reason for placement change(s) 3"
label var reason_placement_change_4       "Reason for placement change(s) 4"
label var reason_placement_change_5       "Reason for placement change(s) 5"
label var number_school_moves             "Number of school moves, April 2021 to March 2022"
label var comment_school_moves_1          "Comment on reasons of school move(s) 1"
label var comment_school_moves_2          "Comment on reasons of school move(s) 2"
label var comment_school_moves_overall    "Overall comment on reasons of school move(s)"
label var comment_data_quality            "Comment on data quality (optional)"
label var sdq_1_comment                   "First SDQ comment"
label var sdq_2_comment                   "Second SDQ comment"
label var date_lac_end                    "Date LAC end"
label var date_lac_start                  "Date LAC start"
label var further_explanation             "Further explanation"
*Note: the other variables do not have a full label but their names has been imported as it is in Stata*

*The first row in the data had the labels, we can now drop it as we have labelled the data
drop in 1
 


