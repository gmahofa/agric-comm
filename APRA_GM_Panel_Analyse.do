clear
set more off, perm 
cap log close
*Set folders
global root  "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global rawdata "$root\rawdata\APRA Zimbabwe Panel"
global code "$root\code"
global output "$root\output"
global data "$root\data"
global tmp "C:\Users\Mahofa"

**
log using "$code\apra_gm_panel_analysis", replace
****HH Demographics
use "$rawdata\2. R1_R2_Section_A_HH_Members_zmb.dta", clear
inspect hh_a_15  /*age */

tab hh_a_18, g(married)  /*marital status */
inspect hh_a_19 /*years of schooling*/
sum hh_a_19, d
tab hh_a_14, g(gender)
byso hh_id year:egen hhdsize = count(hhroster__id)
lab var hhdsize "Household size"

g years = hh_a_19 if hh_a_14==2&hh_a_15>14
g age1 = hh_a_15 if hh_a_14==2&hh_a_15>14
byso hh_id year: egen year_sch_women = mean(years)
byso hh_id year: egen age_women = mean(age1)
byso hh_id year: egen chdn = total(hh_a_15 <= 14) /*total number of chdn*/
lab var chdn "Number of children 0-14"
byso hh_id year: egen nofemale = total(hh_a_15 <= 14&gender2 ==1) /*female children less than 14*/
lab var nofemale "Number of female children below the age of 14"
byso hh_id year: egen nomale = total(hh_a_15 <= 14&gender1 ==1) /*male children less than 14*/
lab var nomale "Number of male children below the age of 14"
byso hh_id year: egen youth = total(inrange(hh_a_15, 15,34)) 
lab var youth "Number of youth 15-34"
byso hh_id year: egen youthmale = total(inrange(hh_a_15, 15,34) & gender1 == 1)
lab var  youthmale "Number of male youth 15-34"
byso hh_id year: egen youthfmale = total(inrange(hh_a_15, 15,34) & gender2 == 1) 
lab var  youthfmale "Number of female youth 15-34"
byso hh_id year: egen adult = total(inrange(hh_a_15, 35,60)) 
lab var adult "Number of adults 35-60"
byso hh_id year: egen adultmale = total(inrange(hh_a_15, 35,60) & gender1 == 1) /* adult male between 35 and 60*/
lab var adultmale "Adult male aged between 35 and 60"
byso hh_id year: egen adultfemale = total(inrange(hh_a_15, 35,60) & gender2 == 1) /* adult female between 35 and 60*/
lab var adultfemale "Adult female aged between 35 and 60"
byso hh_id year: egen old = total(hh_a_15 > 60& hh_a_15 != .) 
lab var old "Number of elders"
byso hh_id year: egen oldfemale = total(hh_a_15 > 60 & gender2 == 1 & hh_a_15 != .) /* old female between 35 and 60*/
lab var oldfemale "Number of female members aged 60 and above"
byso hh_id year: egen oldmale = total(hh_a_15 > 60 & gender1 == 1 & hh_a_15 != .) /* old female between 15 and 60*/
lab var oldmale "Number of male members aged 60 and above"
egen dependent = rowtotal(chdn old)
egen productive = rowtotal(youth adult)
g dpratio = dependent/productive
preserve
keep if hh_a_16 == 1
keep hh_id year hh_a_15 hh_a_19 married3 married4 gender1 hhdsize productive ///
dpratio year_sch_women age_women
save "$data\hhd_demographics", replace
restore
keep hh_id year hhroster__id hh_a_23
reshape wide hh_a_23, i(hh_id year) j(hhroster__id)

*Any school age child is not in primary school (hh_a_23)
egen outschool = anycount( hh_a_231 hh_a_232 hh_a_233 hh_a_234 hh_a_235 hh_a_236 ///
 hh_a_237 hh_a_238 hh_a_239 hh_a_2310 hh_a_2311 hh_a_2312 hh_a_2313 hh_a_2314 hh_a_2315 hh_a_2316), values(1)
gen OutofSchool=0
replace OutofSchool=1 if outschool >0
keep OutofSchool hh_id year
mer 1:1 hh_id year using "$data\hhd_demographics", nogen
lab var OutofSchool "Hhd with children out of School"
lab var productive "Adult age"
save "$data\hhd_demographics_fin", replace
**
use "$rawdata\5. R1_R2_Section_A_Agri_Services_zmb.dta", clear
keep hh_id year Agri_services__id hh_a_29b
reshape wide hh_a_29b, i(hh_id year) j(Agri_services__id)
keep hh_id year hh_a_29b1 hh_a_29b5
lab var hh_a_29b1 "dist to road"
lab var hh_a_29b5 "dist to market"
save "$data\dist_road", replace
**
use "$rawdata\6. R1_R2_Section_B_C_Plot_Crop_Rosters_ALL_zmb.dta", clear
collapse (sum) ag_b_04a_units, by(hh_id year)
ren ag_b_04a_units land_own
lab var land_own "Acres owned"
save "$data\land_own", replace
**
*Poultry
use "$rawdata\11. R1_R2_Section_D_zmb.dta", clear
preserve
keep hh_id year livestockroster__id ag_d_3
g poultry = ag_d_3 if livestockroster__id == 5
drop livestockroster__id ag_d_3
collapse (sum) poultry, by(hh_id year)
save "$data\poultry", replace
restore

preserve
keep hh_id year livestockroster__id ag_d_3
keep if livestockroster__id == 1
ren ag_d_3 cattle 
lab var cattle "Cattle owned"
save "$data\cattle", replace
restore
**
*Tropical livestock Units
keep hh_id year livestockroster__id ag_d_3
collapse (sum) ag_d_3, by(hh_id year livestockroster__id)
reshape wide ag_d_3, i(hh_id year) j(livestockroster__id)
***livestock ownership (numbers) by type***
drop ag_d_37
ren (ag_d_31 ag_d_32 ag_d_33 ag_d_34 ag_d_35 ag_d_36) ///
(cattle_owned goats_owned sheep_owned pigs_owned poultry_owned donkey_owned)
***generating Tropical Livestock Units (TLU)***
g cattleind= 0.7* cattle_owned
g goatsind= 0.1* goats_owned
g sheepind= 0.1* sheep_owned
g pigind= 0.2* pigs_owned
g poultryind= 0.01* poultry_owned
g donkeyind= 0.5* donkey_owned
egen TLU= rowtotal (cattleind goatsind sheepind donkeyind pigind poultryind)
label variable TLU "Tropical Livestock Units"
keep hh_id year TLU
save "$data\TLU", replace
**
use "$rawdata\12. R1_R2_Section_E1_Regular_zmb.dta", replace
keep hh_id year hh_e_1a__* hh_regular__id
egen wagework = rowtotal(hh_e_1a__1-hh_e_1a__6)
drop hh_e_1a__*
collapse (sum) wagework, by(hh_id year)
replace wagework = 1 if wagework>1
save "$data\wage_worker", replace
**
*Rainfall
use "$data\zimwardsfinalrainfall2000_2019_2020.dta", clear
keep if district == "Mazowe"
collapse (sum) rainfall, by(wardno month year)
save "$data\rainwardmonth", replace
keep if year>="2017"
for var year month: g _X = real(X)
drop year month
order _year _month, after(wardno)
ren (_year _month) (year month)
drop if year == 2020&month > 6
drop if year == 2017&month < 7
drop if year == 2018&month > 6
drop if year == 2019&month < 7
g year1 = 2017 if year == 2017|year == 2018
replace year1 = 2019 if year == 2019|year == 2020
collapse (sum) rainfall, by(wardno year1)
ren year1 year
ren wardno ward
mer 1:m ward year using "$data\wardrain"
keep if _mer == 3
drop _mer
order hh_id
//drop ward
so hh_id year
save "$data\wardrainfall21", replace
use "$data\rainwardmonth", clear
collapse (sum) rainfall, by(wardno year)
drop if year == "2000"
byso wardno: egen avge = mean(rainfall)
byso wardno: egen sdev = sd(rainfall)
g std_rainfall =  (rainfall-avge)/sdev
keep wardno year std_rainfall
lab var std_rainfall "Rainfall deviations"
ren wardno ward
g year1 = real(year)
drop year
ren year1 year
order year, after(ward)
mer 1:m ward year using "$data\wardrainfall21"
keep if _mer == 3
drop _mer ward
order hh_id
save "$data\wardrainfall21_fin"

**
*Asset ownership index
use "$rawdata\16. R1_R2_Section_E4_zmb.dta", clear
*Use value of assets
egen production_assets =  rowtotal(hh_e_23c__*)
egen consumption_assets = rowtotal(hh_e_24c__*)
keep hh_id year production_assets consumption_assets
lab var production_assets "Value of production assets in US$"
lab var consumption_assets "Value of consumption assets in US$"
save "$data\assetindex", replace


***dummies for PCA
*Main roof material (hh_e_25a)
generate roof_noroof=0
replace roof_noroof=1 if hh_e_25a==1
generate roof_grass=0
replace roof_grass=1 if hh_e_25a==2
generate roof_mud=0
replace roof_mud=1 if hh_e_25a==3
generate roof_stone=0
replace roof_stone=1 if hh_e_25a==4
generate roof_plastic=0
replace roof_plastic=1 if hh_e_25a==5
generate roof_corrugated=0
replace roof_corrugated=1 if hh_e_25a==6
generate roof_wood=0
replace roof_wood=1 if hh_e_25a==7
generate roof_cement=0
replace roof_cement=1 if hh_e_25a==8
generate roof_other=0
replace roof_other=1 if hh_e_25a==9
gen roof_Asbestos=0
replace roof_Asbestos=1 if hh_e_25a==10

**Main Wall material (hh_e_26a)
gen Wall_nowall=0
replace Wall_nowall=1 if hh_e_26a==1
gen Wall_grass=0
replace Wall_grass=1 if hh_e_26a==2
gen Wall_dirt=0
replace Wall_dirt=1 if hh_e_26a==3
gen Wall_woodbamboo=0
replace Wall_woodbamboo=1 if hh_e_26a==4
gen Wall_stone=0
replace Wall_stone=1 if hh_e_26a==5
gen Wall_ConcreteCement=0
replace Wall_ConcreteCement =1 if hh_e_26a==6
gen Wall_Cement=0
replace Wall_Cement=1 if hh_e_26a==7
gen Wall_Woodplanks=0
replace Wall_Woodplanks=1 if hh_e_26a==8
gen Wall_TiledBricks=0
replace Wall_TiledBricks=1 if hh_e_26a==9
gen Wall_Others=0
replace Wall_Others=1 if hh_e_26a==10

***Main floor material (hh_e_27a)
gen floor_dirt=0
replace floor_dirt=1 if hh_e_27a==1
gen floor_cowdung=0
replace floor_cowdung=1 if hh_e_27a==2
gen floor_cowdungandsoil=0
replace floor_cowdungandsoil=1 if hh_e_27a==3
gen floor_stone=0
replace floor_stone=1 if hh_e_27a==4
gen floor_concrete=0
replace floor_concrete=1 if hh_e_27a==5
gen floor_cement=0
replace floor_cement=1 if hh_e_27a==6
gen floor_woodplanks=0
replace floor_woodplanks=1 if hh_e_27a==7
gen floor_tiledbricks=0
replace floor_tiledbricks=1 if hh_e_27a==8
gen floor_other=0
replace floor_other= 1 if hh_e_27a==9

***Main type of toilet you use
tab hh_e_28a
gen toilet_nofacility=0
replace toilet_nofacility=1 if hh_e_28a==1
gen toilet_panbucket=0
replace toilet_panbucket=1 if hh_e_28a==2
gen toilet_pitlatrine=0
replace toilet_pitlatrine=1 if hh_e_28a==3
gen toilet_ventilated=0
replace toilet_ventilated=1 if hh_e_28a==4
gen toilet_flush=0
replace toilet_flush=1 if hh_e_28a==5
gen toilet_other=0
replace toilet_other=1 if hh_e_28a==6

***The main type of cooking fuel you use in your house
generate cookingfuel_Driedleaves=0
replace cookingfuel_Driedleaves=1 if hh_e_29a==1
generate cookingfuel_driedcowdung=0
replace cookingfuel_driedcowdung=1 if hh_e_29a==2
generate cookingfuel_firewood=0
replace cookingfuel_firewood=1 if hh_e_29a==3
generate cookingfuel_charcoal=0
replace cookingfuel_charcoal=1 if hh_e_29a==4
generate cookingfuel_parafin=0
replace cookingfuel_parafin=1 if hh_e_29a==5
generate cookingfuel_electricity=0
replace cookingfuel_electricity=1 if hh_e_29a==6
generate cookingfuel_gas=0
replace cookingfuel_gas=1 if hh_e_29a==7
generate cookingfuel_solar=0
replace cookingfuel_solar=1 if hh_e_29a==8
generate cookingfuel_other=0
replace cookingfuel_other=1 if hh_e_29a==9

***Main source of water for drinking
replace hh_e_30a=4 if hh_e_30a==5 & hh_e_30b== "taped water"
label define hh_e_30a  6 "Borehole", add
replace hh_e_30a=6 if hh_e_30a==5 & hh_e_30b== "borehole"
replace hh_e_30a=6 if hh_e_30a==5 & hh_e_30b== "borehole water"
generate Water_natural=0
replace Water_natural=1 if hh_e_30a==1
generate Water_unprotectedwell=0
replace Water_unprotectedwell=1 if hh_e_30a==2
generate Water_protectedwell=0
replace Water_protectedwell=1 if hh_e_30a==3
generate Water_pipedsupply=0
replace Water_pipedsupply=1 if hh_e_30a==4
generate Water_other=0
replace Water_other=1 if hh_e_30a==5
generate Water_Borehole=0
replace Water_Borehole=1 if hh_e_30a==6

***Main source of lighting energy.
label define hh_e_31a  11 "Torch", add
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b== "Torch"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="battery torch"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="battery torches"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="battery touch"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="they use torches"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="torch"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="torch light"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="torch lights"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="torches"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="touches"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="tourch"
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="torch powered by in rechargeable batteries"

generate Lighting_grass=0
replace Lighting_grass=1 if hh_e_31a==1
generate Lighting_candles=0
replace Lighting_candles=1 if hh_e_31a==2
generate Lighting_firewood=0
replace Lighting_firewood=1 if hh_e_31a==3
generate Lighting_charcoal=0
replace Lighting_charcoal=1 if hh_e_31a==4
generate Lighting_paraffin=0
replace Lighting_paraffin=1 if hh_e_31a==5
generate Lighting_electricity=0
replace Lighting_electricity=1 if hh_e_31a==6
generate Lighting_gas=0
replace Lighting_gas=1 if hh_e_31a==7
generate Lighting_solar=0
replace Lighting_solar=1 if hh_e_31a==8
generate Lighting_other=0
replace Lighting_other=1 if hh_e_31a==9
generate Lighting_Nosource=0
replace Lighting_Nosource=1 if hh_e_31a==10
generate Lighting_Torch=0
replace Lighting_Torch=1 if hh_e_31a==11

***Creating Wealth index PCA (all assets and living conditions)
global xlist hh_e_23a__1  hh_e_23a__2  hh_e_23a__3  hh_e_23a__4  hh_e_23a__5  ///
hh_e_23a__6  hh_e_23a__7  hh_e_23a__8  hh_e_23a__9  hh_e_23a__10  hh_e_23a__11 ///
hh_e_24a__1  hh_e_24a__2  hh_e_24a__3  hh_e_24a__4  hh_e_24a__6  hh_e_24a__7  ///
hh_e_24a__8  hh_e_24a__9  hh_e_24a__10 roof_noroof  roof_grass  roof_corrugated  ///
roof_wood  roof_cement  roof_other  roof_Asbestos Wall_dirt  Wall_woodbamboo  ///
Wall_stone  Wall_ConcreteCement  Wall_Cement  Wall_Woodplanks  Wall_TiledBricks  ///
Wall_Others floor_dirt  floor_cowdung  floor_cowdungandsoil  floor_stone  floor_concrete  floor_cement  floor_tiledbricks toilet_nofacility  toilet_pitlatrine  toilet_ventilated  toilet_flush  toilet_other Water_natural  Water_unprotectedwell  Water_protectedwell  Water_pipedsupply  Water_Borehole Lighting_candles  Lighting_firewood  Lighting_paraffin  Lighting_electricity  Lighting_gas  Lighting_solar  Lighting_other  Lighting_Nosource  Lighting_Torch cookingfuel_Driedleaves cookingfuel_firewood cookingfuel_parafin cookingfuel_electricity cookingfuel_gas cookingfuel_solar
global hh_id year
pca $xlist, mineigen(1)
predict WealthIndex
xtile WealthClass= WealthIndex, nq(3)

***Creating Production Asset Index (only focusing on the 11 production equipment)
global xlist hh_e_23a__1  hh_e_23a__2  hh_e_23a__3  hh_e_23a__4  hh_e_23a__5  ///
hh_e_23a__6  hh_e_23a__7  hh_e_23a__8  hh_e_23a__9  hh_e_23a__10  hh_e_23a__11
global hh_id year
pca $xlist, mineigen(1) 
predict ProductionAssetIndex
xtile ProductionAssetClass= ProductionAssetIndex, nq(3)
keep hh_id year WealthIndex WealthClass ProductionAssetIndex ProductionAssetClass

**
*Access to extension, credit 
use "$rawdata\R1_R2_AG_ADD_I_zmb", clear
keep hh_id year hh_z_1a hh_z_1b hh_z_7a
tab hh_z_1a, g(contractfarm)
tab hh_z_1b, g(extension)
tab hh_z_7a, g(credit)
drop hh_z_1a hh_z_1b hh_z_7a contractfarm2 extension2 credit2
drop if hh_id == 223&contractfarm1 == 0&year == 2017
save "$data\countryqstn", replace
**

*Commercialisation Indicators
use "$rawdata\6. R1_R2_Section_B_C_Plot_Crop_Rosters_ALL_zmb.dta", clear
order interview__id interview__key
preserve
keep hh_id year crop_roster_sale__id ag_b_23__1 ag_b_23__2 ag_b_23__4 ///
ag_b_23__5 ag_b_23__6 ag_b_23__7
collapse (sum) ag_b_23__1-ag_b_23__7, by(hh_id year)
egen persondays = rowtotal(ag_b_23__1 ag_b_23__2 ag_b_23__4 ag_b_23__5 ag_b_23__6 ag_b_23__7)
keep hh_id year persondays
save "$data\persondays", replace
restore
**
preserve
collapse (sum) ag_b_29b__1, by(hh_id year)
replace ag_b_29b__1 = 1 if ag_b_29b__1>0
ren ag_b_29b__1 tractor_use
lab var tractor_use "Tractor tillage"
save "$data\tractor_use", replace
restore
**


//HCI = (gross value of all crop sales/gross value of all crop
//production) * 100
//0 = total subsistence; 100 = full commercialisation
*ag_c_1a is production quant, ag_c_4a quant sale, ag_c_5 is value of sale
*Commercialisation
*What was the total value of sales from
*%crop_roster_sale%? [Value]
*Others
*50kg bag
*Harvest
replace conv_harv=35 if ag_c_1b_other=="3.5 50 kg bags unshelled" ///
| ag_c_1b_other=="4bags of 50kg bags unshelled" | ag_c_1b_other=="5 bags of unshelled" ///
| ag_c_1b_other=="50  kg bags,unshelled" | ag_c_1b_other=="50 Kg bags of unshelled" ///
| ag_c_1b_other=="50 Kg bags of unshelled groundnuts" | ag_c_1b_other=="50 bags not shelled" ///
| ag_c_1b_other=="50 bags of unshelled groundnuts" | ag_c_1b_other=="50 kg bag unshelled" ///
| ag_c_1b_other=="50 kg bags of unshelled" | ag_c_1b_other=="50 kg bags of unshelled groundnut" ///
| ag_c_1b_other=="50 kg bags of unshelled groundnuts" | ag_c_1b_other=="50 kg bags of unshelled nuts" ///
| ag_c_1b_other=="50 kg bags unshelled" | ag_c_1b_other=="50 kg bags unshelled bags" ///
| ag_c_1b_other=="50 kg bags unshelled groundnut" | ag_c_1b_other=="50 kg bags unshelled groundnuts" ///
| ag_c_1b_other=="50 kg bags, unshelled" | ag_c_1b_other=="50 kg bags,unshelled" ///
| ag_c_1b_other=="50 kg empty bags of unshelled groundnuts" | ag_c_1b_other=="50 kg of unshelled" ///
| ag_c_1b_other=="50 kg of unshelled grains" | ag_c_1b_other=="50 kg of unshelled groundnuts" ///
| ag_c_1b_other=="50 kg unshelled nuts" | ag_c_1b_other=="50 kgs bags of unshelled groundnuts" ///
| ag_c_1b_other=="50 kgs unshelled" | ag_c_1b_other=="50kg bag -unshelled" ///
| ag_c_1b_other=="50kg bag unshelled" | ag_c_1b_other=="50kg bags of unshelled" ///
| ag_c_1b_other=="50kg bags unshelled" | ag_c_1b_other=="50kg bags unshelled groundnuts" ///
| ag_c_1b_other=="50kg bags, unshelled" | ag_c_1b_other=="50kg bags,unshelled" ///
| ag_c_1b_other=="50kg sacks unshelled" | ag_c_1b_other=="50kg unshelled bags" ///
| ag_c_1b_other=="50kgs bad unshelled" | ag_c_1b_other=="50kgs bag unshelled" ///
| ag_c_1b_other=="59 kg bags unshelled" | ag_c_1b_other=="bags of 50 kg unshelled nuts" ///
| ag_c_1b_other=="bags unshelled groundnuts" | ag_c_1b_other=="unshelled 50kg bags" ///
| ag_c_1b_other=="unshelled groundnuts" | ag_c_1b_other=="20 bags of unshelled groundnuts packed in 50kg bags"
replace conv_harv=14 if ag_c_1b_other=="20 litre buckets of unshelled groundnuts"
*Conversions
replace ag_c_1b = 1 if hh_id == 695&year==2017&crop_roster_sale__id==1
replace conv_harv = 1 if hh_id == 695&year==2017&crop_roster_sale__id==1
replace ag_c_1b = 1 if hh_id == 362&year==2019&crop_roster_sale__id==8
replace conv_harv = 1 if hh_id == 362&year==2019&crop_roster_sale__id==8
replace ag_c_1b = 1 if hh_id == 400&year==2017&crop_roster_sale__id==7
replace conv_harv = 1 if hh_id == 400&year==2017&crop_roster_sale__id==7
replace ag_c_1b = 1 if hh_id == 335&year==2017&crop_roster_sale__id==29
replace conv_harv = 1 if hh_id == 335&year==2017&crop_roster_sale__id==29
replace ag_c_1a = 1.6 if hh_id == 122&year==2019&crop_roster_sale__id==4
replace ag_c_1b = 1 if hh_id == 122&year==2019&crop_roster_sale__id==1
replace ag_c_1b = 1 if hh_id == 640&year==2017&crop_roster_sale__id==15
replace conv_harv = 1 if hh_id == 640&year==2017&crop_roster_sale__id==15
replace ag_c_1a_units = ag_c_1a*conv_harv if ag_c_1a!=.
replace ag_c_1a_units = 5 if hh_id == 122&year==2019&crop_roster_sale__id==1
li hh_id year crop_roster_sale__id ag_c_5 ag_c_2 if ag_c_5==6739400
replace ag_c_5=. if ag_c_5==6739400
*Land owned
g conv_area = 1 if ag_b_04b == 2
replace conv_area = 0.404686 if ag_b_04b == 1
replace conv_area = 0.0001 if ag_b_04b == 3
replace ag_b_04a = 1 if hh_id==714&ag_b_2_plot_roster__id==3&year==2017
g ag_b_04a_units1 = ag_b_04a*conv_area if ag_b_04a!=.
g ag_b_04a_2020_units = ag_b_04a_2020*conv_area if ag_b_04a_2020!=.
replace ag_b_04a_units1 = ag_b_04a_2020_units if ag_b_04a_check==1&year==2019
replace ag_b_18 = ag_b_18/100
g area = ag_b_04a_units1*ag_b_18
egen sum_area=sum(area), by(hh_id year) missing /*area planted*/
li hh_id year ag_b_2_plot_roster__id crop_roster_sale__id ag_b_03__1 ag_b_03__2 ///
ag_b_18 ag_b_04a if hh_id==122
*maize plot shd be owned and wheat plot rented
replace ag_b_03__2 = 0 if hh_id == 122&year == 2019&crop_roster_sale__id == 1
replace ag_b_03__1 = 0 if hh_id == 122&year == 2019&crop_roster_sale__id == 4

g ag_b_04a_units1_own = ag_b_04a_units1 if ag_b_03__1 == 1
g ag_b_04a_units1_rentin = ag_b_04a_units1 if ag_b_03__2 == 1
g ag_b_04a_units1_rentout = ag_b_04a_units1 if ag_b_03__3 == 1
replace ag_b_04a_units1_own = ag_b_04a_units1_own/2 if ///
hh_id == 225&year == 2019&crop_roster_sale__id == 1&ag_b_03__2 == 1
replace ag_b_04a_units1_rentin = ag_b_04a_units1_own/2 if ///
hh_id == 225&year == 2019&crop_roster_sale__id == 1&ag_b_03__2 == 1
replace ag_b_04a_units1_own = ag_b_04a_units1_own/2 if ///
hh_id == 225&year == 2019&crop_roster_sale__id == 8&ag_b_03__2 == 1
replace ag_b_04a_units1_rentin = ag_b_04a_units1_own/2 if ///
hh_id == 225&year == 2019&crop_roster_sale__id == 8&ag_b_03__2 == 1
egen sum_ag_b_04a_units1_own=sum(ag_b_04a_units1_own), by(hh_id year) missing /*plot owned*/
egen sum_ag_b_04a_units1_rentin=sum(ag_b_04a_units1_rentin), by(hh_id year) missing /*plot rented*/
preserve
collapse (sum) ag_c_1a_units ag_c_4a_units, by(hh_id year crop_roster_sale__id) 
save "$data\energy_content", replace
restore
preserve
keep hh_id year sum_area sum_ag_b_04a_units1_own sum_ag_b_04a_units1_rentin
duplicates drop 
lab var sum_area "area planted(hectares)"
lab var sum_ag_b_04a_units1_rentin "Land rented in (ha)"
lab var sum_ag_b_04a_units1_own "Land owned (ha)"
save "$data\land_own_ha", replace
restore
**
preserve
drop if missing(ag_b_13)
save "$data\land_quality", replace
restore

**
preserve
collapse (sum) ag_b_21, by(hh_id year)
replace ag_b_21 = 1 if ag_b_21 > 0
save "$data\labor_demands", replace
restore
**
replace ag_c_1a_units = 5010 if hh_id == 638&year == 2019&crop_roster_sale__id == 12
replace ag_c_4a_units = 0 if ag_c_2 == 2&ag_c_5 == 0 | ag_c_5 == .
replace ag_c_9a_units = ag_c_1a_units-ag_c_4a_units
replace ag_c_9a_units = . if ag_c_9a_units <0
*merge with data to get region
mer m:1 hh_id year using "$rawdata\1. R1_R2_Section_A_Interview_Details_zmb.dta", nogen
egen sum_ag_c_5_r = median(ag_c_5), by(hh_a_05b crop_roster_sale__id year) 
egen sum_ag_c_4a_units_r = median(ag_c_4a_units), by(hh_a_05b crop_roster_sale__id year) 
g med_price = sum_ag_c_5_r/sum_ag_c_4a_units_r
g exp_sales = ag_c_9a_units*med_price
replace ag_c_5 = ag_c_1a_units*med_price if hh_id == 122&year == 2019&crop_roster_sale__id == 4
g ag_c_5_1 = ag_c_5 + exp_sales
lab var ag_c_5_1 "crop revenues"
*sum by HH and year
egen sum_ag_c_1a=sum(ag_c_1a_units), by(hh_id year) missing /*production*/
egen sum_ag_c_5=sum(ag_c_5), by(hh_id year) missing /*sales value*/
egen sum_ag_c_5_1=sum(ag_c_5_1), by(hh_id year) missing
egen sum_ag_c_5_maize=sum(ag_c_5) if crop_roster_sale__id == 1, by(hh_id year) missing /*sales value*/
egen sum_ag_c_5_tobbaco=sum(ag_c_5) if crop_roster_sale__id == 2, by(hh_id year) missing /*sales value*/
egen sum_ag_c_5_soya=sum(ag_c_5) if crop_roster_sale__id == 8, by(hh_id year) missing /*sales value*/
*costs
egen sum_ag_c_16=sum(ag_c_16), by(hh_id year) missing
egen sum_ag_c_17=sum(ag_c_17), by(hh_id year) missing
egen sum_ag_c_18=sum(ag_c_18), by(hh_id year) missing
egen sum_ag_b_27b=sum(ag_b_27b), by(hh_id year) missing
egen sum_ag_b_29d=sum(ag_b_29d), by(hh_id year) missing
**
*account stock sales
replace ag_c_4a_units=ag_c_1a_units if ag_c_1a_units<ag_c_4a_units
*impute price using value sales divided by value quant sold
 gen regprice_crop=ag_c_5/ag_c_4a_units
gen prod_value= ag_c_1a_units*regprice_crop if ag_c_1a_units!=. & regprice_crop!=.
egen sum_prod_value=sum(prod_value), by(hh_id year) missing
gen HCI= (sum_ag_c_5/sum_prod_value)*100 if sum_ag_c_5!=. & sum_prod_value!=. 
*replace if HCI is above 100 (slightly)
replace HCI=100 if HCI>100 & HCI!=.
g HCI_maize = (sum_ag_c_5_maize/sum_prod_value)*100 if sum_ag_c_5_maize!=. & sum_prod_value!=. 
replace HCI_maize = 100 if HCI_maize>100&HCI_maize!=.
g HCI_tobbaco = (sum_ag_c_5_tobbaco/sum_prod_value)*100 if sum_ag_c_5_tobbaco!=. & sum_prod_value!=.
replace HCI_tobbaco = 100 if HCI_tobbaco>100&HCI_tobbaco!=.
g HCI_soya = (sum_ag_c_5_soya/sum_prod_value)*100 if sum_ag_c_5_soya!=. & sum_prod_value!=.
replace HCI_soya = 100 if HCI_soya>100&HCI_soya!=.
egen sum_ag_c_4a_units = sum(ag_c_4a_units), by(hh_id year crop_roster_sale__id) missing
egen sum_ag_c_1a_units_1 = sum(ag_c_1a_units), by(hh_id year crop_roster_sale__id) missing
*Duplicates in terms of interview__id sum_ag_c_5
/*gen x=ag_c_2
replace x=. if ag_c_2==2
egen crop_sale=max(x), by(interview__id) 
replace crop_sale=0 if crop_sale==.*/
egen sum_ag_c_1a_units=sum(ag_c_1a_units), by(hh_id year) missing
lab var sum_ag_c_1a_units "Production quantity in kgs"
lab var sum_ag_c_5 "Gross value of crop sales"

preserve
keep hh_id year sum_ag_c_5 sum_prod_value HCI 
duplicates drop 
save tmp, replace
restore

preserve
keep hh_id year HCI_maize HCI_tobbaco HCI_soya
duplicates drop
save tmp1, replace
restore
**
preserve
use tmp1, clear 
keep hh_id year HCI_maize
drop if HCI_maize==.
save tmp2, replace
**
use tmp1, clear 
keep hh_id year HCI_tobbaco
drop if HCI_tobbaco == .
save tmp3, replace
**
use tmp1, clear 
keep hh_id year HCI_soya
drop if HCI_soya == .
save tmp4, replace
**
use tmp2, clear
mer 1:1 hh_id year using tmp3
drop _mer
mer 1:1 hh_id year using tmp4
drop _mer
mer 1:1  hh_id year using tmp
drop _mer
order HCI_maize HCI_tobbaco HCI_soya, after(HCI)
order hh_id
save "$data\HCI commercialisation_hhd_year.dta", replace
restore
*
keep hh_id year crop_roster_sale__id sum_ag_c_1a_units_1 sum_ag_c_4a_units
duplicates drop
drop if crop_roster_sale__id>3&crop_roster_sale__id<7
drop if crop_roster_sale__id==-99
drop if crop_roster_sale__id>8
g prop_sold = sum_ag_c_4a_units/sum_ag_c_1a_units
keep hh_id year crop_roster_sale__id prop_sold
replace prop_sold = prop_sold*100
egen id = group(hh_id year)
reshape wide prop_sold, i(id) j(crop_roster_sale__id)
ren (prop_sold1 prop_sold2 prop_sold3 prop_sold7 prop_sold8) ///
(maize tobacco groundnuts beans soyabeans)
collapse maize tobacco groundnuts beans soyabeans, by(hh_id year)

preserve 
keep hh_id year ag_b_17__*
collapse (sum) ag_b_17__*, by(hh_id year)
for var ag_b_17__*: replace X = 1 if X>1
egen crop_count =rowtotal(ag_b_17__1-ag_b_17__29)
keep hh_id year ag_b_17__1 ag_b_17__2 ag_b_17__3 ag_b_17__7 ag_b_17__8
lab var ag_b_17__1 "Maize"
lab var ag_b_17__2 "Tobacco"
lab var ag_b_17__3 "Groundnuts"
lab var ag_b_17__7 "Common Beans"
lab var ag_b_17__8 "Soya Beans"
ren (ag_b_17__1 ag_b_17__2 ag_b_17__3 ag_b_17__7 ag_b_17__8) ///
(maize tobacco groundnuts beans soyabeans)
so hh_id year
egen id = group(hh_id year)
save "$data\crop_count_grown", replace
restore
*
save "$data\HCI_commercialisation_plot-crop.dta", replace
**
preserve
keep interview__id interview__key year hh_id ag_b_parcel_roster__id ag_b_01_parcel ///
plot_parcel ag_b_2_plot_roster__id crop_roster_sale__id ag_b_24__1 ag_b_24__2 ///
ag_b_24__4 ag_b_24__5 ag_b_24__6 ag_b_24__7 ag_b_27b ag_b_28d__1 ag_b_28d__2 ag_b_29d ///
ag_b_34__0 ag_b_34__1 ag_b_34__2 ag_c_13__1 ag_c_13__2 ag_c_13__3 ag_c_13__4 ///
ag_c_13__5  ag_c_13__6  ag_c_13__7 ag_c_13__8 ag_c_16 ag_c_17 ag_c_18 ag_c_19
for var ag_b_24__1-ag_c_19: g X_tob = X if crop_roster_sale__id == 2
for var ag_b_24__1-ag_c_19: replace X = . if crop_roster_sale__id == 2
collapse (sum) ag_b_24__1-ag_b_29d ag_b_34__0 ag_b_34__1 ag_b_34__2 ag_c_13__1-ag_c_19 ///
ag_b_24__1_tob-ag_c_19_tob, by(hh_id year)
ren (ag_b_24__1 ag_b_24__2 ag_b_24__4 ag_b_24__5 ag_b_24__6 ag_b_24__7 ag_b_27b ///
ag_b_28d__1 ag_b_28d__2 ag_b_29d ag_b_34__0 ag_b_34__1 ag_b_34__2 ///
ag_c_16 ag_c_17 ag_c_18 ag_c_19 ag_b_24__1_tob ag_b_24__2_tob ag_b_24__4_tob ///
ag_b_24__5_tob ag_b_24__6_tob ag_b_24__7_tob ag_b_27b_tob ag_b_28d__1_tob ///
ag_b_28d__2_tob ag_b_29d_tob ag_b_34__0_tob ag_b_34__1_tob ag_b_34__2_tob ///
ag_c_16_tob ag_c_17_tob ag_c_18_tob ag_c_19_tob) ///
(labor_planting labor_seedbad labor_weeding labor_fertapp labor_agrochapp labor_harvest seedcosts ///
fertcosts1 fertcosts2 tillagecosts herbicide_costs pest_costs curing_costs gradingcosts ///
millingcost stroringcosts packagingcosts labor_planting_tob labor_seedbad_tob ///
labor_weeding_tob labor_fertapp_tob labor_agrochapp_tob labor_harvest_tob ///
seedcosts_tob fertcosts1_tob fertcosts2_tob tillagecosts_tob herbicide_costs_tob ///
pest_costs_tob curing_costs_tob gradingcosts_tob millingcost_tob stroringcosts_tob packagingcosts_tob)
egen transportcosts = rowtotal(ag_c_13__1 ag_c_13__2 ag_c_13__3 ag_c_13__4 ///
ag_c_13__5 ag_c_13__6 ag_c_13__7 ag_c_13__8)
egen transportcosts_tob = rowtotal(ag_c_13__1_tob ag_c_13__2_tob ag_c_13__3_tob ///
ag_c_13__4_tob ag_c_13__5_tob ag_c_13__6_tob ag_c_13__7_tob ag_c_13__8_tob)
drop ag_c_13__*
save "$data\labcosts", replace
restore

**
*INCOME VARIABLES
*Timing of income from crop sales
order interview__id interview__key ag_b_2_plot_roster__id
keep interview__id hh_id year ag_b_2_plot_roster__id crop_roster_sale__id ag_c_5 ag_c_6 ag_c_7__* ag_c_2
preserve
keep hh_id year crop_roster_sale__id ag_c_2 ag_b_2_plot_roster__id
egen id = group(hh_id year ag_b_2_plot_roster__id)
drop if crop_roster_sale__id<0
tab ag_c_2, g(sale)
drop sale2 ag_c_2
drop if missing(crop_roster_sale__id)
reshape wide sale1, i(id) j(crop_roster_sale__id)
order hh_id year ag_b_2_plot_roster__id
collapse (sum) sale1*, by( hh_id year)
for var sale11-sale129: replace X = 1 if X>1
egen sale =  rowtotal(sale11-sale129)
replace sale = 1 if sale>1
*Crops sold
g tobacco_sold = (sale12 == 1&sale18 != 1) if sale12 !=.
g soya_sold = (sale18 == 1&sale12 != 1) if sale18 !=.
g tob_soy_sold = (sale12 == 1&sale18 == 1)
g no_tob_soya = (sale12 == 0&sale18 == 0) if sale == 1
replace no_tob_soya = 0 if no_tob_soya == .
g pathway =.
replace pathway = 1 if tobacco_sold == 1
replace pathway = 2 if soya_sold == 1
replace pathway = 3 if tob_soy_sold == 1
replace pathway = 4 if no_tob_soya == 1
replace pathway = 5 if pathway == .
lab val pathway pathway
lab def pathway 1 "Sells tobacco" 2 "Sell soyabeans" 3 "Sells tobacco and soyabeans" 4 "No tobacco and soyabeans" 5 "No Sale"
keep hh_id year tobacco_sold soya_sold tob_soy_sold no_tob_soya pathway sale
lab var tobacco_sold "Sold tobacco"
lab var soya_sold "Sell soya"
lab var tob_soy_sold  "Sell tobacco and soya"
lab var no_tob_soya "Does not sell soya or tobacco"
save "$data\crops_sold", replace
restore
egen id = group(hh_id year ag_b_2_plot_roster__id crop_roster_sale__id)
winsor2 ag_c_5 if ag_c_5!=., replace cuts(1 90)
drop if missing(id)
reshape long ag_c_7__, i(id) j(j)
drop ag_b_2_plot_roster__id crop_roster_sale__id interview__id
order hh_id year
tostring j, g(month)
drop j
g t_t=.
byso id :egen tot = total(ag_c_7__) /*to be used to clean ag_c_6*/
replace t_t=1 if ag_c_6!=100&tot==1
g ag_c_6_1 = ag_c_5*(ag_c_6/100)
drop ag_c_6
replace ag_c_6_1 = ag_c_5 if t_t == 1 
drop t_t tot
//replace hh_e_17d = 0 if hh_id == 108
g balance = ag_c_5-ag_c_6_1 /*balance of income left after removing the highest income*/
g ag_c_7 = ag_c_7__ if ag_c_7__!=1
replace ag_c_7 = 0 if ag_c_7 == .
byso id: egen tot_ag_c_7=total(ag_c_7) /*total for months after removing months with high value ranked 1*/
egen rank_ag_c_7 = rank(-ag_c_7), by(id)
replace rank_ag_c_7 = 0 if ag_c_7 == 0
replace rank_ag_c_7 = 1 + rank_ag_c_7 if rank_ag_c_7>0
drop ag_c_7
g cropsale_month = (rank_ag_c_7/tot_ag_c_7)*balance
replace cropsale_month = ag_c_6_1 if ag_c_7__ == 1

collapse (sum) ag_c_5 cropsale_month, by(hh_id year month)
ren ag_c_5 tot_cropsales
mer m:1 hh_id year using "$data\labcosts", nogen
egen totcost_crops = rowtotal(labor_planting-transportcosts_tob)
egen tot_inputcosts =  rowtotal(seedcosts-stroringcosts packagingcosts-transportcosts_tob)
winsor2 tot_inputcosts if tot_inputcosts!=., replace cuts(1 90)
winsor2 totcost_crops if totcost_crops!=., replace cuts(1 90)
winsor2 tot_cropsales if tot_cropsales!=., replace cuts(1 90)
g crop_income = tot_cropsales-totcost_crops
byso hh_id year: egen peaksales =  max(cropsale_month)
g byte highsales = (cropsale_month == peaksales) & !missing(cropsale_month, peaksales)
drop peaksales
winsor2 seedcosts fertcosts1 fertcosts2 tillagecosts herbicide_costs pest_costs ///
curing_costs gradingcosts millingcost stroringcosts packagingcosts seedcosts_tob ///
fertcosts1_tob fertcosts2_tob tillagecosts_tob herbicide_costs_tob pest_costs_tob ///
curing_costs_tob gradingcosts_tob millingcost_tob stroringcosts_tob packagingcosts_tob ///
transportcosts transportcosts_tob, replace cuts(1 90)
for var seedcosts fertcosts1 fertcosts2 tillagecosts herbicide_costs pest_costs ///
curing_costs gradingcosts millingcost stroringcosts packagingcosts seedcosts_tob ///
fertcosts1_tob fertcosts2_tob tillagecosts_tob herbicide_costs_tob pest_costs_tob ///
curing_costs_tob gradingcosts_tob millingcost_tob stroringcosts_tob packagingcosts_tob ///
transportcosts transportcosts_tob: replace X = 0 if highsales!=1
g byte begseas = (month == "11") & !missing(month)
g byte midseas = (month == "12") & !missing(month)
g byte harvseas = (month == "4") & !missing(month)
for var labor_planting labor_seedbad labor_planting_tob labor_seedbad_tob: replace X = 0 if begseas!=1
for var labor_weeding labor_fertapp labor_agrochapp labor_weeding_tob ///
labor_fertapp_tob labor_agrochapp_tob: replace X = 0 if midseas!=1
for var labor_harvest labor_harvest_tob: replace X = 0 if harvseas!=1
egen totcost_crops_month = rowtotal(labor_planting-transportcosts_tob)
winsor2 totcost_crops_month, replace cuts(1 90)
g cropinc_month = cropsale_month-totcost_crops_month
drop highsales begseas midseas harvseas
save "$data\cropsales_month_long", replace
/*byso hh_id year: egen months_cropsale = total(cropsale_month>0)
reshape wide cropsale_month, i(hh_id year) j(month) string
order tot_cropsales, after(hh_id)
order hh_id year
save "$data\cropsales_month_wide", replace*/
**
*Regular pay
use "$rawdata\12. R1_R2_Section_E1_Regular_zmb.dta", clear
order interview__id interview__key regular_employ__id hh_id
keep interview__id hh_e_3 hh_e_4a hh_e_4b__1-hh_e_4b__12 hh_e_4c hh_id year
collapse (sum) hh_e_3 hh_e_4b__1-hh_e_4b__12 hh_e_4c, by(hh_id year)
for var hh_e_4b__*: replace X = 1 if X > 0
reshape long hh_e_4b__, i(hh_id year) j(j)
replace hh_e_4c = 0 if hh_e_4b__ == 0
drop hh_e_4b__
ren (j hh_e_3 hh_e_4c) (month totinc_regular monthlyinc_regular)
save "$data\regular_inc_long", replace
**
byso hh_id year: egen months = total(monthlyinc_regular>0)
reshape wide monthlyinc_regular, i(hh_id year) j(month)
order months, before(monthlyinc_regular1)
save "$data\regular_pay", replace
**
*Income from casual/seasonal employment
use "$rawdata\13. R1_R2_Section_E1_Casual_zmb.dta", clear
keep hh_e_12 hh_id year
collapse (sum) hh_e_12, by(hh_id year)
order hh_id year
so hh_id year
ren hh_e_12 casual
save "$data\casual.dta", replace
**

*Income from household enterprises
use "$rawdata\14. R1_R2_Section_E2_zmb.dta", clear
keep hh_id year panel_id hh_e_16 hh_e_17d hh_e_17c__* hh_e_18
duplicates tag hh_id year , g(tagid)
byso hh_id year: egen tot_entcost = total(hh_e_18)
winsor2 tot_entcost if tot_entcost!=., replace cuts(1 85)
winsor2 hh_e_16 if hh_e_16!=., replace cuts(1 85)
winsor2 hh_e_18 if hh_e_18!=., replace cuts(1 85)
winsor2 hh_e_17d if hh_e_17d!=., replace cuts(1 85)
preserve
keep if tagid >=1
save "$data\duplicates", replace
restore
drop if tagid >=1
drop tagid
reshape long hh_e_17c__, i(hh_id year) j(j)
order hh_e_17c__, after(j)
*some hhlds reported receiving income in one month but not shown clearly in the data
g t_t=.
byso hh_id year:egen tt=total( hh_e_17c__)
replace t_t=1 if hh_e_16!=hh_e_17d&tt==1
replace hh_e_17d = hh_e_16 if t_t == 1 
drop t_t tt
replace hh_e_17d = 0 if hh_id == 108
g balance = hh_e_16-hh_e_17d /*balance of income left after removing the highest income*/
g hh_e_17c = hh_e_17c__ if hh_e_17c__!=1
replace hh_e_17c = 0 if hh_e_17c == .
byso hh_id year: egen tot_hh_e_17c=total(hh_e_17c) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_17c = rank(-hh_e_17c), by(hh_id year)
replace rank_hh_e_17c = 0 if hh_e_17c == 0
replace rank_hh_e_17c = 1 + rank_hh_e_17c if rank_hh_e_17c>0
drop hh_e_17c
g month_inc_ent = (rank_hh_e_17c/tot_hh_e_17c)*balance
replace month_inc_ent = hh_e_17d if hh_e_17c__ == 1
keep hh_id year j hh_e_16 month_inc_ent hh_e_18 tot_entcost
ren (j hh_e_16) (month totinc_enter)
replace month_inc_ent=0 if month_inc_ent == .&totinc_enter != .a&totinc_enter != .
byso hh_id year: egen months_ent = total(month_inc_ent>0)
g hh_ent_inc = totinc_enter-tot_entcost
g net_month_inc_ent = month_inc_ent - hh_e_18
save "$data\hh_ent_inc_long", replace
/*reshape wide month_inc_ent, i(hh_id year) j(month)
order totinc_enter, after(year)
save "$data\hh_ent_inc1", replace*/
**
use "$data\duplicates", clear
drop tagid 
egen id = group(year panel_id)
reshape long hh_e_17c__, i(id) j(j)
ren j month
order hh_e_17c__, after(month)
g t_t=.
byso hh_id year id:egen tt=total( hh_e_17c__)
replace t_t=1 if hh_e_16!=hh_e_17d&tt==1
replace hh_e_17d = hh_e_16 if t_t == 1 
drop t_t tt
g balance = hh_e_16-hh_e_17d /*balance of income left after removing the highest income*/
g hh_e_17c = hh_e_17c__ if hh_e_17c__!=1
replace hh_e_17c = 0 if hh_e_17c == .
byso hh_id year id: egen tot_hh_e_17c=total(hh_e_17c) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_17c = rank(-hh_e_17c), by(hh_id year id)
replace rank_hh_e_17c = 0 if hh_e_17c == 0
replace rank_hh_e_17c = 1 + rank_hh_e_17c if rank_hh_e_17c>0
drop hh_e_17c
g month_inc_ent = (rank_hh_e_17c/tot_hh_e_17c)*balance
replace month_inc_ent = hh_e_17d if hh_e_17c__ == 1
keep hh_id year month hh_e_16 month_inc_ent hh_e_18 tot_entcost
ren hh_e_16 totinc_enter
replace month_inc_ent=0 if month_inc_ent == .&totinc_enter != .a&totinc_enter != .
g hh_ent_inc = totinc_enter-tot_entcost
g net_month_inc_ent = month_inc_ent - hh_e_18
collapse (sum) totinc_enter month_inc_ent hh_ent_inc net_month_inc_ent, by(hh_id year month)
byso hh_id year: egen months_ent = total(month_inc_ent>0)
save "$data\hh_ent_inc1_long", replace
/*reshape wide month_inc_ent, i(hh_id year) j(month)
order totinc_enter, after(year)
save "$data\hh_ent_inc2", replace
append using "$data\hh_ent_inc1"
save "$data\hh_ent_income", replace*/
*long data
use "$data\hh_ent_inc_long", clear
append using "$data\hh_ent_inc1_long"
save "$data\hh_ent_income_long_fin", replace
**
*Income from livestock sales
use "$rawdata\11. R1_R2_Section_D_zmb.dta", clear
order interview__id interview__key
mer m:1 hh_id year using "$rawdata\1. R1_R2_Section_A_Interview_Details_zmb.dta", nogen
egen med_ag_d_13b = median(ag_d_13b), by(hh_a_05b livestockroster__id year)
egen med_ag_d_14 = median(ag_d_14), by(hh_a_05b livestockroster__id year)
*unit values
g med_unitval_live = med_ag_d_14/med_ag_d_13b
g live_consumedval = ag_d_5*med_unitval_live
for var ag_d_14 live_consumedval: replace X = 0 if X==.
g ag_d_14_1 = ag_d_14+live_consumedval
drop ag_d_14
ren ag_d_14_1 ag_d_14
keep hh_id year ag_d_14 ag_d_11 ag_d_12 ag_d_12b ag_d_12c ag_d_7b
collapse (sum) ag_d_14 ag_d_11 ag_d_12 ag_d_12b ag_d_12c ag_d_7b, by(hh_id year)
egen tot_livecosts =  rowtotal(ag_d_11 ag_d_12 ag_d_12b ag_d_12c ag_d_7b)
winsor2 ag_d_14 if ag_d_14!=., replace cuts(1 85)
save "$data\livestocksale_inc", replace
**
*Livestock Produce
use "$rawdata\11. R1_R2_Section_D_zmb.dta", clear
order interview__id interview__key
keep hh_id year livestockroster__id livestock_produce__id ag_d_19 ag_d_20a__1-ag_d_20c
//drop if interview__id == "00d88b6fe84d4e0abdc102154e065191"
egen id = group(hh_id year livestockroster__id livestock_produce__id)
winsor2 ag_d_19 if ag_d_19!=., replace cuts(1 85)
winsor2 ag_d_20c if ag_d_20c!=., replace cuts(1 85)
reshape long ag_d_20a__ ag_d_20b__, i(id)
ren _j month
drop livestock_produce__id livestockroster__id

g t_t=.
byso id:egen tot=total(ag_d_20b__)
replace t_t=1 if ag_d_19!=ag_d_20c&tot==1
replace ag_d_20c = ag_d_19 if t_t == 1 
drop t_t tot
//replace hh_e_17d = 0 if hh_id == 108
g balance = ag_d_19-ag_d_20c /*balance of income left after removing the highest income*/
g ag_d_20b = ag_d_20b__ if ag_d_20b__!=1
replace ag_d_20b = 0 if ag_d_20b == .
byso id: egen tot_ag_d_20b=total(ag_d_20b) /*total for months after removing months with high value ranked 1*/
egen rank_ag_d_20b = rank(-ag_d_20b), by(id)
replace rank_ag_d_20b = 0 if ag_d_20b == 0
replace rank_ag_d_20b = 1 + rank_ag_d_20b if rank_ag_d_20b>0
drop ag_d_20b
g livprodsales_month = (rank_ag_d_20b/tot_ag_d_20b)*balance
replace livprodsales_month = ag_d_20c if ag_d_20b__ == 1
collapse (sum) ag_d_19 livprodsales_month, by(hh_id year month)
order hh_id year month
so hh_id year month
mer m:1 hh_id year using "$data\livestocksale_inc", nogen
egen tot_livesales = rowtotal(ag_d_19 ag_d_14)
winsor2 tot_livecosts if tot_livecosts!=., replace cuts(1 85)
g live_income = tot_livesales-tot_livecosts
save "$data\livestock_produce_long", replace
byso hh_id year: egen months_livestock = total(livprodsales_month>0)
*
drop if missing(month)
reshape wide livprodsales_month, i(hh_id year) j(month)
order ag_d_19, after(hh_id)
order hh_id
save "$data\livestock_produce_wide", replace
**
*OTHER INCOMES 
use "$rawdata\15. R1_R2_Section_E3_zmb.dta", clear
preserve
keep hh_id year hh_e_20_1 hh_e_21b1__* hh_e_21c1__*  hh_e_21d1
drop if hh_e_20_1 == .
winsor2 hh_e_20_1, replace cuts(1 90)
winsor2 hh_e_21d1 if hh_e_21d1!=., replace cuts(1 90)
reshape long hh_e_21b1__ hh_e_21c1__, i(hh_id year) 
g t_t=.
byso hh_id year:egen tt=total(hh_e_21c1__)
replace t_t=1 if hh_e_20_1!=hh_e_21d1&tt==1
replace hh_e_21d1 = hh_e_20_1 if t_t == 1 
drop t_t tt
//replace hh_e_17d = 0 if hh_id == 108
g balance = hh_e_20_1-hh_e_21d1 /*balance of income left after removing the highest income*/
g hh_e_21c1 = hh_e_21c1__ if hh_e_21c1__!=1
replace hh_e_21c1 = 0 if hh_e_21c1 == .
byso hh_id year: egen tot_hh_e_21c1=total(hh_e_21c1) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_21c1 = rank(-hh_e_21c1), by(hh_id year)
replace rank_hh_e_21c1 = 0 if hh_e_21c1 == 0
replace rank_hh_e_21c1 = 1 + rank_hh_e_21c1 if rank_hh_e_21c1>0
drop hh_e_21c1
g month_inc_other = (rank_hh_e_21c1/tot_hh_e_21c1)*balance
replace month_inc_other = hh_e_21d1 if hh_e_21c1__ == 1
keep hh_id year _j hh_e_20_1 month_inc_other
ren (_j hh_e_20_1) (month totinc_other)
replace month_inc_other=0 if month_inc_other == .&totinc_other != .a&totinc_other != .
byso hh_id year: egen months_other = total(month_inc_other>0)
save "$data\hh_other_inc_long", replace
reshape wide month_inc_other, i(hh_id year) j(month)
order totinc_other months_other, after(year)
save "$data\hh_other_inc_wide", replace
restore
**
*Gift income
preserve
keep hh_id year hh_e_20_2 hh_e_21a2  hh_e_21b2__* hh_e_21c2__* hh_e_21d2 
drop if hh_e_20_2 == .
winsor2 hh_e_20_2 if hh_e_20_2!=., replace cuts(1 90)
winsor2 hh_e_21d2 if hh_e_21d2!=., replace cuts(1 90)
reshape long hh_e_21b2__ hh_e_21c2__, i(hh_id year) 
g t_t=.
byso hh_id year:egen tt=total(hh_e_21c2__)
replace t_t=1 if hh_e_20_2!=hh_e_21d2&tt==1
replace hh_e_21d2 = hh_e_20_2 if t_t == 1 
drop t_t tt
//replace hh_e_17d = 0 if hh_id == 108
g balance = hh_e_20_2-hh_e_21d2 /*balance of income left after removing the highest income*/
g hh_e_21c2 = hh_e_21c2__ if hh_e_21c2__!=1
replace hh_e_21c2 = 0 if hh_e_21c2 == .
byso hh_id year: egen tot_hh_e_21c2=total(hh_e_21c2) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_21c2 = rank(-hh_e_21c2), by(hh_id year)
replace rank_hh_e_21c2 = 0 if hh_e_21c2 == 0
replace rank_hh_e_21c2 = 1 + rank_hh_e_21c2 if rank_hh_e_21c2>0
drop hh_e_21c2
g month_inc_gift = (rank_hh_e_21c2/tot_hh_e_21c2)*balance
replace month_inc_gift = hh_e_21d2 if hh_e_21c2__ == 1
keep hh_id year hh_e_21a2 _j hh_e_20_2 month_inc_gift
ren (_j hh_e_20_2) (month totinc_gift)
replace month_inc_gift=0 if month_inc_gift == .&totinc_gift != .a&totinc_gift != .
save "$data\hh_other_gift_long", replace
reshape wide month_inc_gift, i(hh_id year) j(month)
order totinc_gift hh_e_21a2, after(year)
save "$data\hh_other_gift_wide", replace
restore
**
*Safety nets income
preserve
keep hh_id year hh_e_20_3 hh_e_21a3 hh_e_21b3__* hh_e_21c3__* hh_e_21d3 
drop if hh_e_20_3 == .
winsor2 hh_e_20_3 if hh_e_20_3!=., replace cuts(1 90)
winsor2 hh_e_21d3 if hh_e_21d3!=., replace cuts(1 90)
reshape long hh_e_21b3__ hh_e_21c3__, i(hh_id year) 
g t_t=.
byso hh_id year:egen tt=total(hh_e_21c3__)
replace t_t=1 if hh_e_20_3!=hh_e_21d3&tt==1
replace hh_e_21d3 = hh_e_20_3 if t_t == 1 
drop t_t tt
//replace hh_e_17d = 0 if hh_id == 108
g balance = hh_e_20_3-hh_e_21d3 /*balance of income left after removing the highest income*/
g hh_e_21c3 = hh_e_21c3__ if hh_e_21c3__!=1
replace hh_e_21c3 = 0 if hh_e_21c3 == .
byso hh_id year: egen tot_hh_e_21c3=total(hh_e_21c3) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_21c3 = rank(-hh_e_21c3), by(hh_id year)
replace rank_hh_e_21c3 = 0 if hh_e_21c3 == 0
replace rank_hh_e_21c3 = 1 + rank_hh_e_21c3 if rank_hh_e_21c3>0
drop hh_e_21c3
g month_inc_safety = (rank_hh_e_21c3/tot_hh_e_21c3)*balance
replace month_inc_safety = hh_e_21d3 if hh_e_21c3__ == 1
keep hh_id year hh_e_21a3 _j hh_e_20_3 month_inc_safety
ren (_j hh_e_20_3) (month totinc_safety)
replace month_inc_safety=0 if month_inc_safety == .&totinc_safety != .a&totinc_safety != .
save "$data\hh_other_safety_long", replace
reshape wide month_inc_safety, i(hh_id year) j(month)
order totinc_safety hh_e_21a3, after(year)
save "$data\hh_other_safety_wide", replace
restore
**
keep hh_id year hh_e_20_4__0 hh_e_21a4__0 hh_e_21a4__0 hh_e_21b4_*__0 hh_e_21c4_*__0 hh_e_21d4__0
drop if hh_e_20_4__0 == .
winsor2 hh_e_20_4__0, replace cuts(1 95)
winsor2 hh_e_21d4__0 if hh_e_21d4__0!=., replace cuts(1 90)
ren (hh_e_21b4_1__0 hh_e_21b4_2__0 hh_e_21b4_3__0 hh_e_21b4_4__0 hh_e_21b4_5__0 ///
hh_e_21b4_6__0 hh_e_21b4_7__0 hh_e_21b4_8__0 hh_e_21b4_9__0 hh_e_21b4_10__0 ///
hh_e_21b4_11__0 hh_e_21b4_12__0 hh_e_21c4_1__0 hh_e_21c4_2__0 hh_e_21c4_3__0 ///
hh_e_21c4_4__0 hh_e_21c4_5__0 hh_e_21c4_6__0 hh_e_21c4_7__0 hh_e_21c4_8__0 ///
hh_e_21c4_9__0 hh_e_21c4_10__0 hh_e_21c4_11__0 hh_e_21c4_12__0) ///
(hh_e_21b4_1 hh_e_21b4_2 hh_e_21b4_3 hh_e_21b4_4 hh_e_21b4_5 ///
hh_e_21b4_6 hh_e_21b4_7 hh_e_21b4_8 hh_e_21b4_9 hh_e_21b4_10 ///
hh_e_21b4_11 hh_e_21b4_12 hh_e_21c4_1 hh_e_21c4_2 hh_e_21c4_3 ///
hh_e_21c4_4 hh_e_21c4_5 hh_e_21c4_6 hh_e_21c4_7 hh_e_21c4_8 ///
hh_e_21c4_9 hh_e_21c4_10 hh_e_21c4_11 hh_e_21c4_12)
reshape long hh_e_21b4_ hh_e_21c4_, i(hh_id year)
g t_t=.
byso hh_id year:egen tt=total(hh_e_21c4_)
replace t_t=1 if hh_e_20_4__0!=hh_e_21d4__0&tt==1
replace hh_e_21d4__0 = hh_e_20_4__0 if t_t == 1 
drop t_t tt
//replace hh_e_17d = 0 if hh_id == 108
g balance = hh_e_20_4__0-hh_e_21d4__0 /*balance of income left after removing the highest income*/
g hh_e_21c4 = hh_e_21c4_ if hh_e_21c4_!=1
replace hh_e_21c4 = 0 if hh_e_21c4 == .
byso hh_id year: egen tot_hh_e_21c4=total(hh_e_21c4) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_21c4 = rank(-hh_e_21c4), by(hh_id year)
replace rank_hh_e_21c4 = 0 if hh_e_21c4 == 0
replace rank_hh_e_21c4 = 1 + rank_hh_e_21c4 if rank_hh_e_21c4>0
drop hh_e_21c4
g month_inc_o_other = (rank_hh_e_21c4/tot_hh_e_21c4)*balance
replace month_inc_o_other = hh_e_21d4__0 if hh_e_21c4_ == 1
keep hh_id year _j hh_e_20_4__0 hh_e_21a4__0 month_inc_o_other
ren (_j hh_e_20_4__0) (month totinc_o_other)
replace month_inc_o_other=0 if month_inc_o_other == .&totinc_o_other != .a&totinc_o_other != .
save "$data\hh_other_o_other_long", replace
reshape wide month_inc_o_other, i(hh_id year) j(month)
order totinc_o_other hh_e_21a4__0, after(year)
save "$data\hh_other_o_other_wide", replace
**
*Food Security
use "$rawdata\20. R1_R2_Section_F1_zmb.dta", replace
order hh_id
for var hh_f_2__*: tab X, mi
egen seasons =  rowtotal(hh_f_3__1-hh_f_3__12)
recode seasons (2/4 = 2) (5/12 = 3), g(seasons1)
egen hunger_index = rowtotal(hh_f_2__1-hh_f_2__8)
egen HFIAS = rowtotal(hunger_index seasons1)
recode HFIAS (0/1 = 1) (2/4 = 2) (5/12 = 3), g(HFIAS_cat)
lab val HFIAS_cat HFIAS_cat
lab def HFIAS_cat 1 "Low" 2 "Medium" 3 "High"
lab var HFIAS_cat "HFIAS"
recode HFIAS (0/1 = 1) (2/11 = 0), g(food_sec)
**
*Dietary Diversity
g hh_female_10_11_13 = (hh_f_1b_female__10 == 1 | hh_f_1b_female__11 == 1 | hh_f_1b_female__13 == 1)
g hh_male_10_11_13 = (hh_f_1b_male__10 == 1 | hh_f_1b_male__11 == 1 | hh_f_1b_male__13 == 1)
g hh_female_12_14 = (hh_f_1b_female__12 == 1 | hh_f_1b_female__14 == 1)
g hh_male_12_14 = (hh_f_1b_male__12 == 1 | hh_f_1b_male__14 == 1)
g hh_female_6_7_15 = (hh_f_1b_female__6 == 1 | hh_f_1b_female__7 == 1 | hh_f_1b_female__15 == 1)
g hh_male_6_7_15 = (hh_f_1b_male__6 == 1 | hh_f_1b_male__7 == 1 | hh_f_1b_male__15 == 1)
g hh_female_3_4 = (hh_f_1b_female__3 == 1 | hh_f_1b_female__4 == 1)
g hh_male_3_4 = (hh_f_1b_male__3 == 1 | hh_f_1b_male__4 == 1)
g hh_female_16_17 = (hh_f_1b_female__16 == 1 | hh_f_1b_female__17 == 1)
g hh_male_16_17 = (hh_f_1b_male__16 == 1 | hh_f_1b_male__17 == 1)
g hh_female_18_20 = (hh_f_1b_female__18 == 1 | hh_f_1b_female__20 == 1)
g hh_male_18_20 = (hh_f_1b_male__18 == 1 | hh_f_1b_male__20 == 1)
egen HDDS_m = rowtotal(hh_f_1b_male__1 hh_f_1b_male__2 hh_f_1b_male__9 ///
hh_f_1b_male__8 hh_f_1b_male__5 hh_f_1b_male__19 hh_male_10_11_13 hh_male_12_14 ///
hh_male_6_7_15 hh_male_3_4 hh_male_16_17 hh_male_18_20)
egen HDDS_f = rowtotal(hh_f_1b_female__1 hh_f_1b_female__2 hh_f_1b_female__8 ///
hh_f_1b_female__9 hh_f_1b_female__5 hh_f_1b_female__19 hh_female_10_11_13 ///
hh_female_12_14 hh_female_6_7_15 hh_female_3_4 hh_female_16_17 hh_female_18_20)
egen HDDS = rowmean(HDDS_m HDDS_f)
*WDDS
g hh_women_1_2 = (hh_f_1b_female__1 == 1 | hh_f_1b_female__2 == 1)
g hh_women_11_12_16 = (hh_f_1b_female__11 == 1 | hh_f_1b_female__12 == 1 | ///
 hh_f_1b_female__16 == 1)
g hh_women_13_14 = (hh_f_1b_female__13 == 1 | hh_f_1b_female__14 == 1)
g hh_women_7_8_15 = (hh_f_1b_female__7 == 1 | hh_f_1b_female__8 == 1 | ///
 hh_f_1b_female__15 == 1)
g hh_women_3_4 = (hh_f_1b_female__3 == 1 | hh_f_1b_female__4 == 1)
egen WDDS = rowtotal(hh_women_1_2 hh_women_11_12_16 hh_women_13_14 hh_women_7_8_15 ///
hh_women_3_4 hh_f_1b_female__10 hh_f_1b_female__6 hh_f_1b_female__9)
*
lab var HDDS "Household dietary diversity"
lab var HDDS_m "Male household dietary diversity"
lab var HDDS_f "Female household dietary diversity score"
lab var WDDS "Women dietary diversity score"
recode HDDS (0/3 = 1) (3.5/7 = 2) (7.5/11 = 3), g(HDDS_cat)
lab val HDDS_cat HDDS_cat
lab def HDDS_cat 1 "Low" 2 "Medium" 3 "High"
**
*Seasonal hunger months
egen seasonal_hunger = rowtotal(hh_f_3__12 hh_f_3__1 hh_f_3__2 hh_f_3__3 hh_f_3__4 hh_f_3__5)
recode seasonal_hunger (0 = 1) (1/3 = 2) (4/6 = 3), g(seas_hunger_cat)
lab val seas_hunger_cat seas_hunger_cat
lab def seas_hunger_cat 1 "Low" 2 "Medium" 3 "High"

g byte foodsec_trans = .
byso hh_id: replace foodsec_trans = 1 if food_sec[_n+1] == 1&food_sec[_n] == 0
byso hh_id: replace foodsec_trans = 2 if food_sec[_n+1] == 0&food_sec[_n] == 1
byso hh_id: replace foodsec_trans = 3 if food_sec[_n+1] == 0&food_sec[_n] == 0
byso hh_id: replace foodsec_trans = 4 if food_sec[_n+1] == 1&food_sec[_n] == 1
byso hh_id: replace foodsec_trans = 1 if food_sec[_n] == 1&food_sec[_n-1] == 0
byso hh_id: replace foodsec_trans = 2 if food_sec[_n] == 0&food_sec[_n-1] == 1
byso hh_id: replace foodsec_trans = 3 if food_sec[_n] == 0&food_sec[_n-1] == 0
byso hh_id: replace foodsec_trans = 4 if food_sec[_n] == 1&food_sec[_n-1] == 1
keep hh_id year hh_f_3__1-foodsec_trans
drop hh_women_1_2-hh_women_3_4 hh_female_10_11_13-hh_male_18_20
save "$data\seasonal_hunger", replace
**
*Retained food crops converted to Energy content
use "$data\energy_content", clear
mer m:1 crop_roster_sale__id using "$data\calories.dta"
keep if _mer == 3
drop _mer
replace ag_c_4a_units = ag_c_1a_units if ag_c_4a_units>ag_c_1a_units
g retained = ag_c_1a_units-ag_c_4a_units
g cal_int = calorieskcal100grams/365
save "$data\energy_content1", replace
**
use "$rawdata\2. R1_R2_Section_A_HH_Members_zmb.dta", clear
byso hh_id year: egen male_le_1 = total(hh_a_15 < 1 & hh_a_14 == 1) /*male <1 */
byso hh_id year: egen female_le_1 = total(hh_a_15 < 1&hh_a_14 == 2) /*female <1*/
byso hh_id year: egen male_1_3 = total(inrange(hh_a_15, 1, 3) & hh_a_14 == 1)
byso hh_id year: egen female_1_3 = total(inrange(hh_a_15, 1, 3) & hh_a_14 == 2)
byso hh_id year: egen male_4_6 = total(inrange(hh_a_15, 4, 6) & hh_a_14 == 1)
byso hh_id year: egen female_4_6 = total(inrange(hh_a_15, 4, 6) & hh_a_14 == 2)
byso hh_id year: egen male_7_9 = total(inrange(hh_a_15, 7, 9) & hh_a_14 == 1)
byso hh_id year: egen female_7_9 = total(inrange(hh_a_15, 7, 9) & hh_a_14 == 2)
byso hh_id year: egen male_10_12 = total(inrange(hh_a_15, 10, 12) & hh_a_14 == 1)
byso hh_id year: egen female_10_12 = total(inrange(hh_a_15, 10, 12) & hh_a_14 == 2)
byso hh_id year: egen male_13_15 = total(inrange(hh_a_15, 13, 15) & hh_a_14 == 1)
byso hh_id year: egen female_13_15 = total(inrange(hh_a_15, 13, 15) & hh_a_14 == 2)
byso hh_id year: egen male_16_19 = total(inrange(hh_a_15, 16, 19) & hh_a_14 == 1)
byso hh_id year: egen female_16_19 = total(inrange(hh_a_15, 16, 19) & hh_a_14 == 2)
byso hh_id year: egen male_20_ = total(hh_a_15 > 20 & hh_a_14 == 1)
byso hh_id year: egen female_20_ = total(hh_a_15 > 20 & hh_a_14 == 2)
keep hh_id year male_le_1-female_20_
duplicates drop
g AME = 0.27*(male_le_1+female_le_1)+0.45*(male_1_3+female_1_3)+0.61*(male_4_6+female_4_6) + ///
0.73*(male_7_9+female_7_9)+0.86*male_10_12+0.78*female_10_12+0.96*male_13_15 ///
+0.83*female_13_15+1.02*male_16_19+0.77*female_16_19+male_20_+0.73*female_20_
keep hh_id year AME
save "$data\AME", replace
*
use "$data\energy_content1", clear
mer m:1 hh_id year using "$data\AME"
keep if _mer == 3
drop _mer
g cal_int1 = cal_int/AME
g k_cal_retained = retained*cal_int1
collapse (sum) k_cal_retained, by(hh_id year)
save "$data\retainedfood_kcal", replace
**
*Creating table 1:
use "$data\cropsales_month_long", clear
g mth = real(month)
drop month
ren mth month
order month, before(tot_cropsales)
so hh_id year
mer m:1 hh_id year using "$data\livestocksale_inc"
drop _mer
mer m:1 hh_id year using "$data\casual.dta", nogen
so hh_id year month
mer 1:1 hh_id year month using "$data\livestock_produce_long", nogen
mer 1:1 hh_id year month using "$data\regular_inc_long", nogen
mer 1:1 hh_id year month using "$data\hh_ent_inc_long", nogen
mer 1:1 hh_id year month using "$data\hh_other_inc_long", nogen
mer 1:1 hh_id year month using "$data\hh_other_gift_long", nogen
mer 1:1 hh_id year month using "$data\hh_other_safety_long", nogen
mer 1:1 hh_id year month using "$data\hh_other_o_other_long", nogen
so hh_id year
mer m:1 hh_id year using "$data\crop_count_grown", nogen
mer m:1  hh_id year using "$data\crops_sold", nogen
for var crop_income live_income hh_ent_inc: replace X = . if X <0

egen totincome = rowtotal(crop_income live_income casual totinc_regular ///
hh_ent_inc totinc_other totinc_gift totinc_safety totinc_o_other)
egen totalcosts = rowtotal(tot_livecosts totcost_crops tot_entcost)
preserve
keep hh_id year totincome tot_livesales tot_inputcosts totalcosts totinc_gift crop_income live_income casual ///
totinc_regular hh_ent_inc totinc_other totinc_safety totinc_o_other month
drop if missing(month)
reshape wide totincome tot_inputcosts tot_livesales totalcosts totinc_gift crop_income live_income casual ///
totinc_regular hh_ent_inc totinc_other totinc_safety totinc_o_other, i(hh_id year) j(month)
keep hh_id year tot_inputcosts1 tot_livesales1 crop_income1-totalcosts1
save "$data\inco", replace
restore
egen totinc_month = rowtotal(cropinc_month net_month_inc_ent livprodsales_month monthlyinc_regular ///
month_inc_other month_inc_gift month_inc_safety month_inc_o_other)
drop ag_b_17__1-ag_b_17__29
save "$data\totincome_month_long", replace
winsor2 totincome if totincome!=., replace cuts(10 90)
//winsor2 totinc_month if totinc_month!=., replace cuts(10 90)
winsor2 crop_income if crop_income!=., replace cuts(10 90)
//winsor2 cropinc_month if cropinc_month!=., replace cuts(10 90)
winsor2 live_income if live_income!=., replace cuts(25 85)
winsor2 casual if casual!=., replace cuts(1 89)
winsor2 ag_d_19 if ag_d_19!=., replace cuts(1 95)
winsor2 totinc_regular if totinc_regular!=., replace cuts(1 94)
/*winsor2 monthlyinc_regular if monthlyinc_regular!=., replace cuts(1 94)
winsor2 hh_ent_inc if hh_ent_inc!=., replace cuts(25 85)
winsor2 net_month_inc_ent if net_month_inc_ent!=., replace cuts(25 85)
winsor2 totinc_other if totinc_other!=., replace cuts(1 90)
winsor2 month_inc_other if month_inc_other!=., replace cuts(1 90)
winsor2 totinc_gift month_inc_gift if totinc_gift!=. & month_inc_gift!=., replace cuts(1 90)
winsor2 totinc_safety month_inc_safety if totinc_safety!=. & month_inc_safety!=., replace cuts(1 90)
winsor2 totinc_o_other month_inc_o_other if totinc_o_other!=. & month_inc_o_other!=., replace cuts(1 95)*/
g totinc_month_tb_soygrow = totinc_month if tob_soy_sold == 1
g totinc_month_tbgrow = totinc_month if tobacco_sold == 1
g totinc_month_soygrow = totinc_month if soya_sold == 1
g totinc_month_notb_sy = totinc_month if no_tob_soya == 1
g totincome_tb_soygrow = totincome if tob_soy_sold == 1
g totincome_tbgrow = totincome if tobacco_sold == 1
g totincome_soygrow = totincome if soya_sold == 1
g totincome_notb_sy = totincome if no_tob_soya == 1
g tot_cropsales_tb_soygrow = crop_income if tob_soy_sold == 1
g tot_cropsales_tbgrow = crop_income if tobacco_sold == 1
g tot_cropsales_soygrow = crop_income if soya_sold == 1
g tot_cropsales_notb_sygrow = crop_income if no_tob_soya == 1
g cropsale_month_tb_soygrow = cropinc_month if tob_soy_sold == 1
g cropsale_month_tbgrow = cropinc_month if tobacco_sold == 1
g cropsale_month_soygrow = cropinc_month if soya_sold == 1
g cropsale_month_notb_sygrow = cropinc_month if no_tob_soya == 1
g livestocksale_tb_soygrow = live_income if tob_soy_sold == 1
g livestocksale_tbgrow = live_income if tobacco_sold == 1
g livestocksale_soygrow = live_income if soya_sold == 1
g livestocksale_notb_soygrow = live_income if no_tob_soya == 1
g casual_tb_soygrow = casual if tob_soy_sold == 1
g casual_tbgrow = casual if tobacco_sold == 1
g casual_soygrow = casual if soya_sold == 1
g casual_notb_soygrow = casual if  no_tob_soya == 1
g ag_d_19_tb_soygrow = ag_d_19 if tob_soy_sold == 1
g ag_d_19_tbgrow = ag_d_19 if tobacco_sold == 1
g ag_d_19_soygrow = ag_d_19 if soya_sold == 1
g ag_d_19_notb_soygrow = ag_d_19 if no_tob_soya == 1
g livprodsales_month_tb_soygrow = livprodsales_month if tob_soy_sold == 1
g livprodsales_month_tbgrow = livprodsales_month if tobacco_sold == 1
g livprodsales_month_soygrow = livprodsales_month if soya_sold == 1
g livprodsales_month_notb_soygrow = livprodsales_month if  no_tob_soya == 1
g totinc_regular_tb_soygrow = totinc_regular if tob_soy_sold == 1
g totinc_regular_tbgrow = totinc_regular if tobacco_sold == 1
g totinc_regular_soygrow = totinc_regular if soya_sold == 1
g totinc_regular_notb_soygrow = totinc_regular if no_tob_soya == 1
g monthlyinc_regular_tb_soygrow = monthlyinc_regular if tob_soy_sold == 1
g monthlyinc_regular_tbgrow = monthlyinc_regular if tobacco_sold == 1
g monthlyinc_regular_soygrow = monthlyinc_regular if soya_sold == 1
g monthlyinc_regular_notb_soygrow = monthlyinc_regular if no_tob_soya == 1
g totinc_enter_tb_soygrow = hh_ent_inc if tob_soy_sold == 1
g totinc_enter_tbgrow = hh_ent_inc if tobacco_sold == 1
g totinc_enter_soygrow = hh_ent_inc if soya_sold == 1
g totinc_enter_notb_soygrow  = hh_ent_inc if no_tob_soya == 1
g month_inc_ent_tb_soygrow = net_month_inc_ent if tob_soy_sold == 1
g month_inc_ent_tbgrow = net_month_inc_ent if tobacco_sold == 1
g month_inc_ent_soygrow = net_month_inc_ent if soya_sold == 1
g month_inc_ent_notb_soygrow = net_month_inc_ent if no_tob_soya == 1
g totinc_other_tb_soygrow  = totinc_other if tob_soy_sold == 1
g totinc_other_tbgrow = totinc_other if tobacco_sold == 1
g totinc_other_soygrow = totinc_other if soya_sold == 1
g totinc_other_notb_soygrow = totinc_other if no_tob_soya == 1
g month_inc_other_tb_soygrow = month_inc_other if tob_soy_sold == 1
g month_inc_other_tbgrow = month_inc_other if tobacco_sold == 1
g month_inc_other_soygrow = month_inc_other if soya_sold == 1
g month_inc_other_notb_soygrow = month_inc_other if no_tob_soya == 1
g totinc_gift_tb_soygrow = totinc_gift if tob_soy_sold == 1
g totinc_gift_tbgrow = totinc_gift if tobacco_sold == 1
g totinc_gift_soygrow = totinc_gift if soya_sold == 1
g totinc_gift_notb_soygrow = totinc_gift if no_tob_soya == 1
g month_inc_gift_tb_soygrow = month_inc_gift if tob_soy_sold == 1
g month_inc_gift_tbgrow = month_inc_gift if tobacco_sold == 1
g month_inc_gift_soygrow = month_inc_gift if soya_sold == 1
g month_inc_gift_notb_soygrow = month_inc_gift if no_tob_soya == 1
g totinc_safety_tb_soygrow = totinc_safety if tob_soy_sold == 1
g totinc_safety_tbgrow = totinc_safety if tobacco_sold == 1
g totinc_safety_soygrow = totinc_safety if soya_sold == 1
g totinc_safety_notb_soygrow = totinc_safety if no_tob_soya == 1
g month_inc_safety_tb_soygrow = month_inc_safety if tob_soy_sold == 1
g month_inc_safety_tbgrow = month_inc_safety if tobacco_sold == 1
g month_inc_safety_soygrow = month_inc_safety if soya_sold == 1
g month_inc_safety_notb_soygrow = month_inc_safety if no_tob_soya == 1
g totinc_o_other_tb_soygrow = totinc_o_other if tob_soy_sold == 1
g totinc_o_other_tbgrow = totinc_o_other if tobacco_sold == 1
g totinc_o_other_soygrow = totinc_o_other if soya_sold == 1
g totinc_o_other_notb_soygrow = totinc_o_other if no_tob_soya == 1
g month_inc_o_other_tb_soygrow = month_inc_o_other if tob_soy_sold == 1
g month_inc_o_other_tbgrow = month_inc_o_other if tobacco_sold == 1
g month_inc_o_other_soygrow = month_inc_o_other if soya_sold == 1
g month_inc_o_other_notb_soygrow = month_inc_o_other if no_tob_soya == 1

*alternate years
preserve
keep if year == 2017
lab val month month
lab def month 1 "Jan" 2 "Feb" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 ///
"August" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec"
replace month_inc_other = . if month_inc_other<0
replace month_inc_safety = . if month_inc_safety<0
lab var tot_cropsales "Crop Revenue"
lab var live_income "Livestock income"
lab var ag_d_19 "Livestock products sales"
lab var totinc_regular "Permanent wages"
lab var casual "Seasonal wages"
lab var totinc_enter "Non-Agric enterprises"
lab var totinc_other "Pensions"
lab var totinc_gift "Gift and Remittances"
lab var totinc_safety "Social transfers"
lab var totinc_o_other "Other incomes"
lab var totincome "Total hhd income"
table1 month using $tmp\, id(hh_id) order
export excel using "$output\seasonalhunger.xls", firstrow(variables) replace
restore
*
keep if year == 2019
lab val month month
lab def month 1 "Jan" 2 "Feb" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 ///
"August" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec"
replace month_inc_other = . if month_inc_other<0
replace month_inc_safety = . if month_inc_safety<0
lab var tot_cropsales "Crop Revenue"
lab var live_income "Livestock income"
lab var ag_d_19 "Livestock products sales"
lab var totinc_regular "Permanent wages"
lab var casual "Seasonal wages"
lab var totinc_enter "Non-Agric enterprises"
lab var totinc_other "Pensions"
lab var totinc_gift "Gift and Remittances"
lab var totinc_safety "Social transfers"
lab var totinc_o_other "Other incomes"
lab var totincome "Total hhd income"
table1 month using $tmp\, id(hh_id) order
export excel using "$output\seasonalhunger1.xls", firstrow(variables) replace


*Table 2
/*use "$data\nosale", clear
collapse (sum) nosale2, by(hh_id year)
replace nosale2 =1 if nosale2>1
save "$data\nosale_1", replace*/
**
use "$data\seasonal_hunger", clear
mer 1:1 hh_id year using "$data\crop_count_grown", nogen
mer 1:1 hh_id year using "$data\crops_sold", nogen
*alternate between the years
keep if year==2019
reshape long hh_f_3__, i(hh_id)
tostring _j, g(month)
drop _j
g hh_f_3__tbgrow = hh_f_3__ if tobacco_sold == 1
g hh_f_3__soygrow = hh_f_3__ if soya_sold == 1
g hh_f_3__tb_soygrow = hh_f_3__ if tob_soy_sold == 1
g hh_f_3__notb_soygrow = hh_f_3__ if no_tob_soya == 1
g hh_f_3__nosale = hh_f_3__ if sale == 0
for var hh_f_3__tbgrow-hh_f_3__nosale: replace X = 0 if X ==.&hh_f_3__ != .
g mth = real(month)
drop month
ren mth month
order month, after(year)
lab val month month
lab def month 1 "Jan" 2 "Feb" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 ///
"August" 9 "Sept" 10 "Oct" 11 "Nov" 12 "Dec"
table1 month using $tmp\, id(hh_id) order
export excel using "$output\seasonalhunger2.xls", firstrow(variables) replace
**
*Table 3
use "$data\seasonal_hunger", clear
mer 1:1 hh_id year using "$data\crop_count_grown", nogen
mer 1:1 hh_id year using "$data\crops_sold", nogen
keep hh_id year HDDS_cat HFIAS HFIAS_cat food_sec HDDS_m HDDS_f HDDS WDDS ///
seasonal_hunger seas_hunger_cat foodsec_trans crop_count-pathway
*alternate between the years
preserve
keep if year==2017
lab drop seas_hunger_cat
lab val seas_hunger_cat seas_hunger_cat
lab def seas_hunger_cat 1 "L" 2 "M" 3 "H"
lab drop HFIAS_cat
lab val HFIAS_cat HFIAS_cat
lab def HFIAS_cat 1 "NS" 2 "S" 3 "VS"
table1 HDDS_cat seas_hunger_cat HFIAS_cat using $tmp\, id(hh_id) order
export excel using "$output\seasonalhunger3.xls", firstrow(variables) replace
restore

preserve
keep if year==2019
lab drop seas_hunger_cat
lab val seas_hunger_cat seas_hunger_cat
lab def seas_hunger_cat 1 "L" 2 "M" 3 "H"
lab drop HFIAS_cat
lab val HFIAS_cat HFIAS_cat
lab def HFIAS_cat 1 "NS" 2 "S" 3 "VS"
table1 HDDS_cat seas_hunger_cat HFIAS_cat using $tmp\, id(hh_id) order
export excel using "$output\seasonalhunger3_1.xls", firstrow(variables) replace
restore
********************************************************************************
*COMBINING DAT
*Table 4
use "$data\seasonal_hunger", clear
mer 1:1 hh_id year using "$data\crop_count_grown", nogen
keep hh_id year foodsec_trans crop_count
mer 1:1 hh_id year using "$data\crops_sold", nogen
mer 1:1 hh_id year using "$data\hhd_demographics_fin", nogen
mer 1:1 hh_id year using "$data\dist_road", nogen
mer 1:1 hh_id year using "$data\land_own", nogen
mer 1:1 hh_id year using "$data\poultry", nogen
mer 1:1 hh_id year using "$data\TLU", nogen
mer 1:1 hh_id year using "$data\wage_worker", nogen
replace wagework = 0 if wagework == .
mer 1:1 hh_id year using "$data\wardrainfall21_fin", nogen
mer 1:1 hh_id year using "$data\assetindex", nogen
mer 1:1 hh_id year using "$data\HCI commercialisation_hhd_year.dta", nogen
mer 1:1 hh_id year using "$data\inco.dta", nogen
mer 1:1 hh_id year using "$data\cattle", nogen
replace cattle = 0 if cattle == .
mer 1:1 hh_id year using "$data\persondays", nogen
mer 1:1 hh_id year using "$data\tractor_use", nogen
lab var persondays "Hired labour days"
save "$data\table4", replace
**
g year1 = year
replace year1 = 1 if year == 2017
replace year1 = 2 if year == 2019
xtset hh_id year1
xtbalance, range(1 2)
**
winsor2 totincome1 totinc_regular1 live_income1 if totincome1!=. & totinc_regular1!=., replace cuts(1 95)
winsor2 live_income1 if live_income1!=., replace cuts(25 90)
winsor2 casual1 if casual1!=., replace cuts(1 85)
*Distribution plots
for var crop_income1-totincome1: replace X = . if X < 0
for var totincome1 totinc_o_other1 totinc_safety1 totinc_gift1 totinc_other1 ///
hh_ent_inc1 totinc_regular1 casual1 crop_income1: g lnX = ln(X)
g lnlive_income1 = ln(1+live_income1)
lab var lncrop_income1 "Log of Income from crop sales"
lab var lncasual1 "Log of Seasonal wages"
lab var lnlive_income1 "Log of Livestock sales"
lab var lntotinc_regular1 "Log of Permanent wages"
lab var lnhh_ent_inc1 "Log of Non-Agric Enterprises income"
lab var lntotinc_other1 "Log of Pensions"
lab var lntotinc_gift1 "Log of Remittances and Gifts"
lab var lntotinc_safety1 "Log of Social Transfers"
lab var lntotinc_o_other1 "Log of other incomes"
lab var lntotincome1 "Log of total income"

kdensity lntotincome1, nogr gen(x fx)
kdensity lntotincome1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotincome1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(totinc, replace)
drop fx x fx0 fx1
**
kdensity lntotinc_o_other1, nogr gen(x fx)
kdensity lntotinc_o_other1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotinc_o_other1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(otherinc, replace)
drop fx x fx0 fx1
**
kdensity lntotinc_safety1, nogr gen(x fx)
kdensity lntotinc_safety1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotinc_safety1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(transinc, replace)
drop fx x fx0 fx1
**
kdensity lntotinc_gift1, nogr gen(x fx)
kdensity lntotinc_gift1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotinc_gift1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(giftinc, replace)
drop fx x fx0 fx1
**
kdensity lntotinc_other1, nogr gen(x fx)
kdensity lntotinc_other1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotinc_other1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(pensioninc, replace)
drop fx x fx0 fx1
**
kdensity lnhh_ent_inc1, nogr gen(x fx)
kdensity lnhh_ent_inc1 if year == 2017, nogr gen(fx0) at(x)
kdensity lnhh_ent_inc1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(entinc, replace)
drop fx x fx0 fx1
**
kdensity lntotinc_regular1, nogr gen(x fx)
kdensity lntotinc_regular1 if year == 2017, nogr gen(fx0) at(x)
kdensity lntotinc_regular1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(wageinc, replace)
drop fx x fx0 fx1
**
kdensity lnlive_income1, nogr gen(x fx)
kdensity lnlive_income1 if year == 2017, nogr gen(fx0) at(x)
kdensity lnlive_income1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(liveinc, replace)
drop fx x fx0 fx1
**
kdensity lncasual1, nogr gen(x fx)
kdensity lncasual1 if year == 2017, nogr gen(fx0) at(x)
kdensity lncasual1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(seasinc, replace)
drop fx x fx0 fx1
**
kdensity lncrop_income1, nogr gen(x fx)
kdensity lncrop_income1 if year == 2017, nogr gen(fx0) at(x)
kdensity lncrop_income1 if year == 2019, nogr gen(fx1) at(x)
lab var fx0 "2017"
lab var fx1 "2019"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) saving(cropinc, replace)
drop fx x fx0 fx1
**
graph combine totinc.gph otherinc.gph transinc.gph giftinc.gph pensioninc.gph ///
entinc.gph wageinc.gph liveinc.gph seasinc.gph cropinc.gph
********************************************************************************
*CREATE VARIABLES IDENTIFYING WOMEN EMPOWERMENT
use "$rawdata\2. R1_R2_Section_A_HH_Members_zmb.dta", clear
keep if hh_a_15>=15
keep hhroster__id hh_a_14 hh_id year /*to get variable identifying gender*/
order hh_id year
so hh_id year hhroster__id
save tmp, replace
**
use "$rawdata\6. R1_R2_Section_B_C_Plot_Crop_Rosters_ALL_zmb.dta", clear
keep hh_id year ag_b_2_plot_roster__id crop_roster_sale__id ag_b_09__* ag_b_10__*
egen plot_crop_id = group(ag_b_2_plot_roster__id crop_roster_sale__id)
save tmp1, replace
*
ren  ag_b_09__0 hhroster__id
so hh_id year hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer
keep hh_id year plot_crop_id hh_a_14
reshape wide hh_a_14, i(hh_id year) j(plot_crop_id)
g manage=(hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2 | ///
hh_a_1410==2 | hh_a_1411==2 | hh_a_1412==2 | hh_a_1413==2 | hh_a_1414==2 | ///
hh_a_1415==2 | hh_a_1416==2 | hh_a_1417==2 | hh_a_1418==2 | hh_a_1419==2 | ///
hh_a_1420==2 | hh_a_1421==2 | hh_a_1422==2 | hh_a_1423==2 | hh_a_1424==2 | ///
hh_a_1425==2 | hh_a_1426==2 | hh_a_1427==2 | hh_a_1428==2 | hh_a_1429==2 | ///
hh_a_1430==2 | hh_a_1431==2 | hh_a_1432==2 | hh_a_1433==2 | hh_a_1434==2 | ///
hh_a_1435==2 | hh_a_1436==2 | hh_a_1437==2 | hh_a_1438==2 | hh_a_1439==2 | ///
hh_a_1440==2 | hh_a_1441==2 | hh_a_1442==2 | hh_a_1443==2 | hh_a_1444==2 | ///
hh_a_1445==2 | hh_a_1446==2 | hh_a_1447==2 | hh_a_1448==2 | hh_a_1449==2 | ///
hh_a_1450==2 | hh_a_1451==2 | hh_a_1452==2 | hh_a_1453==2 | hh_a_1454==2 | ///
hh_a_1455==2 | hh_a_1456==2 | hh_a_1457==2 | hh_a_1458==2 | hh_a_1459==2 | ///
hh_a_1460==2 | hh_a_1461==2 | hh_a_1462==2 | hh_a_1463==2 | hh_a_1464==2 | ///
hh_a_1465==2 | hh_a_1466==2 | hh_a_1467==2 | hh_a_1468==2 | hh_a_1469==2 | ///
hh_a_1470==2 | hh_a_1471==2 | hh_a_1472==2 | hh_a_1473==2 | hh_a_1474==2 | ///
hh_a_1475==2 | hh_a_1476==2 | hh_a_1477==2 | hh_a_1478==2 | hh_a_1479==2 | ///
hh_a_1480==2 | hh_a_1481==2 | hh_a_1482==2 | hh_a_1483==2 | hh_a_1484==2 | ///
hh_a_1485==2 | hh_a_1486==2 | hh_a_1487==2 | hh_a_1488==2 | hh_a_1489==2 | ///
hh_a_1490==2 | hh_a_1491==2 | hh_a_1492==2 | hh_a_1493==2 | hh_a_1494==2 | ///
hh_a_1495==2 | hh_a_1496==2 | hh_a_1497==2 | hh_a_1498==2 | hh_a_1499==2 | ///
hh_a_14100==2 | hh_a_14101==2 | hh_a_14102==2 | hh_a_14103==2 | hh_a_14104==2 | ///
hh_a_14105==2 | hh_a_14106==2 | hh_a_14107==2 | hh_a_14108==2) 
lab var manage "Women involved in primarily managing plots"
drop hh_a_14*
save tmp2, replace
*Who primarily decides how the outputs from the plot are used (consumption or sales of crops, etc.)?
use tmp1, clear
ren  ag_b_10__0 hhroster__id
so hh_id year hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer
keep hh_id year plot_crop_id hh_a_14
reshape wide hh_a_14, i(hh_id year) j(plot_crop_id)
g manage1=(hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2 | ///
hh_a_1410==2 | hh_a_1411==2 | hh_a_1412==2 | hh_a_1413==2 | hh_a_1414==2 | ///
hh_a_1415==2 | hh_a_1416==2 | hh_a_1417==2 | hh_a_1418==2 | hh_a_1419==2 | ///
hh_a_1420==2 | hh_a_1421==2 | hh_a_1422==2 | hh_a_1423==2 | hh_a_1424==2 | ///
hh_a_1425==2 | hh_a_1426==2 | hh_a_1427==2 | hh_a_1428==2 | hh_a_1429==2 | ///
hh_a_1430==2 | hh_a_1431==2 | hh_a_1432==2 | hh_a_1433==2 | hh_a_1434==2 | ///
hh_a_1435==2 | hh_a_1436==2 | hh_a_1437==2 | hh_a_1438==2 | hh_a_1439==2 | ///
hh_a_1440==2 | hh_a_1441==2 | hh_a_1442==2 | hh_a_1443==2 | hh_a_1444==2 | ///
hh_a_1445==2 | hh_a_1446==2 | hh_a_1447==2 | hh_a_1448==2 | hh_a_1449==2 | ///
hh_a_1450==2 | hh_a_1451==2 | hh_a_1452==2 | hh_a_1453==2 | hh_a_1454==2 | ///
hh_a_1455==2 | hh_a_1456==2 | hh_a_1457==2 | hh_a_1458==2 | hh_a_1459==2 | ///
hh_a_1460==2 | hh_a_1461==2 | hh_a_1462==2 | hh_a_1463==2 | hh_a_1464==2 | ///
hh_a_1465==2 | hh_a_1466==2 | hh_a_1467==2 | hh_a_1468==2 | hh_a_1469==2 | ///
hh_a_1470==2 | hh_a_1471==2 | hh_a_1472==2 | hh_a_1473==2 | hh_a_1474==2 | ///
hh_a_1475==2 | hh_a_1476==2 | hh_a_1477==2 | hh_a_1478==2 | hh_a_1479==2 | ///
hh_a_1480==2 | hh_a_1481==2 | hh_a_1482==2 | hh_a_1483==2 | hh_a_1484==2 | ///
hh_a_1485==2 | hh_a_1486==2 | hh_a_1487==2 | hh_a_1488==2 | hh_a_1489==2 | ///
hh_a_1490==2 | hh_a_1491==2 | hh_a_1492==2 | hh_a_1493==2 | hh_a_1494==2 | ///
hh_a_1495==2 | hh_a_1496==2 | hh_a_1497==2 | hh_a_1498==2 | hh_a_1499==2 | ///
hh_a_14100==2 | hh_a_14101==2 | hh_a_14102==2 | hh_a_14103==2 | hh_a_14104==2 | ///
hh_a_14105==2 | hh_a_14106==2 | hh_a_14107==2 | hh_a_14108==2) 
drop hh_a_14*
lab var manage1 "Women involved in deciding how the outputs from the plot are used"
save tmp3, replace
**
use "$rawdata\6. R1_R2_Section_B_C_Plot_Crop_Rosters_ALL_zmb.dta", clear
order hh_id year ag_b_2_plot_roster__id 
*maize  and tobacco decision
//keep if crop_roster_sale__id==1 | crop_roster_sale__id==2
preserve
keep hh_id year ag_b_2_plot_roster__id crop_roster_sale__id ag_c_3
//duplicates drop interview__id crop_roster_sale__id ag_c_3, force
ren ag_c_3 hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer
keep hh_id year hh_a_14 
byso hh_id year: egen manage=total(hh_a_14==2)
keep hh_id year manage
duplicates drop
replace manage=1 if manage>0
ren manage manage2
lab var manage2 "Women involved in deciding whether to sell crop"
save tmp4, replace
restore
**
order hh_id year ag_b_2_plot_roster__id crop_roster_sale__id
keep hh_id year ag_b_2_plot_roster__id crop_roster_sale__id ag_c_15*
drop ag_c_15__4 ag_c_15__5 ag_c_15__6
egen plot_crop_id = group(ag_b_2_plot_roster__id crop_roster_sale__id)

keep hh_id year plot_crop_id ag_c_15__1
ren ag_c_15__1 hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
reshape wide hh_a_14, i(hh_id year) j(plot_crop_id)
g women=(hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2 | ///
hh_a_1411==2 | hh_a_1411==2 | hh_a_1414==2 | hh_a_1415==2 | hh_a_1416==2 | ///
hh_a_1418==2 | hh_a_1419==2 | hh_a_1421==2 | hh_a_1422==2 | hh_a_1423==2 | ///
hh_a_1426==2 | hh_a_1427==2 | hh_a_1428==2 | hh_a_1430==2 | hh_a_1431==2 | ///
hh_a_1432==2 | hh_a_1433==2 | hh_a_1434==2 | hh_a_1435==2 | hh_a_1437==2 | ///
hh_a_1438==2 | hh_a_1440==2 | hh_a_1441==2 | hh_a_1443==2 | hh_a_1445==2 | ///
hh_a_1446==2 | hh_a_1447==2 | hh_a_1448==2 | hh_a_1449==2 | hh_a_1450==2 | ///
hh_a_1451==2 | hh_a_1452==2 | hh_a_1454==2 | hh_a_1455==2 | hh_a_1456==2 | ///
hh_a_1457==2 | hh_a_1462==2 | hh_a_1464==2 | hh_a_1466==2 | hh_a_1467==2 | ///
hh_a_1468==2 | hh_a_1469==2 | hh_a_1470==2 | hh_a_1471==2 | hh_a_1472==2 | ///
hh_a_1473==2 | hh_a_1474==2 | hh_a_1475==2 | hh_a_1480==2 | hh_a_1481==2 | ///
hh_a_1482==2 | hh_a_1483==2 | hh_a_1485==2 | hh_a_1486==2 | hh_a_1487==2 | ///
hh_a_1489==2 | hh_a_1490==2 | hh_a_1491==2 | hh_a_1492==2 | hh_a_1494==2 | ///
hh_a_1499==2 | hh_a_14100==2  | hh_a_14107==2 | hh_a_14108==2) 
drop hh_a_14*
lab var women "Women involved in decisions of how revenue from crop sales will be used"
save tmp5, replace

**
*women in owneship of assets-livestock
use "$rawdata\11. R1_R2_Section_D_zmb.dta", clear
keep if livestockroster__id==1 /*cattle only*/
preserve
keep hh_id year ag_d_6a__0 
ren ag_d_6a__0 hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
ren women2 women1
lab var women1 "Women owns cattle"
save tmp6, replace
restore
**
preserve
keep hh_id year ag_d_6b__0 
ren ag_d_6b__0 hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
lab var women2 "Women responsible for taking care of cattle"
save tmp7, replace
restore
**
keep hh_id year ag_d_15__0
ren ag_d_15__0 hhroster__id
mer m:1 hh_id year hhroster__id using tmp
keep if _mer==3
drop _mer  hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
ren women2 women3
lab var women3 "Women responsible in decisions on whether to sell livestock"
save tmp8, replace
**
/*use "$data\wage_worker", clear
ren hh_regular__id hhroster__id 
mer m:1 hh_id year hhroster__id  using tmp
keep if _mer==3
tab hh_a_14, g(wageworker)
drop _mer  hhroster__id hh_a_14 wagework
lab var wageworker1 "Male wage worker"
lab var wageworker2 "Female wage worker"
save "$data\wage_worker_fin", replace*/
**
use tmp2, clear
mer 1:1 hh_id year using tmp3
drop _mer
mer 1:1 hh_id year using tmp4
drop _mer
mer 1:1 hh_id year using tmp5
drop _mer
mer 1:1 hh_id year using tmp6
drop _mer
mer 1:1 hh_id year using tmp7, nogen
mer 1:1 hh_id year using tmp8, nogen
egen women_emp_ind = rowmean(manage manage1 manage2 women women3)
g women_emp = (women_emp>=0.75)
lab var women_emp "Women empowered in the household"
lab var women_emp_ind "Index of women empowerment in the household"
save "$data\women_empower2020", replace
****
use "$data\land_quality", clear
ren  ag_b_09__0 hhroster__id
mer m:1 hh_id year hhroster__id  using tmp
keep if _mer == 3
drop _mer hhroster__id
preserve
reshape wide area  ag_b_04a_units1, i(hh_id year ag_b_2_plot_roster__id ///
crop_roster_sale__id) j(ag_b_13)
keep hh_id year ag_b_04a_units11 ag_b_04a_units12 ag_b_04a_units13 ///
ag_b_04a_units14 ag_b_04a_units15 ag_b_04a_units190
for var ag_b_04a_units11 ag_b_04a_units12 ag_b_04a_units13 ///
ag_b_04a_units14 ag_b_04a_units15 ag_b_04a_units190: egen sum_X = sum(X), by(hh_id year) missing
keep hh_id year sum_ag_b_04a_units11-sum_ag_b_04a_units190
duplicates drop
ren (sum_ag_b_04a_units11 sum_ag_b_04a_units12 sum_ag_b_04a_units13 ///
sum_ag_b_04a_units14 sum_ag_b_04a_units15 sum_ag_b_04a_units190) ///
(sum_ag_b_04a_units11_ sum_ag_b_04a_units12_ sum_ag_b_04a_units13_ ///
sum_ag_b_04a_units14_ sum_ag_b_04a_units15_ sum_ag_b_04a_units190_)
save "$data\landquality1", replace
restore
*
egen soil_gender = group(ag_b_13 hh_a_14)
reshape wide area  ag_b_04a_units1, i(hh_id year ag_b_2_plot_roster__id ///
crop_roster_sale__id) j(soil_gender)
keep hh_id year ag_b_2_plot_roster__id-area11

for var ag_b_04a_units11 ag_b_04a_units12 ag_b_04a_units13 ag_b_04a_units14 ///
ag_b_04a_units15 ag_b_04a_units16 ag_b_04a_units17 ag_b_04a_units18 ///
ag_b_04a_units19 ag_b_04a_units110 ag_b_04a_units111: egen sum_X = sum(X), by(hh_id year) missing
/*egen sum_ag_b_04a_units1 = sum(ag_b_04a_units1), by(hh_id year) missing

reshape wide ag_b_04a_units11 area1 ag_b_04a_units12 area2 ag_b_04a_units13 ///
area3 ag_b_04a_units14 area4 ag_b_04a_units190 area90, ///
i(hh_id year ag_b_2_plot_roster__id crop_roster_sale__id) j(hh_a_14)
for var ag_b_04a_units111-ag_b_04a_units1902: egen sum_X = sum(X), by(hh_id year) missing*/
keep hh_id year sum_ag_b_04a_units11-sum_ag_b_04a_units111
duplicates drop
mer 1:1 hh_id year using "$data\landquality1", nogen
/*ren (sum_ag_b_04a_units11 sum_ag_b_04a_units12 sum_ag_b_04a_units13 ///
sum_ag_b_04a_units14 sum_ag_b_04a_units15 sum_ag_b_04a_units16 ///
sum_ag_b_04a_units17 sum_ag_b_04a_units18 sum_ag_b_04a_units19 ///
sum_ag_b_04a_units110 sum_ag_b_04a_units111) ///
(plotarea_sandy1 plotarea_clay1 plotarea_sandclay1 plotarea_stony1 ///
plotarea_sandy2 plotarea_clay2 plotarea_sandclay2 plotarea_stony2 plotarea_other1 ///
plotarea_other2 plotarea_sandy plotarea_clay plotarea_sandyclay  plotarea_stony ///
plotarea_forest plotarea_other)*/
lab var sum_ag_b_04a_units11_ "Area of sandy plot owned(ha)"
lab var sum_ag_b_04a_units12_ "Area clay plot owned(ha)"
lab var sum_ag_b_04a_units13_ "Area of sandy-clay plot owned(ha)"
lab var sum_ag_b_04a_units14_ "Area of stony plot owned(ha)"
lab var sum_ag_b_04a_units15_ "Area of plot(forest soil) owned(ha)"
lab var sum_ag_b_04a_units190_ "Area of plot(other) owned(ha)"
lab var sum_ag_b_04a_units11 "Area of sandy plot managed by male(ha)"
lab var sum_ag_b_04a_units12 "Area of sandy plot managed by female(ha)"
lab var sum_ag_b_04a_units13 "Area of clay plot managed by male (ha)"
lab var sum_ag_b_04a_units14 "Area of clay plot managed by female (ha)"
lab var sum_ag_b_04a_units15 "Area of sand-clay managed by male (ha)"
lab var sum_ag_b_04a_units16 "Area of sand-clay managed by female (ha)"
lab var sum_ag_b_04a_units17 "Area of stony plot managed by male (ha)" 
lab var sum_ag_b_04a_units18 "Area of stony plot managed by female (ha)" 
lab var sum_ag_b_04a_units19 "Area of forest plot managed by male(ha)"
lab var sum_ag_b_04a_units110 "Area of forest plot managed by male(ha)"
save "$data\landquality_fin", replace
**
use "$rawdata\1. R1_R2_Section_A_Interview_Details_zmb.dta", clear
keep year hh_id hh_a04b1 hh_a_05b
mer 1:1 hh_id year using "$data\table4", nogen
mer 1:1 hh_id year using "$data\women_empower2020", nogen
mer 1:1 hh_id year using "$data\labor_demands", nogen
mer 1:1 hh_id year using "$data\retainedfood_kcal", nogen
mer 1:1 hh_id year using "$data\countryqstn"
keep if _mer == 3
drop _mer  land_own
mer 1:1 hh_id year using "$data\land_own_ha", nogen
mer 1:1 hh_id year using  "$data\landquality_fin", nogen
mer 1:1 hh_id year using "$data\seasonal_hunger", nogen
mer 1:1 hh_id year using "$rawdata\19. R1_R2_Section_E5_zmb.dta", nogen
mer 1:1 hh_id year using "$data\AME", nogen
lab var AME "Adult male equivalent"

winsor2 sum_ag_b_04a_units1_own if sum_ag_b_04a_units1_own!=., replace cuts(1 95)
winsor2 sum_ag_b_04a_units1_rentin if sum_ag_b_04a_units1_rentin!=., replace cuts(1 95)
replace totincome1 = 0 if totincome1 <0
g percapita_inc = totincome1/hhdsize
g percapita_inc_d = percapita_inc/365
winsor2 percapita_inc_d if percapita_inc_d!=., replace cuts(5 95)

lab var percapita_inc "Annual household per capita income"
lab var percapita_inc_d "Daily household per capita income"
*Computing poverty measures
poverty percapita_inc_d, gen(pov_tinc) line(-2)
lab val pov_tinc pov_tinc
lab def pov_tinc 0 "Non poor" 1 "Poor"
g gender = gender1
lab val gender gender
lab def gender 0 "Female" 1 "Male"
**


*Poverty transitions
g byte pov_transitions = .
so hh_id year
by hh_id: replace pov_transitions = 1 if pov_tinc[_n-1] == 1&pov_tinc[_n] == 0
by hh_id: replace pov_transitions = 2 if pov_tinc[_n-1] == 0&pov_tinc[_n] == 1
by hh_id: replace pov_transitions = 3 if pov_tinc[_n-1] == 0&pov_tinc[_n] == 0
by hh_id: replace pov_transitions = 4 if pov_tinc[_n-1] == 1&pov_tinc[_n] == 1
by hh_id: replace pov_transitions = 1 if pov_tinc[_n] == 1&pov_tinc[_n+1] == 0
by hh_id: replace pov_transitions = 2 if pov_tinc[_n] == 0&pov_tinc[_n+1] == 1
by hh_id: replace pov_transitions = 3 if pov_tinc[_n] == 0&pov_tinc[_n+1] == 0
by hh_id: replace pov_transitions = 4 if pov_tinc[_n] == 1&pov_tinc[_n+1] == 1
lab val pov_transitions pov_transitions
lab def pov_transitions 1 "movers" 2 "entrants" 3 "never poor" 4 "chronic"
**
*Empowerment transitions
g empower_trans = .
by hh_id: replace empower_trans = 1 if women_emp[_n-1] == 0&women_emp[_n] == 1
by hh_id: replace empower_trans = 2 if women_emp[_n-1] == 1&women_emp[_n] == 0
by hh_id: replace empower_trans = 3 if women_emp[_n-1] == 0&women_emp[_n] == 0
by hh_id: replace empower_trans = 4 if women_emp[_n-1] == 1&women_emp[_n] == 1
by hh_id: replace empower_trans = 1 if women_emp[_n] == 0&women_emp[_n+1] == 1
by hh_id: replace empower_trans = 2 if women_emp[_n] == 1&women_emp[_n+1] == 0
by hh_id: replace empower_trans = 3 if women_emp[_n] == 0&women_emp[_n+1] == 0
by hh_id: replace empower_trans = 4 if women_emp[_n] == 1&women_emp[_n+1] == 1
lab val empower_trans empower_trans
lab def empower_trans 1 "movers to empowerment" 2 "moving to disempowerment" ///
3 "never empowered" 4 "never disempowered"
lab val food_sec food_sec
lab def food_sec 1 "Food secure" 0 "Food insecure"
**
*Vine et al Table 1
/*g WealthIndex_squared = WealthIndex^2
g ProductionAssetIndex_squared = ProductionAssetIndex^2 */
preserve
keep if year == 2017
keep hh_id year hh_a04b1 pathway hh_e_36 pov_tinc production_assets consumption_assets ///
percapita_inc
table1 pathway hh_a04b1 using $tmp\, id(hh_id) order
export excel using "$output\tableVine_2017.xls", firstrow(variables) replace
restore
preserve
keep if year == 2019
keep hh_id year hh_a04b1 pathway  hh_e_36 pov_tinc production_assets consumption_assets ///
percapita_inc
table1 pathway hh_a04b1 using $tmp\, id(hh_id) order
export excel using "$output\tableVine_2019.xls", firstrow(variables) replace
restore
**
*Mahofa et al Table 1
*alternate years
preserve
keep year hh_id hh_a04b1 pathway manage-women_emp
keep if year == 2017
table1 pathway hh_a04b1 using $tmp\, id(hh_id) order
replace label="Women involved in primarily managing plots" if variables=="manage"
replace label="Women involved in deciding how the outputs from the plot are  used" if variables=="manage1"
replace label="Women involved in deciding whether to sell crop" if variables=="manage2"
replace label="Women involved in decisions of how revenue from crop sales will be used" if variables=="women"
replace label="Women responsible for taking care of cattle" if variables=="women2"
replace label="Women responsible in decisions on whether to sell livestock" if variables=="women3"
replace label="Index of women empowerment in the household" if variables=="women_emp_ind"
replace label="Women empowered in the household" if variables=="women_emp"
export excel using "$output\tableHoff_1.xls", firstrow(variables) replace
restore
**
recode sale (0 = 1) (1 = 0)
recode gender1 (0 = 1) (1 = 0)
ren sale no_sale
ren gender1 female
lab var female "Female headed household"
g female_lab_dd = ag_b_21 if female == 1
g male_lab_dd = ag_b_21 if female == 0
lab val women_emp women_emp
lab def women_emp 0 "Not empowered" 1 "Empowered"
g year1 = year
replace year1 = 1 if year == 2017
replace year1 = 2 if year == 2019
preserve
*Checking for attrition bias
byso hh_id: egen in_2017 = max(year==2017)
byso hh_id: egen in_2019 = max(year==2019)
g byte in_2017_only = (in_2017 == 1&in_2019 == 0)
keep if year == 2017
for var totincome1 totinc_gift1 hh_a_15 hhdsize: g lnX = ln(X)
g lnrainfall = ln(rainfall)
egen HCI_cash = rowmean(HCI_tobbaco HCI_soya)
lab var HCI_maize "Food based commercialisation pathway"
lab var HCI_cash "Cash crop based commercialisation pathway"
*Fixing farm scheme issues
replace hh_a_05b = 19 if hh_id == 1007&year == 2019
eststo: qui logit in_2017_only HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets lntotincome1 contractfarm1 HDDS WDDS seasonal_hunger k_cal_retained, vce(cluster hh_a_05b)
esttab using "$output\attrition_reg_paper1.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table A1:}{Correlates of Attrition}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of Production assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)" ///
HDDS "Household Dietary Diversity" seasonal_hunger "Seasonal hunger months" ///
k_cal_retained "Energy content of retained food") 
eststo clear
*
eststo: qui logit in_2017_only HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets lntotincome1 contractfarm1 women_emp, vce(cluster hh_a_05b)
esttab using "$output\attrition_reg_paper2.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table A1:}{Correlates of Attrition}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of Production Assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)" ///
women_emp "Women empowered")
eststo clear
*
eststo: qui logit in_2017_only HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
contractfarm1 extension1 production_assets consumption_assets pov_tinc percapita_inc hh_e_36, vce(cluster hh_a_05b)
esttab using "$output\attrition_reg_paper3.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table A1:}{Correlates of Attrition}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of Production Assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)" ///
women_emp "Women empowered")
eststo clear
**
restore

xtset hh_id year1
xtbalance, range(1 2)
xtset hh_id year1

*Seasonal hunger and food security tables
xttrans food_sec /*foodsecurity transitions*/
lab val foodsec_trans foodsec_trans
lab def foodsec_trans 1 "movers" 2 "entrants" 3 "chronic" 4 "never food insecure"
preserve
keep if year == 2017
table1 foodsec_trans using $tmp\, id(hh_id) order
export excel using "$output\table4.xls", firstrow(variables) replace
restore
preserve
keep if year == 2019
table1 foodsec_trans using $tmp\, id(hh_id) order
export excel using "$output\table4_1.xls", firstrow(variables) replace
restore
*table 5
//lab def pathway 1 "Sell Tobacco" 2 "Sell Soya" 3 "Sell Tobacco and Soya" 4 "No Tobacco and Soya", replace
preserve
keep if year == 2017
table1 pathway using $tmp\, id(hh_id) order
export excel using "$output\table5.xls", firstrow(variables) replace
restore
preserve
keep if year == 2019
table1 pathway using $tmp\, id(hh_id) order
export excel using "$output\table5_1.xls", firstrow(variables) replace
restore

*Mahofa Table 2
preserve
keep if year == 2017
table1 pathway hh_a04b1 using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableHoff_1.xls", firstrow(variables) replace
restore
**
preserve
keep if year == 2019
table1 pathway hh_a04b1 using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableHoff_2.xls", firstrow(variables) replace
restore
**
*Mahofa Table 3
preserve
keep if year == 2017 /*alternate years*/
qui ttst1 women_emp 0 1, newvars(Y) temp($tmp\) 
table1 women_emp  using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableHoff_2017.xls", firstrow(variables) replace
restore
*
preserve
keep if year == 2019 /*alternate years*/
qui ttst1 women_emp 0 1, newvars(Y) temp($tmp\) 
table1 women_emp using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableHoff_2019.xls", firstrow(variables) replace
restore
**
*Empowerment transition tables
preserve
keep if year==2017
table1 empower_trans using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableempower_trans2017.xls", firstrow(variables) replace
restore
**
preserve
keep if year==2019
table1 empower_trans using $tmp\, id(hh_id) order
replace label="Area of sandy plot owned(ha)" if variables=="sum_ag_b_04a_units11_"
replace label="Area clay plot owned(ha)" if variables=="sum_ag_b_04a_units12_"
replace label="Area of sandy-clay plot owned(ha)" if variables=="sum_ag_b_04a_units13_"
replace label="Area of stony plot owned(ha)" if variables=="sum_ag_b_04a_units14_"
replace label="Area of plot(forest soil) owned(ha)" if variables=="sum_ag_b_04a_units15_" 
replace label="Area of plot(other) owned(ha)" if variables=="sum_ag_b_04a_units190_" 
replace label="Area of sandy plot managed by male(ha)" if variables=="sum_ag_b_04a_units11" 
replace label="Area of sandy plot managed by female(ha)" if variables=="sum_ag_b_04a_units12" 
replace label="Area of clay plot managed by male (ha)" if variables=="sum_ag_b_04a_units13" 
replace label="Area of clay plot managed by female (ha)" if variables=="sum_ag_b_04a_units14"
replace label="Area of sand-clay managed by male (ha)" if variables=="sum_ag_b_04a_units15" 
replace label="Area of sand-clay managed by female (ha)" if variables=="sum_ag_b_04a_units16"
replace label="Area of stony plot managed by male (ha)" if variables=="sum_ag_b_04a_units17" 
replace label="Area of stony plot managed by female (ha)" if variables=="sum_ag_b_04a_units18"  
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units19"
replace label="Area of forest plot managed by male(ha)" if variables=="sum_ag_b_04a_units110"
export excel using "$output\tableempower_trans2019.xls", firstrow(variables) replace
restore
**
*Poverty tables
preserve
keep if year == 2017 
qui ttst1 pov_tinc 0 1, newvars(Y) temp($tmp\) 
table1 pov_tinc  using $tmp\, id(hh_id) order
export excel using "$output\variable_tablePov2017.xls", firstrow(variables) replace
restore
preserve
keep if year == 2019 
qui ttst1 pov_tinc 0 1, newvars(Y) temp($tmp\) 
table1 pov_tinc  using $tmp\, id(hh_id) order
export excel using "$output\variable_tablePov2019.xls", firstrow(variables) replace
restore
*Transition matrix for poverty
xttrans pov_tinc
preserve
keep if year == 2017
table1 pov_transitions  using $tmp\, id(hh_id) order
export excel using "$output\vaiable_povtrans2017.xls", firstrow(variables) replace
restore
preserve
keep if year == 2019
table1 pov_transitions  using $tmp\, id(hh_id) order
export excel using "$output\vaiable_povtrans2019.xls", firstrow(variables) replace
restore
**

*Gen logs of variables
for var totincome1 totinc_gift1 hh_a_15 hhdsize: g lnX = ln(X)
g lnrainfall = ln(rainfall)
egen HCI_cash = rowmean(HCI_tobbaco HCI_soya)
lab var HCI_maize "Food based commercialisation pathway"
lab var HCI_cash "Cash crop based commercialisation pathway"
*Transforming food security indicators using percent of maximum possible (“POMP”) method 
sum HDDS HFIAS WDDS seasonal_hunger
for var HDDS HFIAS WDDS seasonal_hunger: egen max_X = max(X)
for var HDDS HFIAS WDDS seasonal_hunger: egen min_X = min(X)
for var HDDS HFIAS WDDS seasonal_hunger: gen poms_X = ((X-min_X)/(max_X-min_X))*100
**
*Fixing farm scheme issues
replace hh_a_05b = 19 if hh_id == 1007&year == 2019
winsor2 production_assets if production_assets!=., replace cuts(10 90)
winsor2 consumption_assets if consumption_assets!=., replace cuts(10 90)
winsor2 hh_a_29b1 if hh_a_29b1!=., replace cuts(10 90)
winsor2 sum_ag_c_5 if sum_ag_c_5!=., replace cuts(10 90)
winsor2 sum_prod_value if sum_prod_value!=., replace cuts(10 90)
replace crop_income1 = 0 if crop_income1<0
replace live_income1 = 0 if live_income1<0
replace hh_ent_inc1 = 0 if hh_ent_inc1<0

winsor2 percapita_inc if percapita_inc!=., replace cuts(1 95)
g lnpercapita_inc =  ln(0.1+percapita_inc)
replace lnpercapita_inc = . if lnpercapita_inc <0
//g lnWealthIndex_squared =  ln(WealthIndex_squared)
egen nfarm_inc =  rowtotal(totinc_regular1 hh_ent_inc1 totinc_gift1 totinc_safety1 totinc_o_other1)
winsor2 nfarm_inc if nfarm_inc!=., replace cuts(15 85)
winsor2 sum_area if sum_area!=., replace cuts(5 95)
winsor2 HCI if HCI!=., replace cuts(5 95)
g lnarea_pla =ln(sum_area)
g lnnfarm_inc = ln(1+nfarm_inc)
egen assets_val = rowtotal(production_assets consumption_assets)
winsor2 assets_val if assets_val!=., replace cuts(10 90)
g lnassets_val = ln(assets_val)
g lnHCI = ln(HCI)
winsor2 totalcosts1 if totalcosts1!=., replace cuts(5 95)
g lntotalcosts1 = ln(totalcosts1)
winsor2 cattle if cattle!=., replace cuts(5 95)
lab var sum_prod_value "Farm Income"
replace year = 2018 if year == 2017
replace year = 2020 if year == 2019
for var sum_prod_value tot_livesales1: replace X=0 if X==.

replace sum_prod_value = sum_prod_value+tot_livesales1
replace sum_prod_value = . if sum_prod_value==0
lab drop pathway
lab val pathway pathway
lab def pathway 1 "Sells tobacco" 2 "Sells soyabeans" 3 "Sells tobacco and soyabeans" ///
4 "No tobacco and soyabeans" 5 "No sale"

**
*Charts
*1. Farm Income
graph bar sum_prod_value, over(pathway) over(year) asyvars scheme(scheme-svg) ///
ytitle("Farm income") legend(position(5))
*2. Asset Values
graph bar assets_val, over(pathway) over(year) asyvars scheme(scheme-svg) ///
ytitle("Value of assets") legend(position(5))

g lnsum_prod_value = ln(sum_prod_value)
lab var lnsum_prod_value "Log Farm Income"
kdensity lnsum_prod_value, nogr gen(x fx)
kdensity lnsum_prod_value if year == 2018, nogr gen(fx0) at(x)
kdensity lnsum_prod_value if year == 2020, nogr gen(fx1) at(x)
lab var fx0 "2018"
lab var fx1 "2020"
line fx0 fx1 x, sort lpattern("l" "-") ytitle(Density) scheme(scheme-svg) ///
saving(transinc, replace) legend(position(6))
drop fx x fx0 fx1
g farminc_ame = sum_prod_value/AME
lab var farminc_ame "Adult Male equivalent Farm Income"
g lndistance = ln(hh_a_29b5)
*Descriptive Statistics
preserve
keep if year==2018
cap table1 hh_a04b1 gender using $tmp\, id(hh_id) order
do "$code\label"
export excel using "$output\table_descriptives.xls", firstrow(variables) replace
restore

preserve 
keep if year==2020
table1 hh_a04b1 gender using $tmp\, id(hh_id) order
do "$code\label"
export excel using "$output\table_descriptives1.xls", firstrow(variables) replace
restore
**
*REGRESSION ANALYSIS

*Commercialisation and Farm Income
reg sum_prod_value tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla, cluster( hh_a_05b)


eststo: qui reg lnsum_prod_value tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla, cluster( hh_a_05b)

eststo: qui reg lnassets_val tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla, cluster( hh_a_05b)

esttab using "$output\pooled_income.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Income}) ///
varlabels(tobacco_sold "Sells Tobacco only (1=Yes)"  soya_sold "Sells Soya only (1=Yes)" ///
tob_soy_sold "Sells Tobacco and Soya (1=Yes)" no_tob_soya "Does not Sell Tobacco and Soya (1=Yes)" ///
hh_a_15 "Age of Household head" ///
tot_inputcosts1 "Spending on Inputs" ///
hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
productive "Number of Adults" ///
contractfarm1 "Engaged in contract farming" ///
persondays "Hired labour person days" ///
tractor_use "Used Tractor for tillage (1=Yes)" ///
lnrainfall "Log of July-June total rainfall(mm)" ///
extension1 "Access to extension (1=Yes)" ///
lndistance "Log of distance to market(km)" ///
lnarea_pla "Log of area plnted(ha)" ///
cattle "Cattle owned")
eststo clear

*Fixed effects
xtreg lnsum_prod_value tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla i.year, ///
fe cluster( hh_a_05b)

eststo: qui xtreg lnsum_prod_value tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla i.year, ///
fe cluster( hh_a_05b)

eststo: qui xtreg lnassets_val tobacco_sold soya_sold tob_soy_sold ///
no_tob_soya hh_a_15 tot_inputcosts1 hh_a_19 married3 female productive cattle ///
persondays tractor_use contractfarm1 extension1 lnrainfall lndistance lnarea_pla i.year, ///
fe cluster( hh_a_05b)

esttab using "$output\income.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 5:}{Smallholder commercialisation and Income-Fixed Effects Estimate}) ///
varlabels(tobacco_sold "Sells Tobacco only (1=Yes)"  soya_sold "Sells Soya only (1=Yes)" ///
tob_soy_sold "Sells Tobacco and Soya (1=Yes)" no_tob_soya "Does not Sell Tobacco and Soya (1=Yes)" ///
hh_a_15 "Age of Household head" ///
tot_inputcosts1 "Spending on Inputs" ///
hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
productive "Number of Adults" ///
contractfarm1 "Engaged in contract farming" ///
persondays "Hired labour person days" ///
tractor_use "Used Tractor for tillage (1=Yes)" ///
lnrainfall "Log of July-June total rainfall(mm)" ///
extension1 "Access to extension (1=Yes)" ///
lndistance "Log of distance to market(km)" ///
lnarea_pla "Log of area plnted(ha)" ///
cattle "Cattle owned")
eststo clear
**

*A: Seasonal hunger
eststo: qui reg poms_HDDS HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, ro
eststo: qui reg poms_HFIAS HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, ro
eststo: qui reg poms_seasonal_hunger HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, ro
eststo: qui reg k_cal_retained HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, ro

*Fixed effects
eststo: qui xtreg poms_HDDS HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b) 
eststo: qui xtreg poms_HFIAS HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
eststo: qui xtreg poms_seasonal_hunger HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
eststo: qui xtreg k_cal_retained HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, fe vce(cluster hh_a_05b)

**
esttab using "$output\seasonalhunger_reg.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Food Security}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of production assests" consumption_assets "Value of consumption assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**
*Comm Pathways
eststo: qui xtreg poms_HDDS HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b) 
eststo: qui xtreg poms_HFIAS HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
eststo: qui xtreg poms_seasonal_hunger HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
eststo: qui xtreg k_cal_retained HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, fe vce(cluster hh_a_05b)
esttab using "$output\seasonalhunger_reg1.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Commercialisation Pathways and Food Security}) ///
varlabels(HCI_maize "Maize-based" HCI_cash "Cash crop-based"  lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of production assets" consumption_assets "Value of consumption assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**
**

*Regression analyis:Women Empowerment
reg women_emp HCI, ro
xtreg women_emp HCI i.year, fe ro
eststo: qui reg women_emp HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area, vce(cluster hh_a_05b)
eststo: qui xtreg women_emp HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit women_emp HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post
esttab using "$output\womenempower_reg.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Women Empowerment}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
crop_count "Crop count" ///
lnassets_val "Value of production assets" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
cattle "Number of cattle owned" sum_area "Area planted"  ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**
eststo: qui xtreg women_emp HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area i.year if female==1, fe vce(cluster hh_a_05b)
eststo: qui xtreg women_emp HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area i.year if female==0, fe vce(cluster hh_a_05b)
esttab using "$output\womenempower_reg_gender.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 6:}{Smallholder commercialisation and Women Empowerment by Gender of Household Head}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
lnassets_val "Log of total value of assets" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
crop_count "Crop count" cattle "Number of cattle owned" sum_area "Area planted" ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**

*Different commercialisation pathways
eststo: qui reg women_emp HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1, vce(cluster hh_a_05b)
eststo: qui xtreg women_emp HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit women_emp HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
production_assets consumption_assets lntotincome1 contractfarm1 i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post
esttab using "$output\womenempower_reg_pathways.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Women Empowerment}) ///
varlabels(HCI_cash "Cash crop-based" HCI_maize "Food-based" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
production_assets "Value of production assets" consumption_assets "Value of consumption assets" nfarminc "Has non-farm income" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**
*Frational logit
xtgee women_emp_ind HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
WealthIndex lntotincome1 contractfarm1 i.year, family(binomial) link(logit) vce(boot)
**
*Channels
eststo: qui xtreg manage HCI lnhh_a_15  lnhhdsize married3 female dpratio ///
crop_count TLU lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit manage HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post

eststo: qui xtreg manage1 HCI lnhh_a_15 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit manage1 HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post

eststo: qui xtreg manage2 HCI lnhh_a_15 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit manage2 HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post

eststo: qui xtreg women HCI lnhh_a_15  lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit women HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post

eststo: qui xtreg women2 HCI lnhh_a_15  lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit women2 HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post

eststo: qui xtreg women3 HCI lnhh_a_15 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, fe vce(cluster hh_a_05b)
eststo: qui xtlogit women3 HCI lnhh_a_15 hh_a_19 lnhhdsize married3 female dpratio crop_count TLU ///
lnassets_val lntotincome1 cattle sum_area i.year, re vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post
esttab using "$output\womenempower_reg_channels.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Women Empowerment}) ///
varlabels(HCI "Household commercialisation Index" lnhh_a_15 "Log of Age of Household head" hh_a_19 "Years of Schooling of Household head" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
lnhhdsize "Log of household size" ///
lnassets_val "Log of total value of assets"  ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
cattle "Number of cattle owned" ///
sum_area "Area planted (ha)" ///
TLU "Tropical Livestock Units (TLU)")
eststo clear
**
*Women empowerment and productivity
g productivity = sum_prod_value/sum_area
g lnproductivity = ln(productivity)
xtreg lnproductivity women_emp lnhh_a_15 lnhhdsize married3 female dpratio crop_count TLU ///
WealthIndex lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)
xtreg lnproductivity manage lnhh_a_15 lnhhdsize married3 female dpratio crop_count TLU ///
WealthIndex lntotincome1 contractfarm1 i.year, fe vce(cluster hh_a_05b)

*********************************************************************************
*INCOME, POVERTY AND ASSET ACCUMULATION

*Pooled OLS
eststo: qui reg lnpercapita_inc HCI lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall, cluster(hh_a_05b)
eststo: qui reg lnpercapita_inc HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize ///
lnnfarm_inc  married3 female dpratio crop_count TLU lnarea_pla extension1 ///
contractfarm1 lnrainfall, cluster(hh_a_05b)
eststo: qui reg pov_tinc HCI lnhh_a_15 hh_a_19 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 ///
lnrainfall, cluster(hh_a_05b)
eststo: qui reg pov_tinc HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize ///
lnnfarm_inc  married3 female dpratio crop_count TLU lnarea_pla extension1 ///
contractfarm1 lnrainfall, cluster(hh_a_05b)
eststo: qui reg lnassets_val HCI lnhh_a_15 hh_a_19  married3 female dpratio ///
crop_count TLU extension1 contractfarm1 lnrainfall, cluster(hh_a_05b)
eststo: qui reg lnassets_val HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize ///
lnnfarm_inc  married3 female dpratio crop_count TLU lnarea_pla extension1 ///
contractfarm1 lnrainfall, cluster(hh_a_05b)
/*eststo: qui reg hh_e_36 HCI lnhh_a_15 hh_a_19  married3 female dpratio ///
crop_count TLU extension1 contractfarm1 lnrainfall, cluster(hh_a_05b)
eststo: qui reg hh_e_36 HCI_maize HCI_cash lnhh_a_15 hh_a_19  married3 female dpratio ///
crop_count TLU extension1 contractfarm1 lnrainfall, cluster(hh_a_05b)
*/
*Table 5
esttab using "$output\poverty_reg_pooled.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Welfare-Pooled OLS}) ///
varlabels(HCI "Household commercialisation Index" ///
HCI_maize "Food-based" HCI_cash "Cash crop-based" ///
lnhh_a_15 "Log of Age of Household head" ///
hh_a_19 "Years of Schooling of Household head" ///
lnhhdsize "Log of household size" ///
lnnfarm_inc "Log of non farm income" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
extension1 "Access to extension" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
lnarea_pla "log of area planted" ///
TLU "Tropical Livestock Units (TLU)" lnrainfall "Log of July-June total rainfall(mm)")
eststo clear
**

*Fixed Effects
eststo: qui xtreg lnpercapita_inc HCI lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
eststo: qui xtreg lnpercapita_inc HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
eststo: qui xtreg lnassets_val HCI lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
eststo: qui xtreg lnassets_val HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
/*eststo: qui xtreg hh_e_36 HCI lnhh_a_15 hh_a_19 married3 female dpratio ///
crop_count TLU extension1 contractfarm1 lnrainfall i.year, fe cluster(hh_a_05b)
eststo: qui xtreg hh_e_36 HCI_maize HCI_cash lnhh_a_15 hh_a_19 married3 female dpratio ///
crop_count TLU extension1 contractfarm1 lnrainfall i.year, fe cluster(hh_a_05b) */
*Table 6
esttab using "$output\poverty_reg_fe.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 4:}{Smallholder commercialisation and Welfare-Fixed Effects Estimates}) ///
varlabels(HCI "Household commercialisation Index" ///
HCI_maize "Food-based" HCI_cash "Cash crop-based" ///
lnhh_a_15 "Log of Age of Household head" ///
hh_a_19 "Years of Schooling of Household head" ///
lnhhdsize "Log of household size" ///
lnnfarm_inc "Log of non farm income" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
extension1 "Access to extension" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
lnarea_pla "log of area planted" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
TLU "Tropical Livestock Units (TLU)" lnrainfall "Log of July-June total rainfall(mm)")
eststo clear

**
*Table 7
eststo: qui xtreg pov_tinc HCI lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
eststo: qui xtreg pov_tinc HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, cluster(hh_a_05b)
eststo: qui xtlogit pov_tinc HCI lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post
eststo: qui xtlogit pov_tinc HCI_maize HCI_cash lnhh_a_15 hh_a_19 lnhhdsize lnnfarm_inc ///
married3 female dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, vce(cluster hh_a_05b)
eststo: qui margins, dydx(*) post
*Table 5
esttab using "$output\poverty_reg_logit.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 7:}{Smallholder commercialisation and Poverty-Logistic Regression}) ///
varlabels(HCI "Household commercialisation Index" ///
HCI_maize "Food-based" HCI_cash "Cash crop-based" ///
lnhh_a_15 "Log of Age of Household head" ///
hh_a_19 "Years of Schooling of Household head" ///
lnhhdsize "Log of household size" ///
lnnfarm_inc "Log of non farm income" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
extension1 "Access to extension" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
lnarea_pla "log of area planted" ///
TLU "Tropical Livestock Units (TLU)" lnrainfall "Log of July-June total rainfall(mm)")
eststo clear
**
*Mechanisms
eststo: qui xtreg totalcosts1 HCI hh_a_15 hh_a_19 lnhhdsize lnnfarm_inc married3 female ///
dpratio crop_count TLU lnarea_pla extension1 contractfarm1 lnrainfall i.year, fe cluster(hh_a_05b)
eststo: qui xtreg totalcosts1 c.HCI#i.contractfarm1 hh_a_15 hh_a_19 lnhhdsize lnnfarm_inc married3 female ///
dpratio crop_count TLU lnarea_pla extension1 lnrainfall i.year, fe cluster(hh_a_05b)
esttab using "$output\poverty_mechanisms.doc", se rtf replace starlevels( * 0.10 ** 0.05 *** 0.010) nodep ///
stats(N r2)  title({\b Table 7:}{Smallholder commercialisation and Poverty-Mechanisms}) ///
varlabels(HCI "Household commercialisation Index" ///
hh_a_15 "Age of Household head" ///
hh_a_19 "Years of Schooling of Household head" ///
lnhhdsize "Log of household size" ///
lnnfarm_inc "Log of non farm income" ///
female  "Female Headed Household" married3 "Head is married monogamously" ///
extension1 "Access to extension" ///
contractfarm1 "Engaged in contract farming" crop_count "Crop count" ///
lntotincome1 "Log of Total household income" dpratio "Dependency Ratio" ///
lnarea_pla "log of area planted" ///
TLU "Tropical Livestock Units (TLU)" lnrainfall "Log of July-June total rainfall(mm)")
eststo clear



lorenz estimate percapita_inc, over(year) gini
lorenz graph, aspectratio(1) overlay  scheme(scheme-svg)


log close 
exit































