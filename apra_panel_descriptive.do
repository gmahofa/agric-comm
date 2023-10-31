clear
set more off, perm 
cap log close
global root "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global tmp "C:\Users\Mahofa"
global code "$root\code"
global output "$root\output"
global data "$root\data"

log using "$output\apra_panel_descriptive.txt", replace
**
use "$data\hhd_final_panel_merged", clear
keep if panel==1
drop panel hh_a_05b-hh_a_13 hh_a_25a hh_a_24a hh_a_27a hh_a_28a hh_a_31-hh_a_35a ///
hh_a_35c hh_a_36a hh_a_37a hh_a_38a outschool2 married4-married7 agri_activity2 ///
mainjob1 mainjob5-mainjob16 secondjob1 secondjob5-secondjob16 headman1 headman3 ///
headman4 headman_spouse1 headman_spouse3 headman_spouse3-chief1 chief3-mobile1 ///
mobile3-mobile_inf1 mobile_inf3 covid2 foodsale_covid2 foodstck_covid2 foodcost_covid2 ///
farmeff_covid2 workeff_covid2 contrfarm2 extension2 mkt_info2 credit2 ///
obtain_loan2 hhenter2 female_diet2 hhdtasks5 childdeath2 sum_ag_c_1a cattleind-donkeyind _merge ///
cattle_owned goats_owned sheep_owned pigs_owned poultry_owned donkey_owned ag_c_1a_units ag_c_4a_units ///
sum_ag_c_16other-sum_ag_c_18other output14 output21 prod_value hh_a_37c hh_a_36c hh_a_28c_oth hh_f_8b

*To create descriptive statistics of variables by year
g round="."
replace round="round1" if year==2018
replace round="round2" if year==2020
drop year
encode round, g(_round)
drop round
ren _round round
order round, after(HHID)
lab def round 1 "round1" 2 "round2"
lab val round round
*to run the following commands: one has to have an ado file for ttst1 and table1
qui ttst1 round 1 2, newvars(Y) temp($tmp\) 
table1 round using $tmp\, id(HHID) order

*labels
do "$code\labels.do"
export excel using "$output\apradescriptive_1.xls", firstrow(variables) replace
****
exit



