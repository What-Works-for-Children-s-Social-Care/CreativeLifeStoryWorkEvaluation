set more off
capture log close 
global wd "FILEPATH\21-057056 _BlueCabin"

*Import file with IMD scores by LSOA
import excel "$wd\Data\File_5_-_IoD2019_Scores.xlsx", sheet("Sheet1") firstrow clear
drop if lsoa11cd == ""
save "FILEPATH\21-057056 _BlueCabin\Data\imd_lsoa.dta", replace

*Import file with postcode LSOA lookup
import delimited "$wd\Data\PCD_OA_LSOA_MSOA_LAD_FEB20_UK_LU.csv", clear
keep pcd7 pcd8 pcds lsoa11cd lsoa11nm
save "$wd\Data\pcd_lsoa_lookup.dta", replace

*merge with file with IMD scores
merge m:1 lsoa11cd using "$wd\Data\imd_lsoa.dta"

keep if _merge == 3
drop _merge

replace pcd7 = subinstr(pcd7, " ", "", .)
replace pcd8 = subinstr(pcd8, " ", "", .)
replace pcds = subinstr(pcds, " ", "", .)

keep pcd7 imd_score
rename pcd7 postcode

save  "$wd\Data\imd_lsoa_postcode.dta", replace
