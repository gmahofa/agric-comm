********************************************************************************
*Do File for loading and preparing for cleaning and preparing APRA data  
*Household Roster and other activities APRA Project
********************************************************************************

clear
set more off, perm 
global root  "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global rawdata "$root\rawdata\APRA_ZIM_2018_3_STATA_ALL"
global tmp "C:\Users\Mahofa"
global code "$root\code"
global output "$root\output"
global data "$root\data"
***
use "$rawdata\hhroster", clear
order interview__id interview__key
tab hh_a_14, g(gender)
ren (gender1 gender2) (male female)
inspect hh_a_15  /*age */
sum hh_a_15, d
ren hh_a_15 age
inspect hh_a_15_months

tab hh_a_16, mi /*relationship to head*/
tab hh_a_16, g(head)
inspect hh_a_17 /*months lived in the houshold in the last 12 years*/
sum hh_a_17, d
tab hh_a_18, mi  /*marital status */
tab hh_a_18, g(married)

inspect hh_a_19 /*years of schooling*/
sum hh_a_19, d

tab hh_a_20, mi /*work on hhd agricultural activities*/
tab hh_a_20, g(agri_activity)
tab hh_a_21, mi /*mainoccupation*/
tab hh_a_21, g(mainjob)

tab hh_a_22, mi /*second occupation*/
tab hh_a_22, g(secondjob)
tab hh_a_23, mi
tab hh_a_23, g(outschool)

inspect hh_f_5  /*individuals all care work*/
sum hh_f_5, d
ren hh_f_5 unpd_cre
lab var unpd_cre "All care work"
inspect hh_f_6a-hh_f_6d
sum hh_f_6a-hh_f_6d
ren (hh_f_6a-hh_f_6d) (cooking chdn_care cllt_fire cllct_wter)
lab var cooking "Cooking/preparing meals"
lab var chdn_care "Taking care of young children"
lab var cllt_fire "Collecting firewood"
lab var cllct_wter "Collecting water"
**
*Household composition variables including hhd size
byso interview__id:egen hhdsize = count(hhroster__id)
lab var hhdsize "Household size"
byso interview__id: egen chdn = total(age <= 14) /*total number of chdn*/
lab var chdn "Number of children 0-14"
byso interview__id: egen nofemale = total(age <= 14&female ==1) /*female children less than 14*/
lab var nofemale "Number of female children below the age of 14"
byso interview__id: egen nomale = total(age <= 14&male ==1) /*male children less than 14*/
lab var nomale "Number of male children below the age of 14"
byso interview__id: egen youth = total(inrange(age, 15,34)) 
lab var youth "Number of youth 15-34"
byso interview__id: egen youthmale = total(inrange(age, 15,34) & male == 1)
lab var  youthmale "Number of male youth 15-34"
byso interview__id: egen youthfmale = total(inrange(age, 15,34) & female == 1) 
lab var  youthfmale "Number of female youth 15-34"
byso interview__id: egen adult = total(inrange(age, 35,60)) 
lab var adult "Number of adults 35-60"
byso interview__id: egen adultmale = total(inrange(age, 35,60) & male == 1) /* adult male between 35 and 60*/
lab var adultmale "Adult male aged between 35 and 60"
byso interview__id: egen adultfemale = total(inrange(age, 35,60) & female == 1) /* adult female between 35 and 60*/
lab var adultfemale "Adult female aged between 35 and 60"
byso interview__id: egen old = total(age > 60& age != .) 
lab var old "Number of elders"
byso interview__id: egen oldfemale = total(age > 60 & female == 1 & age != .) /* old female between 35 and 60*/
lab var oldfemale "Number of female members aged 60 and above"
byso interview__id: egen oldmale = total(age > 60 & male == 1 & age != .) /* old female between 15 and 60*/
lab var oldmale "Number of male members aged 60 and above"

drop hh_a_14
/*preserve
keep interview__id hhroster__id head1
so interview__id
save tmp, replace
restore
so interview__id */
keep if head1 == 1
/*mer 1:m interview__id using tmp
keep if _mer==2*/
keep interview__id interview__key age hh_a_19 hh_a_23-cllct_wter male female married3 married4 mainjob2 ///
mainjob3 mainjob4 outschool1 hhdsize-oldmale
so interview__id
save "$data\hhd_demographics", replace
****
*Opening Plot roster data
use "$rawdata\ag_b_parcel_roster", clear
isid interview__id  ag_b_parcel_roster__id 
so interview__id  ag_b_parcel_roster__id
order interview__id
ren ag_b_parcel_roster__id parcel_id
d
inspect ag_b_05a /*distance to parcel in km*/
sum ag_b_05a, d
graph box ag_b_05a /*outliers with distances more than 100 up to 500km*/
ren ag_b_05a distparc
lab var distparc "Distance to parcel in km"
inspect ag_b_05b
sum ag_b_05b, d
graph box ag_b_05b /*outliers*/
winsor2 ag_b_05b if ag_b_05b!=. , replace cuts(10 90)
ren ag_b_05b dist_parchr
lab var dist_parchr "Distance to parcel in hours"
**
*How was parcel acquired
numlabel ag_b_06, add
tab ag_b_06
recode ag_b_06 (2/5 = 1) (6/90 = 0) (-9 = .), g(Govt)
table ag_b_06 Govt
lab var Govt "State allocation"
recode ag_b_06 (1/5 11/90 = 0) (6/8 = 1) (-9 = .), g(inher)
table ag_b_06 inher
lab var inher "Inheritance"
recode ag_b_06 (1/11 90 = 0) (12/14 = 1) (-9 = .), g(Mkt)
table ag_b_06 Mkt
lab var Mkt "Market transactions"
recode ag_b_06 (1/8 12/90 = 0) (11 = 1) (-9 = .), g(other)
table ag_b_06 other 
label var other "Other transactions"
recode ag_b_06 (1/5 = 0) (6/8 = 1) (12/14 = 2) (11 = 3) (-9 90 = .), g(Ltrn)
table ag_b_06 Ltrn
lab val  Ltrn Ltrn
lab def Ltrn 0 "Govt" 1 "Inher" 2 "Mkt" 3 "Other"
lab var Ltrn "Land transactions"
**
numlabel ag_b_07a, add
tab ag_b_07a
recode ag_b_07a (2/4 = 0) (-9 90 = .), g(regis)
table ag_b_07a regis
lab var regis "Parcel is registered"
drop ag_b_06-ag_b_08
isid interview__id parcel_id
so interview__id parcel_id
save "$data\parcelroster", replace
***
*Plot roster data
use "$rawdata\ag_b_2_plot_roster", clear
isid interview__id ag_b_2_plot_roster__id /*variables identifying the dataset*/
order interview__id ag_b_2_plot_roster__id
so interview__id ag_b_2_plot_roster__id
order plot_parcel ag_b_01 ag_b_02, before(ag_b_12)
**
*Recoding variable linking plots to parcels-parcels are coded 1 to 5 in parcel roster
*but 0 to 4 in plots roster
destring plot_parcel, replace
recode plot_parcel (4 = 5) (3 = 4) (2 = 3) (1 = 2) (0 = 1) 
**
*Plot type:how is the plot used
inspect ag_b_03*
for var ag_b_03*: tab X
egen ptype = rowtotal(ag_b_03__*)
tab ptype
tab ag_b_03__2 if ptype == 2
tab ag_b_03__3 if ptype == 2 /* this is okay*/
tab ag_b_03__2
tab ag_b_03__3
**
*Area
inspect ag_b_04a
sum ag_b_04a, d
numlabel ag_b_04b, add
tab ag_b_04b
*Convert all areas to hectares
replace ag_b_04a = ag_b_04a/10000 if ag_b_04b == 3
replace ag_b_04a = ag_b_04a/2.471 if ag_b_04b == 1
ren ag_b_04a area
lab var area "Plot area in hectares"
sum area
graph box area
**
*Rental value
inspect ag_b_11a
sum ag_b_11a, d
graph box ag_b_11a
ren ag_b_11a rent
lab var rent "Rental values"
keep interview__id ag_b_2_plot_roster__id plot_parcel ag_b_03__* area rent
ren (ag_b_03__2 ag_b_03__3) (rent_in rent_out)
lab var rent_in "Rented in land"
lab var rent_out "Rented out land"
**
byso interview__id: egen land_own = total(area)
lab var land_own "Total area owned"
sum land_own, d
g rentin_area = area if rent_in == 1
g rentot_area = area if rent_out == 1
replace rentin_area = 0 if rentin_area == .
replace rentot_area =  0 if rentot_area == .
for var rentin_area rentot_area: byso interview__id: egen X_1 = total(X)
for var rentin_area rentot_area:drop X
ren (rentin_area_1 rentot_area_1) (rentin_area rentot_area)
lab var rentin_area "Area rented in in ha"
lab var rentot_area "Area rented out in ha"
drop ag_b_03__1 ag_b_03__4-ag_b_03__12
ren plot_parcel parcel_id
order parcel_id, before(ag_b_2_plot_roster__id)
ren ag_b_2_plot_roster__id plotroster_id
byso interview__id: egen rentin = total(rent_in)
byso interview__id: egen rentot = total(rent_out)
drop rent_in rent_out
ren (rentin rentot) (rent_in rent_out)
for var rent_in rent_out: replace X = 1 if X >0
drop plotroster_id area rent
duplicates drop interview__id parcel_id, force
so interview__id parcel_id
mer m:m interview__id parcel_id using "$data\parcelroster"
keep if _mer==3
drop _mer
save "$data\hhd_parcel", replace
**
keep interview__id land_own rentin_area rentot_area rent_in rent_out
duplicates drop 
order rent_in rent_out rentin_area rentot_area, before(land_own)
winsor2 land_own if land_own!=. , replace cuts(5 95)
g rentmkt= rent_in+rent_out
lab var rentmkt "Participation in rental market"
save "$data\hhd_rentmkt", replace
***
*Commercialisation index
use "$rawdata\hci collapsed", clear
so interview__id
mer 1:1 interview__id using "$data\hhd_rentmkt"
drop _mer
mer 1:1 interview__id using "$data\hhd_demographics"
drop _mer
save "$rawdata\hhdrent_tomer", replace
**
use "$rawdata\Activity", clear
order interview__id interview__key ag_b_2_plot_roster__id
drop ag_b_20__3-ag_b_20__14 ag_b_20__1 ag_b_20__2 interview__key
egen _id = group(interview__id ag_b_2_plot_roster__id)
order _id
reshape wide ag_b_20__0 ag_b_20_days, i(_id) j(Activity__id)
order interview__id 
drop ag_b_2_plot_roster__id ag_b_2_plot_roster__id
so interview__id
save tmp1, replace
**
*HHD roster
use "$rawdata\hhroster", clear
keep if hh_a_15>=15
keep hhroster__id hh_a_14 interview__id
order interview__id
so interview__id hhroster__id
save tmp2, replace
**
use tmp1, clear
keep interview__id ag_b_20__01 ag_b_20_days1 
ren (ag_b_20__01 ag_b_20_days1) (hhroster__id ag_b_20_lndppdys)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
lab var hhroster__id "Hhd member responsible for land preparation & planting"
lab var ag_b_20_lndppdys "Total days worked on land preparation & planting"
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
order ag_b_20_lndppdys, after(hh_a_14)
collapse (sum) ag_b_20_lndppdys, by(interview__id hh_a_14)
reshape wide ag_b_20_lndppdys, i(interview__id) j(hh_a_14)
ren (ag_b_20_lndppdys1 ag_b_20_lndppdys2) (lndppmale lndppfmale)
lab var lndppmale "Male total days worked on land preparation & planting"
lab var lndppfmale "Female total days worked on land preparation & planting"
so interview__id
save "$data\landpp", replace
**
use tmp1, clear
keep interview__id ag_b_20__02 ag_b_20_days2
ren (ag_b_20__02 ag_b_20_days2) (hhroster__id ag_b_nsm)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) ag_b_nsm, by(interview__id hh_a_14)
reshape wide ag_b_nsm, i(interview__id) j(hh_a_14)
lab var ag_b_nsm1 "Male total days worked on nursery & seedbed mmgt"
lab var ag_b_nsm2 "Female total days worked on nursery & seedbed mmgt"
so interview__id
save "$data\nursery", replace
**
use tmp1, clear
keep interview__id ag_b_20__03 ag_b_20_days3
ren (ag_b_20__03 ag_b_20_days3) (hhroster__id ag_b_ird)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) ag_b_ird, by(interview__id hh_a_14)
reshape wide ag_b_ird, i(interview__id) j(hh_a_14)
lab var ag_b_ird1 "Male total days worked in irrigation and drainage"
lab var ag_b_ird2 "Female total days worked in irrigation and drainage"
so interview__id
save "$data\irr_dra", replace
**
use tmp1, clear
keep interview__id ag_b_20__04 ag_b_20_days4
ren (ag_b_20__04 ag_b_20_days4) (hhroster__id weeding)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) weeding, by(interview__id hh_a_14)
reshape wide weeding, i(interview__id) j(hh_a_14)
lab var weeding1 "Male total days worked weeding"
lab var weeding2 "Female total days worked weeding"
so interview__id
save "$data\weeding", replace
**
use tmp1, clear
keep interview__id ag_b_20__05 ag_b_20_days5
ren (ag_b_20__05 ag_b_20_days5) (hhroster__id app_fert)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) app_fert, by(interview__id hh_a_14)
reshape wide app_fert, i(interview__id) j(hh_a_14)
lab var app_fert1 "Male total days worked on applying fert"
lab var app_fert2 "Female total days worked on applying fer"
so interview__id
save "$data\app_fert", replace
**
use tmp1, clear
keep interview__id ag_b_20__06 ag_b_20_days6
ren (ag_b_20__06 ag_b_20_days6) (hhroster__id app_chem)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) app_chem, by(interview__id hh_a_14)
reshape wide app_chem, i(interview__id) j(hh_a_14)
lab var app_chem1 "Male total days worked on applying agrochem"
lab var app_chem2 "Female total days worked on applying agrochem"
so interview__id
save "$data\app_agrochem", replace
**
use tmp1, clear
keep interview__id ag_b_20__07 ag_b_20_days7
ren (ag_b_20__07 ag_b_20_days7) (hhroster__id harve)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) harve, by(interview__id hh_a_14)
reshape wide harve, i(interview__id) j(hh_a_14)
lab var harve1 "Male total days worked on harvesting"
lab var harve2 "Female total days worked on harvesting"
so interview__id
save "$data\harvesting", replace
**
use tmp1, clear
keep interview__id ag_b_20__08 ag_b_20_days8
ren (ag_b_20__08 ag_b_20_days8) (hhroster__id curing)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) curing, by(interview__id hh_a_14)
reshape wide curing, i(interview__id) j(hh_a_14)
lab var curing1 "Male total days worked curing"
lab var curing2 "Female total days worked curing"
so interview__id
save "$data\curing", replace
**
use tmp1, clear
keep interview__id ag_b_20__010 ag_b_20_days10
ren (ag_b_20__010 ag_b_20_days10) (hhroster__id grading)
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer hhroster__id
collapse (sum) grading, by(interview__id hh_a_14)
reshape wide grading, i(interview__id) j(hh_a_14)
lab var grading1 "Male total days worked on grading & packaging"
lab var grading2 "Female total days worked on grading & packagin"
so interview__id
save "$data\grading", replace
**
use "$data\landpp", clear
mer 1:1 interview__id using "$data\nursery"
drop _mer
mer 1:1 interview__id using "$data\irr_dra"
drop _mer
mer 1:1 interview__id using "$data\weeding"
drop _mer
mer 1:1 interview__id using "$data\app_fert"
drop _mer
mer 1:1 interview__id using "$data\app_agrochem"
drop _mer
mer 1:1 interview__id using "$data\harvesting"
drop _mer
mer 1:1 interview__id using "$data\curing"
drop _mer
mer 1:1 interview__id using "$data\grading"
drop _mer
so interview__id
save "$data\activ_gender", replace
**
use "$rawdata\Additional_Inputs", clear
order interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id ///
Additional_Inputs__id
egen _id = group(interview__id ag_b_2_plot_roster__id crop_roster_sale__id)
order _id
reshape wide ag_b_30d-ag_b_30g__5, i(_id) j(Additional_Inputs__id)
order interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id
save tmp3, replace
keep interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id ///
_id ag_b_30e1 ag_b_30e2 ag_b_30e3 ag_b_30e4
tostring ag_b_30e1, g (catt)
tostring ag_b_30e2, g (catt1)
tostring ag_b_30e3, g (catt2)
tostring ag_b_30e4, g (catt3)
save tmp4, replace
keep interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id _id ag_b_30e1 catt
order catt, before(ag_b_30e1)
destring catt, replace
drop if catt == .
reshape wide ag_b_30e1, i(_id) j(catt)
order interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id
keep _id interview__id ag_b_30e11-ag_b_30e14
ren (ag_b_30e11 ag_b_30e12 ag_b_30e13 ag_b_30e14) (herb_agro herb_contr herb_gvt herb_ret)
so _id 
save "$data\herb", replace
**
use tmp4, clear
keep interview__id _id ag_b_30e2 catt1
destring catt1, replace
drop if catt1 == .
drop if catt1 == .a
reshape wide ag_b_30e2, i(_id) j(catt1)
order interview__id
ren (ag_b_30e21 ag_b_30e22 ag_b_30e23 ag_b_30e24) (pest_agro pest_contr pest_gvt pest_ret)
so _id
save "$data\pest", replace
**
use tmp4, clear
keep interview__id _id ag_b_30e4 catt3
destring catt3, replace
drop if catt3 == .
drop if catt3 == .a
reshape wide ag_b_30e4, i(_id) j(catt3)
order interview__id
ren (ag_b_30e41 ag_b_30e43 ag_b_30e44) (irr_agro irr_gvt irr_rt)
so _id
save "$data\irri", replace
**
use "$data\herb", clear
mer 1:1 _id using "$data\pest"
drop _mer
mer 1:1 _id using "$data\irri"
drop _mer _id
duplicates drop interview__id, force
so interview__id
save "$data\addinp", replace
**
use tmp3, clear
keep interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id ///
_id ag_b_30d1 ag_b_30d2 ag_b_30d3 ag_b_30d4
collapse (sum) ag_b_30d1-ag_b_30d4, by(interview__id)
ren (ag_b_30d1 ag_b_30d2 ag_b_30d3 ag_b_30d4) (herbcost pestcost tcuringcost irrcost)
so interview__id
mer 1:1 interview__id using "$data\addinp"
drop _mer
for var herb_agro-irr_rt: replace X = 0 if X == .
save "$data\hhd_addinp", replace
**
use "$rawdata\Agri_services", clear
order interview__id interview__key
tab hh_a_30a, g(mode)
drop hh_a_30a
reshape wide hh_a_29b-mode5, i(interview__id) j(Agri_services__id)
ren (hh_a_29b1 hh_a_29b2 hh_a_29b3 hh_a_29b4 hh_a_29b5 hh_a_29b6 hh_a_29b7 ///
hh_a_29b8 hh_a_29b9 hh_a_29b10 hh_a_29b13) (dist_trd dist_wrd dist_frd dist_agd dist_mkp ///
dist_lmkt dist_ext dist_vet dist_ais dist_till dist_villcentr)
**
lab var dist_trd "Distance to tarmac"
lab var dist_wrd "Distance to all weather road"
lab var dist_frd "Distance to feeder road"
lab var dist_agd "Distance to agro-dealers"
lab var dist_mkp "Distance to established market place"
lab var dist_lmkt "Distance to livestock market"
lab var dist_ext "Distance to agricultural exetension services"
lab var dist_vet "Distance to vet"
lab var dist_ais "Distance to artificial insemination services"
lab var dist_till "Distance to tillage services"
lab var dist_villcentr "Distance to village centre"
**
ren (hh_a_30b1 hh_a_30b2 hh_a_30b3 hh_a_30b4 hh_a_30b5 hh_a_30b6 hh_a_30b7 ///
hh_a_30b8 hh_a_30b9 hh_a_30b10 hh_a_30b13) (tim_trd tim_wrd tim_frd tim_agd ///
tim_mkp tim_lmkt tim_ext tim_vet tim_ais tim_till tim_villcentr)
lab var tim_trd "Time to tarmac road in hours"
lab var tim_wrd "Time to all weather road in hours"
lab var tim_frd "Time to feeder road in hours"
lab var tim_agd "Time to agro-dealers in hours"
lab var tim_mkp "Time to established market place in hours"
lab var tim_lmkt "Time to livestock market in hours"
lab var tim_ext "Time to agricultural exetension services in hours"
lab var tim_vet "Time to vet in hours"
lab var tim_ais "Time to artificial insemination services in hours"
lab var tim_till "Time to tillage services in hours"
lab var tim_villcentr "Time to village centre in hours"
**
lab var mode11 "Walking to tarmarc road"
lab var mode21 "Bike to tarmac road"
lab var mode31 "Oxcart to tarmac road"
lab var mode41 "Canoe to tarmac road"
lab var mode51  "Motor to tarmac road"
**
lab var mode12 "Walking to all wether road"
lab var mode22 "Bike to all wether road"
lab var mode32 "Oxcart to all wether road"
lab var mode42 "Canoe to all wether road"
lab var mode52 "Motor to all wether road"
**
lab var mode13 "Walking to feeder road"
lab var mode23 "Bike to feeder road"
lab var mode33 "Oxcart to feeder road"
lab var mode43 "Canoe to feeder road"
lab var mode53 "Motor to feeder road"
**
lab var mode14 "Walking to agro-dealers"
lab var mode24 "Bike to agro-dealers"
lab var mode34 "Oxcart to agro-dealers"
lab var mode44 "Canoe to agro-dealers"
lab var mode54 "Motor to agro-dealers"
**
lab var mode15 "Walking to market place"
lab var mode25 "Bike to market place"
lab var mode35 "Oxcart to market place"
lab var mode45 "Canoe to market place"
lab var mode55 "Motor to market place"
**
lab var mode16 "Walking to livestock market place"
lab var mode26 "Bike to livestock market place"
lab var mode36 "Oxcart to livestock market place"
lab var mode46 "Canoe to livestock market place"
lab var mode56 "Motor to livestock market place"
**
lab var mode17 "Walking to extension offices"
lab var mode27 "Bike to extension offices"
lab var mode37 "Oxcart to extension offices"
lab var mode47 "Canoe to extension offices"
lab var mode57 "Motor to extension offices"
**
lab var mode18 "Walking to veterinary clinic"
lab var mode28 "Bike to veterinary clinic"
lab var mode38 "Oxcart to veterinary clinic"
lab var mode48 "Canoe to veterinary clinic"
lab var mode58 "Motor to veterinary clinic"
**
lab var mode19 "Walking to artificial insemination services"
lab var mode29 "Bike to artificial insemination services"
lab var mode39 "Oxcart to artificial insemination services"
lab var mode49 "Canoe to artificial insemination services"
lab var mode59 "Motor to artificial insemination services"
**
lab var mode110 "Walking to tillage services"
lab var mode210 "Bike to tillage services"
lab var mode310 "Oxcart to tillage services"
lab var mode410 "Canoe to tillage services"
lab var mode510 "Motor to tillage services"
**
lab var mode113 "Walking to village centre"
lab var mode213 "Bike to village centre"
lab var mode313 "Oxcart to village centre"
lab var mode413 "Canoe to village centre"
lab var mode513 "Motor to village centre"
drop interview__key
so interview__id
save "$data\hhd_services", replace
**
use "$rawdata\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1", clear
inspect hh_a_24
sum hh_a_24, d
winsor2 hh_a_24 if hh_a_24!=., replace cuts(12 88)
ren hh_a_24 no_trder
**
inspect hh_a_25a
tab hh_a_25a, mi
tab hh_a_25a, g(headman_rel)
drop hh_a_25a
**
inspect hh_a_25b__1
tab hh_a_25b__1, mi
**
tab hh_a_26a, mi
tab hh_a_26a, g(hdmansp_rel)
**
tab hh_a_27a, g(chiefrel)
for var hh_a_27b__*: tab X
**
inspect hh_a_28a
tab hh_a_28a, mi 
tab hh_a_28a, g(mobile_money)
**
for var hh_a_28b__*: tab X 
drop hh_a_28b__1-hh_a_28b__14
preserve
keep interview__id hh_a_28b__0
drop if hh_a_28b__0 == ""
ren hh_a_28b__0 hhroster__id
destring hhroster__id, replace
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3 
drop _mer hhroster__id
ren hh_a_14 hh_a_28b
lab var hh_a_28b "Gender of hhd member using mobile money services
so interview__id 
save "$data\mobile_services", replace
restore
**
drop hh_a_28b__0
mer 1:1 interview__id using "$data\mobile_services"
drop _mer
**
for var hh_a_28c__*: tab X, mi
inspect hh_a_28d
sum hh_a_28d, d
for var hh_a_28c__*: tab X, mi
tab hh_a_28e, g(mbmney_inf)
for var hh_a_29a__*: tab X, mi
for var ag_d_1a__*: tab X, mi
**
tab hh_z_1a , mi
tab hh_z_1a, g(cont_farming)
tab hh_z_1b, mi
tab hh_z_1b, g(ext)
inspect hh_z_2
sum hh_z_2, d
winsor2 hh_z_2 if hh_z_2!=., replace cuts(5 95)
for var hh_z_3__*: tab X, mi
**
sum hh_z_5b, d
winsor2 hh_z_5b if hh_z_5b!=., replace cuts(10 90)
**
tab hh_z_6a, mi
tab hh_z_6a, g(minfo)
for var hh_z_6b__*: tab X, mi
**
tab hh_z_7a, mi
tab hh_z_7a, g(credit)
**
tab hh_z_7b, mi
tab hh_z_7b, g(getloan)
inspect hh_z_7c
sum hh_z_7c, d
**
for var hh_z_7d__*: tab X
for var hh_z_7e__*:tab X
**
*Income
for var income_source__*: tab X, mi
for var hh_e_1a__*: tab X, mi
**
*Household Enterprises
tab hh_e_14, mi
for var hh_e_15__*: tab X, mi
drop hh_e_15__*
for var hh_e_19a__*: tab X, mi
**
*other sources of income
for var hh_e_19b1__*: tab X, mi
drop hh_e_19b1__1-hh_e_19b1__14
preserve
keep interview__id hh_e_19b1__0
drop if hh_e_19b1__0 == ""
ren hh_e_19b1__0 hhroster__id
destring hhroster__id, replace
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3 
drop _mer hhroster__id
ren hh_a_14 hh_e_19b1__0
lab var hh_e_19b1__0 "Gender of member receiving other incomes"
so interview__id
save "$data\otherinc", replace
restore
drop hh_e_19b1__0
mer 1:1 interview__id using "$data\otherinc"
drop _mer
**
inspect hh_e_20_1
sum hh_e_20_1, d
ren hh_e_20_1 other_inc
inspect hh_e_21a1
sum hh_e_21a1, d
for var hh_e_21b1__*: tab X, mi
for var hh_e_21c1__*: tab X, mi
drop hh_e_21c1__*
drop hh_e_19b2__1-hh_e_19b2__14
preserve
keep interview__id hh_e_19b2__0
ren hh_e_19b2__0 hhroster__id
destring hhroster__id, replace
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3 
drop _mer hhroster__id
ren hh_a_14 hh_e_19b2__0
lab var hh_e_19b2__0 "Gender of member who received gift income"
save "$data\gifts", replace
restore
**
drop hh_e_19b2__0
mer 1:1 interview__id using "$data\gifts"
drop _mer
inspect hh_e_20_2
sum hh_e_20_2, d
inspect hh_e_21a2
sum hh_e_21a2
**
for var hh_e_21b2__*: tab X, mi
drop hh_e_21c2__1-hh_e_21c2__12
sum hh_e_22_2, d
winsor2 hh_e_22_2 if hh_e_22_2!=., replace cuts(10 90)
**
for var hh_e_19b3__*:tab X
for var hh_e_23a__*: tab X, mi
for var hh_e_24a__*: tab X, mi
tab hh_e_32, mi
tab hh_e_32, g(hhsstatus)
tab hh_e_33, g(hhcircum)
tab hh_e_34, g(hhdistat)
tab hh_e_35, g(hhdwbeing)
tab hh_f_1a_male
for var hh_f_1b_male__*: tab X, mi
egen HDDS =  rowtotal(hh_f_1b_male__1-hh_f_1b_male__20)
sum HDDS, d
lab var HDDS "Household dietary diversity"
for var hh_f_1b_female__*: tab X, mi
egen HDDS_f = rowtotal(hh_f_1b_female__1-hh_f_1b_female__20)
sum HDDS_f, d
lab var HDDS_f "Female household dietary diversity score"
for var hh_f_2__*: tab X, mi
egen foodinsec = rowtotal(hh_f_2__1-hh_f_2__9)
sum foodinsec, d
tab hh_e_14, g(hhd_ent)
drop hh_e_36-FS_module_endtime income_module_start_date income_module_start_time ///
hh_e_20_3-hh_e_19a_others__2 AF_module_enddate-interview__status hdmansp_rel4 ///
hdmansp_rel3 headman_rel1 headman_rel3 headman_rel4 hdmansp_rel1 headman_rel1 ///
headman_rel3 headman_rel4 hdmansp_rel1 hdmansp_rel3 hdmansp_rel4 chiefrel1 ///
chiefrel3 chiefrel4 mobile_money1 mobile_money3 mobile_money4 mbmney_inf1 ///
mbmney_inf3 cont_farming2 ext2 minfo2 credit2 getloan2 hh_a_01-hh_a_03 hh_a_04 ///
hh_a_05 hh_a_06-hh_a_09 hh_a_10__Accuracy-hh_a_10__Timestamp hh_a_11__0-hh_a_13a__4 hh_e_14 hhd_ent2
so interview__id FS_respondent_female FS_Female_availability
save "$data\hhd_wsround1", replace
**
use "$rawdata\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1_VineFile_HCIcomplete", clear
inspect HCI
sum HCI, d
keep interview__id roof_noroof-AssetsDeprived outschool-WealthClass5 
so interview__id
save "$rawdata\hhd_other", replace
**
use "$data\hhd_wsround1", clear
mer 1:1 interview__id using "$rawdata\hhd_other"
drop _mer
lab var foodinsec "foodsecurity"
save "$data\hhd_wsround1_", replace
***
use "$rawdata\casual_empl_f", clear
order interview__id interview__key
tab hh_f_22, g(farm_emp)
for var hh_f_23a__*: tab X, mi
for var hh_f_23b__*: tab X, mi
for var hh_f_23b__2 hh_f_23b__3 hh_f_23b__4: tab X, mi
keep interview__id hh_f_23a__1-farm_emp2
so interview__id
save "$data\casualemp_fe", replace
**
use "$rawdata\Casual_pay", clear 
order interview__id interview__key
sum hh_e_12, d
inspect hh_e_12b
sum hh_e_12b
inspect hh_e_13
sum hh_e_13
drop hh_casual__id hh_casual_sources__id
collapse (sum) hh_e_12-hh_e_13, by(interview__id)
so interview__id
save "$data\casualpay", replace
**
use "$rawdata\Casual_pay_f", clear
order interview__id interview__key
inspect hh_f_24 hh_f_24b hh_f_25
collapse (sum) hh_f_24 hh_f_24b hh_f_25, by(interview__id)
so interview__id
save "$data\casualpay_fem", replace
**
use "$rawdata\conspn", clear
order interview__id interview__key
inspect hh_e_24b hh_e_24c
ren (hh_e_24b hh_e_24c) (casset_owned casset_value)
reshape wide casset_owned casset_value, i(interview__id) j(conspn__id)
drop interview__key
so interview__id
save "$data\conspn", replace
**
use "$rawdata\Contract_Package", clear
order interview__id interview__key
inspect hh_z_4a
tab hh_z_4b, mi
replace hh_z_4a = hh_z_4a*0.404686 if hh_z_4b == 1
replace hh_z_4a = hh_z_4a/10000 if hh_z_4b == 3
for var hh_z_4e__*: tab X, mi
drop hh_z_4f hh_z_4b interview__key hh_z_4c hh_z_4b hh_z_4e__1-hh_z_4e__8
replace hh_z_4d = "Chidziva" if hh_z_4d == "(CTP) chidziva tobacco processors"
replace hh_z_4d = "Aqua" if hh_z_4d == "Aqua Tobacco Zimbabwe"	
replace hh_z_4d = "Boost" if hh_z_4d == "Boast Africa a private tobacco company"	
replace hh_z_4d = "Boost" if hh_z_4d == "Boast African, a private tobacco firm"	
replace hh_z_4d = "Boost" if hh_z_4d == "Boost  Africa"	
replace hh_z_4d = "Boost" if hh_z_4d == "Boost Africa"	
replace hh_z_4d = "Boost" if hh_z_4d == "Booster Africa"	
replace hh_z_4d="CTL" if hh_z_4d=="CTL (Curbrit Tobacco Leaf)"
replace hh_z_4d="CTL" if hh_z_4d=="CTL a private tobacco company"
replace hh_z_4d="CTL" if hh_z_4d=="CTL a private tobacco firm"
replace hh_z_4d="CTL" if hh_z_4d=="Caved Tobacco Limited (CTL)"
replace hh_z_4d="Chidziva" if hh_z_4d=="Chidziva"
replace hh_z_4d="Chidziva" if hh_z_4d=="Chidziva Contractor"
replace hh_z_4d="Chidziva" if hh_z_4d=="Chidziva a private tobacco company"
replace hh_z_4d="Chidziva" if hh_z_4d=="ChidzivaTobacco Processors"
replace hh_z_4d="Command" if hh_z_4d=="Command Agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Command agriculture a government program"
replace hh_z_4d="Command" if hh_z_4d=="Command agriculture a government program"
replace hh_z_4d="CTL" if hh_z_4d=="Coverage Tobacco Leaf"
replace hh_z_4d="CTL" if hh_z_4d=="Coverage Tobacco Limited"
replace hh_z_4d="CTL" if hh_z_4d=="Curbrid Tobacco"
replace hh_z_4d="CTL" if hh_z_4d=="Curverid Tobacco Limited"
replace hh_z_4d="CTL" if hh_z_4d=="Curverid Tobacco a private firm"
replace hh_z_4d="CTL" if hh_z_4d=="Curvirid Leaf Tobacco"
replace hh_z_4d="CTL" if hh_z_4d=="Cuverige Leaf Tobacco"
replace hh_z_4d="Ethical" if hh_z_4d=="Elt private tobacco company"
replace hh_z_4d="Ethical" if hh_z_4d=="Ethical Leaf Tobacco"
replace hh_z_4d="Command" if hh_z_4d=="Government"
replace hh_z_4d="Command" if hh_z_4d=="Government Command Agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Government Command Agriculture programme"
replace hh_z_4d="Command" if hh_z_4d=="Government Command Agriculture programme"
replace hh_z_4d="Command" if hh_z_4d=="Government Command Agriculture programme"
replace hh_z_4d="Command" if hh_z_4d=="Government of Zimbabwe under command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Government under command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Government under command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="Government under its command farming program"
replace hh_z_4d="Command" if hh_z_4d=="Government under the command farming program"
replace hh_z_4d="MTC" if hh_z_4d=="MTC a private tobacco company"
replace hh_z_4d="MTC" if hh_z_4d=="Mashonaland Tobacco Company"
replace hh_z_4d="MTC" if hh_z_4d=="Mashonaland Tobacco Company a private company"
replace hh_z_4d="MTC" if hh_z_4d=="Mashonaland Tobacco Company, selling contract only"
replace hh_z_4d="Premier" if hh_z_4d=="Premier Tobacco"
replace hh_z_4d="Premier" if hh_z_4d=="Premier leaf tobacco"
replace hh_z_4d="Premier" if hh_z_4d=="Premium"
replace hh_z_4d="Premier" if hh_z_4d=="Premium Leaf Tobacco a private company"
replace hh_z_4d="Premier" if hh_z_4d=="Premium Leaf Zimbabwe"
replace hh_z_4d="Premier" if hh_z_4d=="Premium Tobacco"
replace hh_z_4d="Premier" if hh_z_4d=="Premium Tobacco Leaf"
replace hh_z_4d="Premier" if hh_z_4d=="Premium Tobacco a private company"
replace hh_z_4d="Seedco" if hh_z_4d=="Seedco"
replace hh_z_4d="Shasha" if hh_z_4d=="Shasha Tobacco"
replace hh_z_4d="Command" if hh_z_4d=="The Government through the Command Agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The Government, through the command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government"
replace hh_z_4d="Command" if hh_z_4d=="The government through command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the Command Agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the Command Agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the Command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the command farming"
replace hh_z_4d="Command" if hh_z_4d=="Under command agriculture ,a government program"
replace hh_z_4d="Command" if hh_z_4d=="Under command agriculture a government program"
replace hh_z_4d="ZLT" if hh_z_4d=="ZLT"
replace hh_z_4d="ZLT" if hh_z_4d=="ZLT a private tobacco company"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe  Leaf Tobacco"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe Command Agriculture"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe Leaf Tobacco"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe Leaf Tobacco, a private company"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe Leaf Tobbaco a private company"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe Tobacco Leaf"
replace hh_z_4d="ZLT" if hh_z_4d=="Zimbabwe leaf tobacco"
replace hh_z_4d="Aqua" if hh_z_4d=="aqua atz"
replace hh_z_4d="Boost" if hh_z_4d=="boost africa"
replace hh_z_4d="Chidziva" if hh_z_4d=="chidziva"
replace hh_z_4d="Chidziva" if hh_z_4d=="chidziva  tobacco processors"
replace hh_z_4d="Chidziva" if hh_z_4d=="chidziva tobacco contractors"
replace hh_z_4d="Chidziva" if hh_z_4d=="chidziva tobacco processors"
replace hh_z_4d="Chidziva" if hh_z_4d=="chidziwa"
replace hh_z_4d="Command" if hh_z_4d=="command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="Command agriculture a government programme"
replace hh_z_4d="Command" if hh_z_4d=="command agriculture program"
replace hh_z_4d="CTL" if hh_z_4d=="coverage"
replace hh_z_4d="CTL" if hh_z_4d=="coverage tobacco company"
replace hh_z_4d="CTL" if hh_z_4d=="coverage tobacco leaf"
replace hh_z_4d="CTL" if hh_z_4d=="coverage tobacco leaf CTL"
replace hh_z_4d="CTL" if hh_z_4d=="coverage tobacco limited"
replace hh_z_4d="CTL" if hh_z_4d=="coverage tobacco ltd"
replace hh_z_4d="CTL" if hh_z_4d=="ctl"
replace hh_z_4d="CTL" if hh_z_4d=="cuverige tobacco company"
replace hh_z_4d="Command" if hh_z_4d=="government"
replace hh_z_4d="Command" if hh_z_4d=="government (command agriculture)"
replace hh_z_4d="Command" if hh_z_4d=="government command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="government command farming"
replace hh_z_4d="Command" if hh_z_4d=="government command program"
replace hh_z_4d="Command" if hh_z_4d=="government of zimbabwe (command agriculture program)"
replace hh_z_4d="Command" if hh_z_4d=="government of zimbabwe command agric program"
replace hh_z_4d="Command" if hh_z_4d=="government under command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="grain marketing board, under the government of Zimbabwe's command agriculture program"
replace hh_z_4d="CTL" if hh_z_4d=="kevrid tobacco limited"
replace hh_z_4d="MTC" if hh_z_4d=="mashonaland tobacco company"
replace hh_z_4d="MTC" if hh_z_4d=="mashonaland tobacco company (MTC)"
replace hh_z_4d="MTC" if hh_z_4d=="mashonaland tobacco company in Zimbabwe"
replace hh_z_4d="MTC" if hh_z_4d=="mashonaland tobacco company pvt ltd and coverage tobacco company pvt ltd"
replace hh_z_4d="Pension" if hh_z_4d=="pension union trust of zimbabwe"
replace hh_z_4d="Premier" if hh_z_4d=="premier"
replace hh_z_4d="Premier" if hh_z_4d=="premium"
replace hh_z_4d="Premier" if hh_z_4d=="premium leaf tobacco"
replace hh_z_4d="Premier" if hh_z_4d=="premium leaf tobacco pvt ltd"
replace hh_z_4d="Premier" if hh_z_4d=="premium tobacco"
replace hh_z_4d="Premier" if hh_z_4d=="premium tobacco company"
replace hh_z_4d="Shasha" if hh_z_4d=="shasha tobacco"
replace hh_z_4d="Shasha" if hh_z_4d=="shasha tobacco company"
replace hh_z_4d="Command" if hh_z_4d=="the Grain Marketing Board, under the Command Agriculture program by government of Zimbabwe"
replace hh_z_4d="Command" if hh_z_4d=="the government of zimbabwe"
replace hh_z_4d="Command" if hh_z_4d=="the grain marketing board, under government"
replace hh_z_4d="Premier" if hh_z_4d=="timb, gid, tp, premium"
replace hh_z_4d="Tribac" if hh_z_4d=="tribac pvt ltd"
replace hh_z_4d="Tribac" if hh_z_4d=="triberg"
replace hh_z_4d="Command" if hh_z_4d=="zimbabwe government command agriculture"
replace hh_z_4d="Command" if hh_z_4d=="zimbabwe government command agriculture"
replace hh_z_4d="ZLT" if hh_z_4d=="zimbabwe leaf tobacco"
replace hh_z_4d="ZLT" if hh_z_4d=="zlt"
replace hh_z_4d="Command" if hh_z_4d=="zimbabwe government command agriculture program"
replace hh_z_4d="Command" if hh_z_4d=="Government Command Agriculture Program"
replace hh_z_4d="Command" if hh_z_4d=="The government through the Command Agriculture Program"
replace hh_z_4d="Command" if hh_z_4d=="command agriculture a government program"
replace hh_z_4d="Command" if hh_z_4d== "The government through the command farming program"
replace hh_z_4d="Command" if hh_z_4d== "Government Command Agriculture Programme"
encode hh_z_4d, g(cont)
drop hh_z_4d
order cont, before(hh_z_4a)
tostring cont, g(cont1)
drop cont
ren cont1 cont
//egen contractpackage = group(Contract_Package__id cont)
preserve
drop hh_z_4a
save "$data\contr", replace
restore
drop cont
reshape wide hh_z_4a, i(interview__id) j(Contract_Package__id)
lab var hh_z_4a1 "Maize Area"
lab var hh_z_4a2 "Tobacco Area"
lab var hh_z_4a8 "Soyabeans Area"
lab var hh_z_4a12 "Sweet Potato"
g contrfarming = 1
so interview__id
save "$data\contractpackage", replace
**
use "$data\contr", clear
g cont1 = real(cont)
drop cont
ren cont1 cont
drop if cont==.
egen _id = group(interview__id cont)
reshape wide cont , i(_id) j(Contract_Package__id)
order interview__id
g cont_1 = (cont1!=.)
g cont_2 = (cont2!=.)
g cont_8 = (cont8!=.)
g cont_12 = (cont12!=.)
preserve
keep cont_1 interview__id-cont1
drop if cont1 == .
reshape wide cont_1, i(_id) j(cont1)
order interview__id
drop _id
so interview__id
save tmp5, replace
restore
**
preserve
keep interview__id _id cont2 cont_2
drop if cont2 == .
reshape wide cont_2, i(_id) j(cont2)
order interview__id
drop _id
for var cont_21-cont_213: replace X = 0 if X == .
so interview__id
save tmp6, replace
restore
**
preserve
keep interview__id _id cont8 cont_8
drop if cont8 == .
reshape wide cont_8, i(_id) j(cont8)
order interview__id
drop _id
save tmp7, replace
restore
**
use "$data\contractpackage", clear
mer 1:1 interview__id using tmp5
drop _mer
mer 1:1 interview__id using tmp6
drop _mer
mer 1:1 interview__id using tmp7
drop _mer
for var cont_15-cont_85:replace X = 0 if X == .
lab var cont_15 "Maize under Government of Zimbabwe"
lab var cont_110 "Maize under Seedco"
lab var cont_113 "Maize under ZLT"
lab var cont_21 "Aqua"
lab var cont_22 "Boost Africa"
lab var cont_23 "CTL"
lab var cont_24 "Chidziva Tobacco Processors"
lab var cont_26 "Ethical Leaf Tobacco"
lab var cont_27 "Mashonaland Tobacco Company"
lab var cont_29 "Premier Leaf Tobacco"
lab var cont_211 "Shasha Tobacco"
lab var cont_212 "Tribac"
lab var cont_213 "Zimbabwe Leaf Tobacco"
so interview__id
save "$data\contractpackage_fin", replace
**

**
use "$rawdata\crop div", clear
isid interview__id
sum NumberMainCrops, d
keep interview__id NumberMainCrops
so interview__id
save "$data\cropdiver", replace
**
use "$rawdata\fertiliser", clear
order interview__id interview__key crop_roster_sale__id ag_b_2_plot_roster__id
replace ag_b_28b = ag_b_28b*1000 if ag_b_28c == 2
replace ag_b_28b = ag_b_28b*18 if ag_b_28c_other == "20 litre bucket"
replace ag_b_28b = ag_b_28b*5 if ag_b_28c_other == "5 litre galon"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50 kg bag"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50 kg bags"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50 kgs bag"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50 kgs bags"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50kg bags"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50kgs bag"
replace ag_b_28b = ag_b_28b*50 if ag_b_28c_other == "50kgs bags"
replace ag_b_28b = ag_b_28b*500 if ag_b_28c_other == "carts"
inspect ag_b_28b
winsor2 ag_b_28b if ag_b_28b!=., replace cuts(10 90)
drop ag_b_28c ag_b_28c_other
inspect ag_b_28d
sum ag_b_28d, d
winsor2 ag_b_28d if ag_b_28d!=., replace cuts(10 90)
tab ag_b_28e, g(fert_source)
drop ag_b_28e
egen _id = group(interview__id interview__key crop_roster_sale__id ag_b_2_plot_roster__id)
reshape wide ag_b_28b-fert_source4, i(_id) j(fertiliser__id)
order interview__id interview__key crop_roster_sale__id ag_b_2_plot_roster__id
drop interview__key-_id
for var ag_b_28b1-fert_source42: byso interview__id: egen _X = total(X) 
for var ag_b_28b1-fert_source42: drop X
duplicates drop
order _fert_source11-_fert_source41, after(_ag_b_28d2)
for var _fert_source11-_fert_source42: replace X = 1 if X >=1
so interview__id
save "$data\fertiliser", replace
**
use "$rawdata\hh_enterprises", clear
order interview__id interview__key 
drop hh_member_enter__1-hh_member_enter__14
inspect hh_e_16
sum hh_e_16
sum hh_e_18
sum hh_e_17a
drop hh_e_17b__1-hh_e_17c__12 hh_e_15
sum hh_e_17d, d
sum hh_e_18
reshape wide hh_member_enter__0-hh_e_18, i(interview__id) j(hh_enterprises__id)
drop hh_member_enter__02-interview__key
for var hh_e_161-hh_e_181: inspect X
ren hh_member_enter__01 hhroster__id
so interview__id hhroster__id
g hhroster__id1 = real(hhroster__id)
drop hhroster__id 
ren hhroster__id1 hhroster__id
so interview__id hhroster__id
drop if hhroster__id == .
mer m:m interview__id hhroster__id using tmp2
keep if _mer == 3
drop _mer
order hh_a_14, after(interview__id)
drop hhroster__id
tab hh_a_14, g(gend_ent)
drop hh_a_14
so interview__id
save "$data\hhd_ent", replace
**
use "$rawdata\hh_regular", clear
order interview__id interview__key regular_employ__id
**
use "$rawdata\livestock_produce", clear
order interview__id interview__key
inspect ag_d_19
sum ag_d_19
drop ag_d_20a__1-ag_d_21b
collapse (sum) ag_d_19, by(interview__id)
sum ag_d_19, d
winsor2  ag_d_19 if ag_d_19!=., replace cuts(10 90)
ren ag_d_19 liv_sales
save "$data\liv_sales", replace
**
use "$rawdata\livestockroster", clear
order interview__id interview__key
drop ag_d_6a__* ag_d_6b__* ag_d_15__* cattle_owned-TLU
tab ag_d_10a, g(grazing)
tab ag_d_13a, g(soldliv)
tab ag_d_17a, g(livmod)
drop grazing1 soldliv2 ag_d_10a ag_d_13a ag_d_17a ag_d_17b
**
reshape wide ag_d_2-livmod5, i(interview__id) j(livestockroster__id)
ren (ag_d_21 ag_d_31 ag_d_41 ag_d_51 ag_d_7a1 ag_d_7b1 ag_d_81) (cattleraised cattleowned ///
cattlevalue cattleslaughtered cattlepurchased cattleprice cattledeath)
ren (ag_d_22 ag_d_32 ag_d_42 ag_d_52 ag_d_7a2 ag_d_7b2 ag_d_82) (goatsraised goatsowned ///
goatsvalue goatsslaughtered goatspurchased goatsprice goatsdeath)
ren (ag_d_23 ag_d_33 ag_d_43 ag_d_53 ag_d_7a3 ag_d_7b3 ag_d_83) (sheepraised sheepowned ///
sheepvalue sheepslaughtered sheeppurchased sheepprice sheepdeath)
ren (ag_d_24 ag_d_34 ag_d_44 ag_d_54 ag_d_7a4 ag_d_7b4 ag_d_84) (pigsraised pigsowned ///
pigsvalue pigsslaughtered pigspurchased pigsprice pigsdeath)
ren (ag_d_25 ag_d_35 ag_d_45 ag_d_55 ag_d_7a5 ag_d_7b5 ag_d_85) (poultryraised poultryowned ///
poultryvalue poultryslaughtered poultrypurchased poutryprice poultrydeath)
ren (ag_d_26 ag_d_36 ag_d_46 ag_d_56 ag_d_7a6 ag_d_7b6 ag_d_86) (donkeyraised donkeyowned ///
donkeyvalue donkeyslaughtered donkeypurchased donkeyprice donkeydeath)
ren (ag_d_27 ag_d_37 ag_d_47 ag_d_57 ag_d_7a7 ag_d_7b7 ag_d_87) (otheliveraised otheliveowned ///
othelivevalue otherliveslaughtered othelivepurchased otheliveprice othelivedeath)
keep interview__id-cattledeath goatsraised-goatsdeath sheepraised-sheepdeath pigsraised-pigsdeath ///
poultryraised-poultrydeath donkeyraised-donkeydeath otheliveraised-othelivedeath
so interview__id
save "$data\livestock", replace
**
use "$rawdata\production", clear
order interview__id interview__key
ren (hh_e_23b hh_e_23c) (prodasset prodassetvalue)
reshape wide prodasset prodassetvalue, i(interview__id) j(production__id)
drop interview__key
so interview__id
save "$data\productionasset", replace
**
use "$rawdata\services_hired", clear
order interview__id interview__key ag_b_2_plot_roster__id
g persondays = ag_b_23/ag_b_22
collapse  (sum) persondays, by(interview__id)
winsor2 persondays if persondays!=., replace cuts(10 90)
sum persondays, d
save "$data\hiredlab", replace
**
mer 1:1 interview__id using "$rawdata\tlu"
drop _mer
save "$data\hiredlab_TLU", replace
**
use "$rawdata\crops grown", clear
ren ag_b_17__2 cashcrop
keep interview__key cashcrop
save "$data\cashcrop", replace
**
use "$data\hhd_demographics", clear
keep interview__id interview__key
so interview__key 
mer 1:1 interview__key using "$data\cashcrop"
keep if _mer==3
drop _mer interview__key
save "$data\cashcrop_fin", replace
**
use "$rawdata\Crops Area.dta", clear
drop if crop_roster_sale__id == .
reshape wide CropArea, i(interview__id) j(crop_roster_sale__id)


*COMPILING ALL THE DATA INTO ONE
use "$data\hhd_rentmkt", clear
order rentmkt, before(rent_in)
mer 1:1 interview__id using "$data\hhd_demographics"
drop _mer
mer 1:1 interview__id using "$rawdata\hci collapsed"
drop _mer
order HCI, before(age)
mer 1:1 interview__id using "$data\activ_gender"
drop _mer
mer 1:1 interview__id using "$data\hhd_addinp"
drop _mer
mer 1:1 interview__id using "$data\hhd_services"
drop _mer
mer 1:1 interview__id using "$data\hhd_wsround1_"
drop _mer
order HDDS HDDS_f foodinsec, before(age)
mer 1:1 interview__id using "$data\casualemp_fe"
drop _mer
mer 1:1 interview__id using "$data\casualpay"
drop _mer
mer 1:1 interview__id using "$data\casualpay_fem"
drop _mer
mer 1:1 interview__id using "$data\conspn"
drop _mer
mer 1:1 interview__id using "$data\contractpackage"
drop _mer
replace contrfarming = 0 if contrfarming == .
mer 1:1 interview__id using "$data\cropdiver"
drop _mer
mer 1:1 interview__id using "$data\fertiliser"
drop _mer
mer 1:1 interview__id using "$data\hhd_ent"
drop _mer
mer 1:1 interview__id using "$data\liv_sales"
drop _mer
mer 1:1 interview__id using "$data\livestock"
drop _mer
mer 1:1 interview__id using "$data\productionasset"
drop _mer
mer 1:1 interview__id using "$data\hiredlab_TLU"
drop _mer
mer 1:1 interview__id using "$data\cashcrop_fin"
drop _mer
order hh_a_10__Latitude hh_a_10__Longitude hh_a_04b, before(rentmkt)

g lat2 = .
g long2 = .
replace lat2 = -17.0263346 if hh_a04b1 == 1
replace long2 = 30.8423018 if hh_a04b1 == 1
replace lat2 = -17.3722341 if hh_a_05b == 17
replace lat2 = -17.3722341 if hh_a_05b == 16
replace lat2 = -17.3722341 if hh_a_05b == 15
replace lat2 = -17.3722341 if hh_a_05b == 14
replace lat2 = -17.3722341 if hh_a_05b == 13
replace long2 = 30.9403014 if hh_a_05b == 17 | hh_a_05b == 16 | hh_a_05b == 15 | hh_a_05b == 14
replace long2 = 30.9403014 if hh_a_05b == 13
replace lat2 = -17.3613486 if hh_a_05b == 1 | hh_a_05b == 2
replace long2 = 31.0435007 if hh_a_05b == 1 | hh_a_05b == 2
replace lat2 = -17.0263346 if lat2 == .
replace long2 = 30.8423018 if long2 == .
inspect lat2 long2
vincenty hh_a_10__Latitude  hh_a_10__Longitude lat2 long2, v(v) hav(h) inkm /* calculating distances */
replace hh_a_05b = 6 if hh_a_05b == .a
preserve
/*keep interview__id hh_a_10__Latitude hh_a_10__Longitude
ren (hh_a_10__Latitude hh_a_10__Longitude) (Latitude Longitude)
export delimited using "$data\apracoor", replace*/
import delimited using "$data\aprasurvey", clear
keep adm3_en adm3_pcode interview__id
order interview__id adm3_pcode
drop if interview__id == ""
ren adm3_en ward
so interview__id
save "$data\wardapra", replace
restore
**
mer 1:1 interview__id using "$data\wardapra"
drop _mer v lat2 long2
order ward adm3_pcode, before(hh_a_04b)
replace ward = 29 if ward == 28
so ward 
save "$data\hhdmerged_", replace
*merge with rainfall data
use "C:\Users\Mahofa\OneDrive - University of Cape Town\GM First Strategy\data\zimwardsfinalrainfall2000_2019", clear
keep if district == "Mazowe"
collapse (sum) rainfall, by(wardno year)
ren wardno ward
destring year, replace
keep if year > 2013
drop if year == 2019
byso ward: egen meanrain = mean(rainfall)
drop rainfall year
duplicates drop
lab var meanrain "Average rainfall(mm) in ward for 2014-2018"
mer 1:m ward using "$data\hhdmerged_"
keep if _mer == 3
drop _mer
order interview__id adm3_pcode
order meanrain, after(TLU)
preserve 
keep interview__id hh_a_05b
ren hh_a_05b farm
encode interview__id, g(interview__id1)
drop interview__id
order interview__id1
ren interview__id1 interview__id
so interview__id
save "$data\scheme", replace
restore
drop hh_a04b1 hh_a_05b hh_module_endtime AG_module_start_date ag_module_start_time ///
ag_module_respondent ag_b_parcel cultivated_year ag_b_0 AG_module_enddate AG_module_endtime
ren h dist 
lab var dist "Distance to main markets"
save "$data\hhdmerged_final", replace
**
exit

