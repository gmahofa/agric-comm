********************************************************************************
*Do File for loading and preparing for cleaning and preparing APRA round 2 data 
*Household Roster and other activities APRA Project
********************************************************************************

clear
set more off, perm 
*Set folders
global root  "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global rawdata "$root\rawdata\APRA_ZIM_2020_3_STATA_All"
global code "$root\code"
global output "$root\output"
global data "$root\data"
***
*1. Check if all surveys had consent. If not drop them. 
use "$rawdata\APRA Survey Instrument November 2020 Zimbabwe WS1 Round 2", clear
sum hh_a_02 if hh_a_02==2
drop if hh_a_02==2
*87 had no consent
********************************************************************************
*Checking wards
tab hh_a_04b, mi /*some wards missing*/
*Correcting ward numbers (given the updated ZEC ward listing)
replace hh_a_04b= 30 if hh_a_05b==9
replace hh_a_04b= 30 if hh_a_05b==10
replace hh_a_04b= 30 if hh_a_05b==7
replace hh_a_04b= 30 if hh_a_05b==8
replace hh_a_04b= 32 if hh_a_05b==1
replace hh_a_04b= 16 if hh_a_05b==2
replace hh_a_04b= 29 if hh_a_05b==3
replace hh_a_04b= 29 if hh_a_05b==4
replace hh_a_04b= 25 if hh_a_05b==5
replace hh_a_04b= 27 if hh_a_05b==11
replace hh_a_04b= 27 if hh_a_05b==17
replace hh_a_04b= 24 if hh_a_05b==13
replace hh_a_04b= 31 if hh_a_05b==14
replace hh_a_04b= 31 if hh_a_05b==15
replace hh_a_04b= 31 if hh_a_05b==16
replace hh_a_04b= 31 if hh_a_05b==17
*Fix hh_a_05b
tab hh_a_05b, mi
numlabel hh_a_05b, add
tab hh_a_05b, mi /*some missing farm names*/
label define hh_a_05b 18 "Forrester J" 19 "Forrester K", add
*Populating the Forrester J and K wards (based on the HH ID derived 
*from interview__id from previous round. HH ID is consistent across the waves not interview__id)
replace hh_a_05b = 18 if hh_a_06 == 270.00 | hh_a_06 == 264.00 | hh_a_06 == 269.00| ///
hh_a_06 == .a |	hh_a_06 == 277.00 | hh_a_06 == 257.00 | hh_a_06 == 267.00 | hh_a_06 == 266.00 | ///
hh_a_06 == 254.00 | hh_a_06 == 282.00 | hh_a_06 == 263.00 | hh_a_06 == 260.00 | ///
hh_a_06 == 268.00 | hh_a_06 == 261.00 | hh_a_06 == 272.00 | hh_a_06 == 256.00 | ///
hh_a_06 == 253.00 | hh_a_06 == 262.00 | hh_a_06 == 265.00 | hh_a_06 == 276.00
replace hh_a_05b = 19 if hh_a_06 == 288.00 | hh_a_06 == 299.00 | hh_a_06 == 284.00 | ///
hh_a_06 == 312.00 | hh_a_06 == 313.00 | hh_a_06 == 297.00 | hh_a_06 == 314.00 | ///
hh_a_06 == 296.00 | hh_a_06 == 291.00 | hh_a_06 == 301.00 | hh_a_06 == 309.00 | ///
hh_a_06	== 306.00 | hh_a_06 == 287.00 | hh_a_06 == 316.00 | hh_a_06 == 294.00 | ///
hh_a_06 == 315.00 | hh_a_06 == 290.00 | hh_a_06 == 295.00 | hh_a_06 == 288.00 | ///
hh_a_06 == 302.00 | hh_a_06 == 317.00 | hh_a_06 == 300.00 | hh_a_06 == 289.00 | ///
hh_a_06 == 304.00 | hh_a_06 == 303.00 | hh_a_06 == 305.00 | hh_a_06 == 310.00 | ///
hh_a_06 == 293.00 | hh_a_06 == 307.00 | hh_a_06 == 286.00 | hh_a_06 == 305.00 | ///
hh_a_06 == 292.00 | hh_a_06 == 285.00
replace hh_a_05b=18 if hh_a_05b==6
**
*Fix remaining ward numbers
replace hh_a_04b = 27 if hh_a_04b==2
*Area
tab hh_a04b1, mi
table hh_a_05b hh_a04b1 /*some inconsistencies-have to fix this*/
replace hh_a04b1 = 1 if  hh_a_05b==11| hh_a_05b==10| hh_a_05b==8| hh_a_05b==9| ///
hh_a_05b==7| hh_a_05b==6| hh_a_05b==5| hh_a_05b==18| hh_a_05b==3| hh_a_05b==4| ///
hh_a_05b==19|hh_a_05b==12
replace hh_a04b1 = 2 if  hh_a_05b==16| hh_a_05b==17| hh_a_05b==15|  hh_a_05b==14 ///
| hh_a_05b==1| hh_a_05b==2|  hh_a_05b==13
table hh_a_05b hh_a04b1
**
replace hh_a_04b=27 if hh_a_04b==6
save "$data\master2020", replace

****************************************************************************
**************II. MERGE WITH HOUSEHOLD MEMBERS & MIGRANTS*******************
****************************************************************************
for var hh_a_13__* :replace X="" if X=="##N/A##"
**
*Migrants (hh_a_13_15 onwards)
ren (hh_a_13a__0 hh_a_13a__1 hh_a_13a__2 hh_a_13a__3 hh_a_13a__4) ///
(hh_a_13__15 hh_a_13__16 hh_a_13__17 hh_a_13__18 hh_a_13__19)
reshape long hh_a_13__, i(interview__id) j(id)
g migrant=(id>14)
table id migrant /*checking if dummy created well*/
ren hh_a_13__ hh_a_13
drop if hh_a_13=="##N/A##"
drop if hh_a_13==""
replace id= id+1
rename id individ_id
*Check for duplicates in names
duplicates report interview__id hh_a_13 
duplicates tag interview__id hh_a_13, g(tagid)
*Do necessary replacements
replace hh_a_13="Christopher Panganai II" if hh_a_13=="Christopher Panganai" & individ_id==5
replace hh_a_13="Natalie Gwanzura II" if hh_a_13=="Natalie Gwanzura" & individ_id==17
replace hh_a_13="yvonne gama II" if hh_a_13=="yvonne gama" & individ_id==20
replace hh_a_13="willard saidi II" if hh_a_13=="willard saidi" & individ_id==18
replace hh_a_13="richard saidi II" if hh_a_13=="richard saidi" & individ_id==19
replace hh_a_13="tinashe nzviramiri II" if hh_a_13=="tinashe nzviramiri" & individ_id==17
replace hh_a_13="paison chibwe II" if hh_a_13=="paison chibwe" & individ_id==17
replace hh_a_13="tarisai chibwe II" if hh_a_13=="tarisai chibwe" & individ_id==18
replace hh_a_13="gift chikuni II" if hh_a_13=="gift chikuni" & individ_id==17
replace hh_a_13="belinda kunjaira II" if hh_a_13=="belinda kunjaira" & individ_id==16
replace hh_a_13="Davison Mavhura II" if hh_a_13=="Davison Mavhura" & individ_id==12
replace hh_a_13="clive katundu II" if hh_a_13=="clive katundu" & individ_id==16
replace hh_a_13="Adon Bandira II" if hh_a_13=="Adon Bandira" & individ_id==16
replace hh_a_13="Tahjah Tapoya II" if hh_a_13=="Tahjah Tapoya" & individ_id==16
*Create new dataset
save "$data\Household Panel_2020.dta", replace
**
*Use hhroster and do necessary replacements (As above)
use "$rawdata\hhroster", clear
replace hh_a_13="Christopher Panganai II" if hh_a_13=="Christopher Panganai" & hhroster__id==5
replace hh_a_13="Davison Mavhura II" if hh_a_13=="Davison Mavhura" & hhroster__id==12
//drop if hh_a_13==""
save "$data\hhroster_modif_2020.dta", replace
*merge with ALL members
use "$data\Household Panel_2020.dta",clear
mer 1:1 interview__id hh_a_13 using "$data\hhroster_modif_2020.dta"
keep if _mer==3
drop _mer 
save "$data\Household Panel_2020_1.dta", replace
**
*Use migrant roster
use "$rawdata\migrantroster", clear
rename hh_a_13a hh_a_13 
rename hh_a_14a hh_a_14
rename hh_a_15a hh_a_15
rename hh_a_15a_months hh_a_15_months 
rename hh_a_16a hh_a_16 
rename hh_a_18a hh_a_18
rename hh_a_19a hh_a_19
rename hh_a_21a hh_a_21
rename hh_a_21a_other hh_a_21_other 
rename hh_a_22a hh_a_22 
rename hh_a_22a_other hh_a_22_other 
rename hh_a_23a hh_a_23
//drop if hh_a_13==""
save "$data\migrantroster_modif2020.dta", replace
**
*Merge with Household panel
use "$data\Household Panel_2020_1.dta", clear
mer 1:1 interview__id hh_a_13 using "$data\migrantroster_modif2020.dta"
drop if _mer==2
drop _mer
save "$data\Household Panel_2020_fin.dta", replace
**

****************************************************************************
*****************************III. AGRICULTURE*******************************
****************************************************************************
*merging with plots & crops
*Was plot cultivated this year?
*Any missing ovserations dropped
use "$rawdata\ag_b_2_plot_roster", clear
inspect ag_b_12 /*check for missing observations*/
tab ag_b_12, mi
drop if missing(ag_b_12)
mer 1:m interview__id ag_b_2_plot_roster__id using "$rawdata\crop_roster_sale"
*there are plots where other crops are grow, so 137 left in master
drop _mer
*minimum other crops * dont analyse other crops in zim
mer m:m interview__id ag_b_2_plot_roster__id using "$rawdata\crop_roster_sale_other"
drop _mer
*Drop if no crops reported
egen cr=rowtotal(ag_b_17__1-ag_b_17__21)
drop if cr==0
*if no crop harvest
*drop if ag_c_1a==.
*Keep all plots cultivated this year
//drop if ag_b_12==2
save "$data\plots_current_year2020.dta", replace
**
*******************************************
*******************Crops*******************
*******************************************
*******create dummy variables for crops****

foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 21{
foreach var in  ag_b_17__`i'{
gen `var'_dummy=1 if `var'>0
replace `var'_dummy=0 if `var'==0
order `var'_dummy, after(`var')
copydesc `var' `var'_dummy
}
}  

foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 21 {
foreach var in  ag_b_17__`i'_dummy {
replace `var'=0 if crop_roster_sale__id!=`i'
}
} 
save "$data\plots_current year2020_1.dta", replace
**
******************************************************************************
******************************COMMERCIALISATION*******************************
******************************************************************************
//HCI = (gross value of all crop sales/gross value of all crop
//production) * 100
//0 = total subsistence; 100 = full commercialisation
*ag_c_1a is production quant, ag_c_4a quant sale, ag_c_5 is value of sale
*Commercialisation
*What was the total value of sales from
*%crop_roster_sale%? [Value]
inspect ag_c_5 ag_c_2 
tab ag_c_2, nol
replace ag_c_5=0 if ag_c_2==2
inspect ag_c_1a
tab ag_c_1b, nol mi
inspect ag_c_4a
tab ag_c_4b, nol mi
**
*****************
*FIX OUTLIERS 
*****************
*MAIZE
*Crop production
inspect ag_c_1a
tab ag_c_1b if crop_roster_sale__id==1, mi
replace ag_c_1b=1 if ag_c_1b==2&crop_roster_sale__id==1&interview__id=="d2dc32b704284a5d8e979e9b05b12863" ///
| ag_c_1b==2&crop_roster_sale__id==1&interview__id=="186c4161236b44258dac12434a5fd014"
*Crop Sales quantity
inspect ag_c_4a if crop_roster_sale__id==1
format ag_c_4a %6.2f
replace ag_c_4a=1.5 if ag_c_4a==30&crop_roster_sale__id==1&interview__id=="0157e2cfa82a493494030d30ac346eda"
replace ag_c_4b=3 if ag_c_4b==7&crop_roster_sale__id==1&interview__id=="0157e2cfa82a493494030d30ac346eda"
replace ag_c_4a=0.5 if ag_c_4a==500&crop_roster_sale__id==1&interview__id=="02d745ca6fdf4798b377678ab1c15e29"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="02d745ca6fdf4798b377678ab1c15e29"
replace ag_c_4a=1000 if ag_c_4a==1&crop_roster_sale__id==1&interview__id=="034a36b8af644bbbb7c11c02c8a0304d"
replace ag_c_4b=2 if ag_c_4b==3&crop_roster_sale__id==1&interview__id=="034a36b8af644bbbb7c11c02c8a0304d"
replace ag_c_4a=1000 if ag_c_4a==20&crop_roster_sale__id==1&interview__id=="070369760ae84d3eb62c56cafdf2b89c"
replace ag_c_4b=2 if ag_c_4b==7&crop_roster_sale__id==1&interview__id=="070369760ae84d3eb62c56cafdf2b89c"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="0ab83f67d5a44b6aada9aba532c90c6d"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="0ab83f67d5a44b6aada9aba532c90c6d"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="0bd77971e67e458dad4c7559b090a14e"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="0bd77971e67e458dad4c7559b090a14e"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="0c40b8af924a4fe4b921d2d415c2f9f7"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="0c40b8af924a4fe4b921d2d415c2f9f7"
replace ag_c_4a=0.5 if ag_c_4a==10&crop_roster_sale__id==1&interview__id=="0e77c7719d2f4d698703acb60baaf782"
replace ag_c_4b=3 if ag_c_4b==7&crop_roster_sale__id==1&interview__id=="0e77c7719d2f4d698703acb60baaf782"
replace ag_c_4a=0.5 if ag_c_4a==500&crop_roster_sale__id==1&interview__id=="132f24d13922429ab6d753fa007ad384"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="132f24d13922429ab6d753fa007ad384"
replace ag_c_4a=1.25 if ag_c_4a==1250&crop_roster_sale__id==1&interview__id=="1aa52d3b889549b2879eaacdb8e0d75c"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="1aa52d3b889549b2879eaacdb8e0d75c"
replace ag_c_4a=0.5 if ag_c_4a==500&crop_roster_sale__id==1&interview__id=="fead4835952942439fde7217f57bf6d4"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="fead4835952942439fde7217f57bf6d4"
replace ag_c_4a=0.25 if ag_c_4a==250&crop_roster_sale__id==1&interview__id=="fe4064b5b5214d489fc7d53ad1a9ab20"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="fe4064b5b5214d489fc7d53ad1a9ab20"
replace ag_c_4a=7.5 if ag_c_4a==7500&crop_roster_sale__id==1&interview__id=="f66c21d291da41aaac989413993ef825"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="f66c21d291da41aaac989413993ef825"
replace ag_c_4a=1000 if ag_c_4a==1&crop_roster_sale__id==1&interview__id=="f564ecb5dccd4971bd3f4e9b168f88b4"
replace ag_c_4b=2 if ag_c_4b==3&crop_roster_sale__id==1&interview__id=="f564ecb5dccd4971bd3f4e9b168f88b4"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="f35b7dacfefb435f8094930f55c0ef10"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="f35b7dacfefb435f8094930f55c0ef10"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="eb4b2b98160c437884ca48a06d24f154"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="eb4b2b98160c437884ca48a06d24f154"
replace ag_c_4a=1.5 if ag_c_4a==1500&crop_roster_sale__id==1&interview__id=="eaaca0acea2a4b119ffa6d5984c89d9a"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="eaaca0acea2a4b119ffa6d5984c89d9a"
replace ag_c_4a=6.5 if ag_c_4a==6500&crop_roster_sale__id==1&interview__id=="e6b332e9807f4e63a5815ac424dd674e"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="e6b332e9807f4e63a5815ac424dd674e"
replace ag_c_4a=3.2 if ag_c_4a==3235&crop_roster_sale__id==1&interview__id=="c9d5eec6c3584181a27b8051a39133c4"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="c9d5eec6c3584181a27b8051a39133c4"
replace ag_c_4a=0.5 if ag_c_4a==500&crop_roster_sale__id==1&interview__id=="c8a886bced774d2a95cfadb86f799bb6"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="c8a886bced774d2a95cfadb86f799bb6"
replace ag_c_4b=3 if ag_c_4b==2&crop_roster_sale__id==1&interview__id=="ad5ff948442846bd89cb16b1f4e09ed2"
*Crop Sales value
inspect ag_c_5 if crop_roster_sale__id==1
**
*TOBACCO
*bundles equivalent to bales if crop is tobacco from comments
replace ag_c_1b=5 if ag_c_1b==4&crop_roster_sale__id==2
replace ag_c_4b=14 if ag_c_4b==13&crop_roster_sale__id==2
replace ag_c_4a=3500 if ag_c_4a==3800&crop_roster_sale__id==2&interview__id=="f5e1956407634347a89799ed79d12a2c"
replace ag_c_4b=14 if ag_c_4b==3&crop_roster_sale__id==2&interview__id=="f92c8d00e449429385a211f9d2146cf8"
replace ag_c_4a=11 if ag_c_4a==770&crop_roster_sale__id==2&interview__id=="c18d8928aa184ffca382de105a64708d"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="c18d8928aa184ffca382de105a64708d"
replace ag_c_4a=17 if ag_c_4a==1900&crop_roster_sale__id==2&interview__id=="bbbcc8744d674df89646a1847118e37e"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="bbbcc8744d674df89646a1847118e37e"
replace ag_c_4a=18 if ag_c_4a==860&crop_roster_sale__id==2&interview__id=="8665e458c07249bb9bf6bfc92a708225"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="8665e458c07249bb9bf6bfc92a708225"
replace ag_c_4a=20 if ag_c_4a==2000&crop_roster_sale__id==2&interview__id=="843d840319d14543b64414494d0e5626"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="843d840319d14543b64414494d0e5626"
replace ag_c_4a=60 if ag_c_4a==5400&crop_roster_sale__id==2&interview__id=="7838571b92154af0aec603d00b72e744"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="7838571b92154af0aec603d00b72e744"
replace ag_c_4a=36 if ag_c_4a==1300&crop_roster_sale__id==2&interview__id=="5df5088e4d42460d857cb5e1bc6148ec"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="5df5088e4d42460d857cb5e1bc6148ec"
replace ag_c_4a=8 if ag_c_4a==800&crop_roster_sale__id==2&interview__id=="56d2211b8aba4d7ca2b310acf7553715"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="56d2211b8aba4d7ca2b310acf7553715"
replace ag_c_4a=29 if ag_c_4a==2600&crop_roster_sale__id==2&interview__id=="4ef26fa8d7ca474588427531fa09b49b"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="4ef26fa8d7ca474588427531fa09b49b"
replace ag_c_4a=17 if ag_c_4a==1300&crop_roster_sale__id==2&interview__id=="47fcb3ced4fb4c7aa4ca09f48d92005b"
replace ag_c_4a=7 if ag_c_4a==700&crop_roster_sale__id==2&interview__id=="46aed6e8773f484988ce0c1a907d09d9"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="46aed6e8773f484988ce0c1a907d09d9"
replace ag_c_4a=20 if ag_c_4a==1600&crop_roster_sale__id==2&interview__id=="2800424bbf7e4221a52437e67b6db22a"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="2800424bbf7e4221a52437e67b6db22a"
replace ag_c_4a=15 if ag_c_4a==1400&crop_roster_sale__id==2&interview__id=="2631bc06533e4d3ba0f18436d81863e1"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="2631bc06533e4d3ba0f18436d81863e1"
replace ag_c_4a=6 if ag_c_4a==800&crop_roster_sale__id==2&interview__id=="1d5d33977b7e45538a73c61b3a02549a"
replace ag_c_4b=14 if ag_c_4b==2&crop_roster_sale__id==2&interview__id=="1d5d33977b7e45538a73c61b3a02549a"
**
*for crop 12-sweet potatoes some hhld report harvesting about 3334 15kg pockets
replace ag_c_4a=334 if ag_c_4a==3334&crop_roster_sale__id==12&interview__id=="20d5be6f03b34b9bb49d8c5d8a48fbbf"
**
*sum by HH
egen sum_ag_c_1a=sum(ag_c_1a), by(interview__id) missing
egen sum_ag_c_5=sum(ag_c_5), by(interview__id) missing
**
*costs
/*replace ag_c_16=. if ag_c_16<0
replace ag_c_17=. if ag_c_17<0
replace ag_c_18=. if ag_c_18<0
replace ag_b_27b=. if ag_b_27b<0
replace ag_b_29d=. if ag_b_29d<0
replace ag_c_16other=. if ag_c_16other<0
replace ag_c_17other=. if ag_c_17other<0
replace ag_c_18other=. if ag_c_18other<0*/
egen sum_ag_c_16=sum(ag_c_16), by(interview__id) missing
egen sum_ag_c_17=sum(ag_c_17), by(interview__id) missing
egen sum_ag_c_18=sum(ag_c_18), by(interview__id) missing
egen sum_ag_b_27b=sum(ag_b_27b), by(interview__id) missing
egen sum_ag_b_29d=sum(ag_b_29d), by(interview__id) missing
egen sum_ag_c_16other=sum(ag_c_16other) , by(interview__id) missing
egen sum_ag_c_17other=sum(ag_c_17other), by(interview__id) missing
egen sum_ag_c_18other=sum(ag_c_18other), by(interview__id) missing
**
*bunch conversion unclear
*IMPUTE price to VALUE HARVEST
*price imputed SALES HARVESTS QUANT
*ag_c_4b crop sale quant unit ag_c_4b_other other units
//replace ag_c_4b=. if ag_c_4b<-1
*conversion factors for harvest where prodn sold to calcualte HCI 
*check units
*tab ag_c_1b_other if ag_b_17__1_dummy==1 | ag_b_17__2_dummy==1
*Harvest
*Kg PRODUCTION QUANTITIES (if sold!!!!)
g conv_harv=1 if ag_c_1b==1
*Tons
replace conv_harv=1000 if ag_c_1b==2
***Bales (all bales for tobacco)
*Tobacco
replace conv_harv=80 if ag_c_1b==5 & crop_roster_sale__id==2
*Sunflower has bales:to confirm weight of bales for sunflower
replace conv_harv=80 if ag_c_1b==5 & crop_roster_sale__id==21
**Bundles
*Onion-not sold
/*replace conv_harv=1 if ag_c_1b==4 & crop_roster_sale__id==13
replace conv_harv=0.01 if ag_c_1b==3 & crop_roster_sale__id==13 & ag_c_1b_other=="bulbs of king onions"*/
*Vegetable
replace conv_harv=1 if ag_c_1b==4 & crop_roster_sale__id==18
*Others
*50kg bag
replace conv_harv=50 if ag_c_1b_other=="12(50) bags of shelled common beans" | ag_c_1b_other=="50 kg bag" ///
| ag_c_1b_other=="24 * 50 bags shelled" | ag_c_1b_other=="3.5 50 kg bags unshelled" | ag_c_1b_other=="4bags of 50kg bags unshelled" ///
| ag_c_1b_other=="5 (50 kgs) of shelled common beans" | ag_c_1b_other=="5 bags of unshelled" ///
| ag_c_1b_other=="50  kg bags" | ag_c_1b_other=="50  kg bags,unshelled" ///
| ag_c_1b_other=="50 Kg bags of unshelled"| ag_c_1b_other== "50 Kg bags of unshelled groundnuts" ///
| ag_c_1b_other=="50 kg bags of unshelled groundnut" | ag_c_1b_other=="50 bags" ///
| ag_c_1b_other=="50 kg bag"| ag_c_1b_other== "50 kg bag unshelled" ///
| ag_c_1b_other=="50 kg bags" | ag_c_1b_other=="50 kg bags of unshelled" ///
| ag_c_1b_other=="50 kg bags of unshelled groundnuts" | ag_c_1b_other== "50 kg bags of unshelled nuts" ///
| ag_c_1b_other=="50 kg bags shelled" | ag_c_1b_other=="50 kg bags unshelled" ///
| ag_c_1b_other=="50 kg bags unshelled groundnuts" | ag_c_1b_other=="50 kg bags, unshelled" ///
| ag_c_1b_other=="50 kg bags,unshelled" | ag_c_1b_other=="50 kg empty bags" ///
| ag_c_1b_other=="50 kg empty bags of unshelled groundnuts" | ag_c_1b_other=="50 kg of unshelled groundnuts" ///
| ag_c_1b_other=="50 kgs" | ag_c_1b_other=="50 kgs bag" | ag_c_1b_other=="50 kgs bags" ///
| ag_c_1b_other=="50 kgs bags of unshelled groundnuts" | ag_c_1b_other=="50kg bag" ///
| ag_c_1b_other=="50kg bag -unshelled" | ag_c_1b_other=="50kg bag . the beans was affected by the drought hence didn't yield much" ///
| ag_c_1b_other=="50kg bag unshelled" | ag_c_1b_other=="50kg bags" | ag_c_1b_other=="50kg bags of unshelled" ///
| ag_c_1b_other=="50kg bags shelled" | ag_c_1b_other=="50kg bags unshelled" ///
| ag_c_1b_other=="50kg bags unshelled groundnuts" | ag_c_1b_other=="50kg bags, unshelled" ///
| ag_c_1b_other=="50kg bags,unshelled" | ag_c_1b_other=="50kg sacks unshelled" ///
| ag_c_1b_other=="50kg unshelled bags" | ag_c_1b_other=="50kgs bad unshelled" ///
| ag_c_1b_other=="50kgs bag" | ag_c_1b_other=="50kgs bag unshelled" ///
| ag_c_1b_other=="59 kg bags unshelled" | ag_c_1b_other=="8 50kg bags shelled" ///
| ag_c_1b_other=="unshelled 50kg bags" | ag_c_1b_other=="unshelled groundnuts" ///
| ag_c_1b_other=="bags" | ag_c_1b_other=="20 bags of unshelled groundnuts packed in 50kg bags" 
*15 kg bags/pockets of ??
replace conv_harv=15 if ag_c_1b_other=="pockets"| ag_c_1b_other== "15 kg pockets" 
*20 litre buckets
replace conv_harv=20 if ag_c_1b_other=="20 LITRE BUCKETS"| ag_c_1b_other== "20 litre bucket" ///
| ag_c_1b_other=="20 litre buckets"| ag_c_1b_other=="20 litre buckets of unshelled groundnuts" ///
| ag_c_1b_other=="20 litre gallon"| ag_c_1b_other== "20 litre tin" ///
| ag_c_1b_other=="20l bucket"| ag_c_1b_other=="20l buckets"| ag_c_1b_other=="20litre bucket" ///
| ag_c_1b_other=="20litre buckets" | ag_c_1b_other=="buckets" 
*1 Scoth cart is approx 800 L (each litre approx 0.32 kg) , so 256 kg
replace conv_harv=500 if ag_c_1b_other=="Scotch carts" | ag_c_1b_other=="carts"
*BUTTERNUT-assuming 2 butternuts in a packing bag
replace conv_harv=1 if ag_c_1b_other=="transparent packing bags" & crop_roster_sale__id==17
*90kg bags
replace conv_harv=90 if ag_c_1b_other=="90 kg bags"
*10 litre tin
replace conv_harv=10 if ag_c_1b_other=="10 litre tin"
/*tomato
*box of tomato weighs approx 7kg
replace conv_harv=7 if ag_c_1b==3 & ag_c_1b_other=="boxes" & crop_roster_sale__id==15
replace conv_harv=7 if ag_c_1b==3 & ag_c_1b_other=="65 x 30 cm crates" & crop_roster_sale__id==15 ///
| ag_c_1b==3 & ag_c_1b_other=="crates" & crop_roster_sale__id==15
replace conv_harv=28 if ag_c_1b==3 & ag_c_1b_other=="4 separate loads in a pick up truck" & crop_roster_sale__id==15 
*pockets of irish potato
replace conv_harv=15 if ag_c_1b==3 & ag_c_1b_other=="pockets" & crop_roster_sale__id==11 
*bucket of sweetpotat
replace conv_harv=20 if ag_c_1b==3 & ag_c_1b_other=="buckets" & crop_roster_sale__id==12
*truck loads
replace conv_harv=28 if ag_c_1b==3 & ag_c_1b_other=="truck loads" & crop_roster_sale__id==18

replace conv_harv=50 if ag_c_1b==1 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==7 ///
& interview__id=="7dfd4a8ec8594fd892e70e1f330c2461" */

*use harvest quant units conversion to give prod quant
/*replace ag_c_1a=. if ag_c_1a<0
replace ag_c_1aother=. if ag_c_1aother<0*/

*NEED TO DIVIDE SALES QUANTITY WITH SALES value to impute prices
*prices below to value harevst
/*replace ag_c_4b=. if ag_c_4b<0
replace ag_c_4bother=. if ag_c_4bother<-1*/
g conv_sale=1 if ag_c_4b==2
//replace conv_sale=0.001 if ag_c_4b==1
replace conv_sale=1000 if ag_c_4b==3

*5 litres tin (gallon) error, should be a kg
replace conv_sale=1 if ag_c_4b==5
*20 litre tin
replace conv_sale=20 if ag_c_4b==6
*50 kg bag
replace conv_sale=50 if ag_c_4b==7
*90 kg bag
replace conv_sale=50 if ag_c_4b==8
*Bunch of vegetables
replace conv_sale=1 if ag_c_4b==12 | ag_c_4b==13
*bales
replace conv_sale=80 if ag_c_4b==14 
*
replace conv_sale=15 if ag_c_4b_other=="15 kg pockets"| ag_c_4b_other== "15kg pockets" | ag_c_4b_other=="pockets"
*
replace conv_sale=20 if ag_c_4b_other=="20 litre bucket"
*
replace conv_sale=50 if ag_c_4b_other=="50 kg bags,unshelled" | ag_c_4b_other=="50kg bags ,unshelled"
*cart
replace conv_sale=500 if ag_c_4b==15 & ag_c_4b_other=="carts"
**********************************************
//Conversions
g ag_c_1a_units=ag_c_1a*conv_harv if ag_c_1a!=.
g ag_c_4a_units=ag_c_4a*conv_sale if ag_c_4a!=.
*account stock sales
replace ag_c_4a_units=ag_c_1a_units if ag_c_1a_units<ag_c_4a_units
*impute price using value sales divided by value quant sold
 g regprice_crop=ag_c_5/ag_c_4a_units
 *clean up prices
 *egen x= mean(regprice_crop) if regprice_crop!=., by(crop_roster_sale__id)
 *range tobacco price
*replace regprice_crop=x if regprice_crop>10 & regprice_crop!=. | regprice_crop<10 & regprice_crop!=.
*drop x
*value production by imputed prices
g prod_value= ag_c_1a_units*regprice_crop if ag_c_1a_units!=. & regprice_crop!=.
egen sum_prod_value=sum(prod_value), by(interview__id) missing
g HCI= (sum_ag_c_5/sum_prod_value)*100 if sum_ag_c_5!=. & sum_prod_value!=. 
*replace if HCI is above 100 (slightly)
replace HCI=100 if HCI>101 & HCI!=.
*Duplicates in terms of interview__id sum_ag_c_5
g x=ag_c_2
replace x=. if ag_c_2==2
egen crop_sale=max(x), by(interview__id) 
replace crop_sale=0 if crop_sale==.
egen sum_ag_c_1a_units=sum(ag_c_1a_units), by(interview__id) missing
lab var sum_ag_c_1a_units "Production quantity in kgs"
lab var sum_ag_c_5 "Gross value of crop sales"
save "$data\HCI commercialisation plot crop2020.dta", replace
********************************************************************************
********************************************************************************
***HH Demographics
use "$rawdata\hhroster", clear
order interview__id interview__key
inspect hh_a_15  /*age */

tab hh_a_18, mi  /*marital status */
inspect hh_a_19 /*years of schooling*/
sum hh_a_19, d

tab hh_a_20, mi /*work on hhd agricultural activities*/
tab hh_a_21, mi /*mainoccupation*/

tab hh_a_22, mi /*second occupation*/
tab hh_a_23, mi
tab hh_a_23, g(outschool)

*Household composition variables including hhd size
byso interview__id:egen hhdsize = count(hhroster__id)
lab var hhdsize "Household size"
byso interview__id: egen chdn = total(hh_a_15 <= 14) /*total number of chdn*/
lab var chdn "Number of children 0-14"
byso interview__id: egen nofemale = total(hh_a_15 <= 14&hh_a_14 == 2) /*female children less than 14*/
lab var nofemale "Number of female children below the age of 14"
byso interview__id: egen nomale = total(hh_a_15 <= 14&hh_a_14 == 1) /*male children less than 14*/
lab var nomale "Number of male children below the age of 14"
byso interview__id: egen youth = total(inrange(hh_a_15, 15,34)) 
lab var youth "Number of youth 15-34"
byso interview__id: egen youthmale = total(inrange(hh_a_15, 15,34) & hh_a_14 == 1)
lab var  youthmale "Number of male youth 15-34"
byso interview__id: egen youthfmale = total(inrange(hh_a_15, 15,34) & hh_a_14 == 2) 
lab var  youthfmale "Number of female youth 15-34"
byso interview__id: egen adult = total(inrange(hh_a_15, 35,60)) 
lab var adult "Number of adults 35-60"
byso interview__id: egen adultmale = total(inrange(hh_a_15, 35,60) & hh_a_14 == 1) /* adult male between 35 and 60*/
lab var adultmale "Adult male aged between 35 and 60"
byso interview__id: egen adultfemale = total(inrange(hh_a_15, 35,60) & hh_a_14 == 2) /* adult female between 35 and 60*/
lab var adultfemale "Adult female aged between 35 and 60"
byso interview__id: egen old = total(hh_a_15 > 60& hh_a_15 != .) 
lab var old "Number of elders"
byso interview__id: egen oldfemale = total(hh_a_15 > 60 & hh_a_14 == 2 & hh_a_15 != .) /* old female between 35 and 60*/
lab var oldfemale "Number of female members aged 60 and above"
byso interview__id: egen oldmale = total(hh_a_15 > 60 & hh_a_14 == 1 & hh_a_15 != .) /* old female between 15 and 60*/
lab var oldmale "Number of male members aged 60 and above"
save "$data\hhd_demographics2020", replace
**

**OUTCOME INDICATORS
use "$rawdata\APRA Survey Instrument November 2020 Zimbabwe WS1 Round 2", replace
//drop if hh_a_02==2
*retrieving assets involving string variables (asbestos)
tab hh_e_25b
label define hh_e_25a  10 "asbestos", add
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "asbestos"
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "Asbestos"
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "asbestors"
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "asbestos and iron sheets"
replace hh_e_25a=6 if hh_e_25a==9 & hh_e_25b=="Iron Sheets" | hh_e_25b=="Iron sheets" ///
| hh_e_25b=="Tiles" | hh_e_25b=="Zinc" | hh_e_25b=="corrugated iron steel" ///
| hh_e_25b=="iron sheets" | hh_e_25b=="zinc" 
label define hh_e_26a  11 "iron sheets", add
replace hh_e_26a=11 if hh_e_26a==10 & hh_e_26b=="iron sheetings"
replace hh_e_27a=8 if hh_e_27a==9 & hh_e_27b=="bricks"
replace hh_e_28a=3 if hh_e_28a==6 & hh_e_28b=="A pit with  walls which  are built with grass"
replace hh_e_28a=3 if hh_e_28a==6 & hh_e_28b=="thatched toilet" | hh_e_28b=="mapango" ///
| hh_e_28b=="thatched"
label define hh_e_30a 6 "borehole", add
replace hh_e_30a=6 if hh_e_30a==5 & hh_e_30b=="borehole"
replace hh_e_31a=2 if hh_e_31a==9 & hh_e_31b=="candles"
label define hh_e_31a 11 "batteries", add
replace hh_e_31a=11 if hh_e_31a==9 & hh_e_31b=="Torch" | hh_e_31b=="battery Torch" ///
| hh_e_31b=="battery torch" | hh_e_31b=="battery torches" | hh_e_31b=="battery torçh" ///
| hh_e_31b=="torches and phones" | hh_e_31b=="torches that uses cell batteries" ///
| hh_e_31b=="torches that uses battery cells" | hh_e_31b=="torches ,charged with car battery" ///
| hh_e_31b=="rechargeable lights" | hh_e_31b=="phones" | hh_e_31b=="phone torch" ///
| hh_e_31b=="phone light and torches" | hh_e_31b=="phone light" | hh_e_31b=="phone & torch" ///
| hh_e_31b=="lights connected to batteries" | hh_e_31b=="battery connected to bulb" ///
| hh_e_31b=="battery Torch"
replace hh_e_31a=8 if hh_e_31a==9 & hh_e_31b=="Solar Torch" | hh_e_31b=="solar torch" 
**
***dummies for PCA
*Main roof material (hh_e_25a)
tab hh_e_25a, g(roof)
ren (roof1 roof2 roof3) (roof_grass roof_corrugated roof_Asbestos)
**Main Wall material (hh_e_26a)
tab hh_e_26a, g(Wall)
ren (Wall1 Wall2 Wall3 Wall4 Wall5 Wall6 Wall7) (Wall_dirt Wall_woodbamboo Wall_ConcreteCement ///
Wall_Cement Wall_Woodplanks Wall_TiledBricks Wall_ironsheets)
***Main floor material (hh_e_27a)
tab hh_e_27a, g(floor)
ren (floor1 floor2 floor3 floor4 floor5 floor6 floor7 floor8) (floor_dirt floor_cowdung ///
floor_cowdungandsoil floor_stone floor_concrete floor_cement floor_woodplanks floor_tiledbricks)
***Main type of toilet you use
tab hh_e_28a, g(toilet)
ren (toilet1 toilet2 toilet3 toilet4 toilet5) (toilet_nofacility toilet_panbucket ///
toilet_pitlatrine toilet_ventilated toilet_flush)
***The main type of cooking fuel you use in your house
tab hh_e_29a, g(cookingfuel)
ren (cookingfuel1 cookingfuel2 cookingfuel3 cookingfuel4 cookingfuel5) ///
(cookingfuel_firewood cookingfuel_charcoal cookingfuel_electricity cookingfuel_gas cookingfuel_solar)
***Main source of water for drinking
tab hh_e_30a, g(Water)
ren (Water1 Water2 Water3 Water4 Water5) (Water_natural Water_unprotectedwell ///
Water_protectedwell Water_pipedsupply Water_Borehole)
***Main source of lighting energy.
tab hh_e_31a, g(Lighting)
ren (Lighting1 Lighting2 Lighting3 Lighting4 Lighting5 Lighting6 Lighting7 Lighting8) ///
(Lighting_candles Lighting_firewood Lighting_paraffin Lighting_electricity Lighting_gas ///
Lighting_solar Lighting_other Lighting_battery)
***Creating Wealth index PCA (all assets and living conditions)
global xlist hh_e_23a__* hh_e_24a__* roof_grass roof_corrugated roof_Asbestos Wall_dirt-Lighting_battery
global id interview__id
pca $xlist, mineigen(1)
predict WealthIndex
xtile WealthClass= WealthIndex, nq(3)
**
***Creating Production Asset Index (only focusing on the 11 production equipment)
global xlist hh_e_23a__*
global id interview__id
pca $xlist, mineigen(1) 
predict ProductionAssetIndex
xtile ProductionAssetClass= ProductionAssetIndex, nq(3)
**
***GENERATING THE MULTIDIMENSIONAL POVERTY INDEX (MPI)*** 
*1. Any child death in the family (hh_f_10)
g ChildDeath=( hh_f_10==1)
**
*2. Whether a member is malnourished (hh_f_2__1; hh_f_2__2; hh_f_2__3; hh_f_2__4; hh_f_2__5; hh_f_2__6; hh_f_2__7; hh_f_2__8; hh_f_2__9)
***household considered malnourished if they experience any of the listed cases
g Malnourished=0
replace Malnourished=1 if hh_f_2__1==1| hh_f_2__2==1| hh_f_2__3==1| hh_f_2__4==1| hh_f_2__5==1| hh_f_2__6==1| hh_f_2__7==1| hh_f_2__8==1| hh_f_2__9==1

*3. Household has no electricity (hh_e_31a) 
**household has no electricity if primary source of lighting is not electricity
g NoElectricity=(hh_e_31a !=6)
*4. Household’s sanitation facility is not improved (hh_e_28a) 
**improved sanitation includes pit latrine, ventilated pit latrine and flush toilet. The rest are unimproved options (no facility, field, bush, bucket, thatch )
g UnimprovedSanitation=0
replace UnimprovedSanitation=1 if hh_e_28a==1 | hh_e_28a==2 | hh_e_28a==6
*5. Household does not have access to safe drinking water (If hh_e_30a)
***safe drinking water regarded as protected well/spring, taped water and borehole. The rest are considered unsafe (natural river, unprotected wells)
g UnsafeDrinkingWater=0
replace UnsafeDrinkingWater =1 if hh_e_30a==1|hh_e_30a==2

*6. Household has a mud or sand floor (hh_e_27a)
**Improved floor covers any of: (a) Concrete (b) Cement (c) Wood Planks (d) Tiled/Bricks. The rest are considered unimproved (dirt, dung, dung and soil, stone) 
g UnImprovedFloor=0
replace UnImprovedFloor =1 if hh_e_27a==1|hh_e_27a==2|hh_e_27a==3|hh_e_27a==4

*7. Household cooks with wood or charcoal (hh_e_29a)
**Improved cooking covers electricity, paraffin/ kerosene, gas and solar. The rest are unimproved (leaves, cow-dung, firewood, charcoal) 
g UnimprovedCookingFuel=0
replace UnimprovedCookingFuel=1 if hh_e_29a==1|hh_e_29a==2|hh_e_29a==3|hh_e_29a==4

*8. Household does not own more than one asset (radio, TV, telephone, bike, motorbike,refrigerator), and does not own car (hh_e_24a).

***series of assets dummies (1=Yes, 0=No) on the consumer durables 
egen NumberDurableAssets = anycount(hh_e_24a__3 hh_e_24a__4 hh_e_24a__5 hh_e_24a__7 hh_e_24a__8 hh_e_24a__9), values(1)
gen AssetsDeprived=0
replace AssetsDeprived=1 if NumberDurableAssets<2 & hh_e_24a__10==0
keep interview__id hh_a04b1 hh_a_06 roof_grass-AssetsDeprived
so interview__id
save "$data\Assets_index.dta", replace
**
use "$rawdata\hhroster.dta", clear
keep interview__id hhroster__id hh_a_13 hh_a_14 hh_a_15 hh_a_15_months hh_a_16 hh_a_17 hh_a_18 ///
hh_a_19 hh_a_20 hh_a_21 hh_a_21_other hh_a_22 hh_a_23 hh_f_5 hh_f_6a hh_f_6b ///
hh_f_6c hh_f_6d  hh_a_22_other
reshape wide hh_a_13 hh_a_14 hh_a_15 hh_a_15_months hh_a_16 hh_a_17 hh_a_18 ///
hh_a_19 hh_a_20 hh_a_21 hh_a_21_other hh_a_22 hh_a_23 hh_f_5 hh_f_6a hh_f_6b ///
hh_f_6c hh_f_6d  hh_a_22_other, i(interview__id) j(hhroster__id)
*1. HHD members that does not have 5 Years of Schooling (years of schooling variable hh_a_19)
egen no5years = anycount( hh_a_191 hh_a_192 hh_a_193 hh_a_194 hh_a_195 hh_a_196 ///
hh_a_197 hh_a_198 hh_a_199 hh_a_1910 hh_a_1911 hh_a_1912 hh_a_1913 hh_a_1914 hh_a_1915 ), values(1 2 3 4)
g LackSchooling=0
replace LackSchooling=1 if no5years >0
*2. Any school age child is not in primary school (hh_a_23)
egen outschool = anycount( hh_a_231 hh_a_232 hh_a_233 hh_a_234 hh_a_235 hh_a_236 hh_a_237 hh_a_238 hh_a_239 hh_a_2310 hh_a_2311 hh_a_2312 hh_a_2313 hh_a_2314 hh_a_2315 ), values(1)
g OutofSchool=0
replace OutofSchool=1 if outschool >0
save "$data\hhroster_wide without schooling2020.dta", replace 
**
use "$data\Assets_index.dta", clear
mer 1:1 interview__id using "$data\hhroster_wide without schooling2020.dta"
keep if _mer==3
drop _mer
***MPI stata code**
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) ///
d3(NoElectricity UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor ///
UnimprovedCookingFuel AssetsDeprived) w1(0.16 0.16) w2(0.16 0.16) ///
w3(0.06 0.06 0.06 0.06 0.06 0.06), cutoff(0.3) deprivedscore(MPI_score) depriveddummy(MPI_class)

*no weights
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) ///
d3(NoElectricity UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor ///
UnimprovedCookingFuel AssetsDeprived), cutoff(0.3) deprivedscore(MPI_score1) depriveddummy(MPI_class1)

*by Mvurwi vs Concession (Hotspot-Coldspot)
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) ///
d3(NoElectricity UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor ///
UnimprovedCookingFuel AssetsDeprived), cutoff(0.3) by(hh_a04b1 )
save "$data\AssetIndex_MPI.dta", replace
**
*******% households who grew a particular crop**
use "$data\plots_current year.dta", clear
order interview__id interview__key
preserve
keep interview__id ag_b_17__*_dummy
g tobacco_grow = (ag_b_17__2_dummy == 1) if ag_b_17__2_dummy !=.
g soya_grow = (ag_b_17__8_dummy == 1&ag_b_17__2_dummy != 1)
g no_tob_soya = (ag_b_17__8_dummy == 0&ag_b_17__2_dummy == 0)
g tob_soy_grow = (ag_b_17__2_dummy == 1 | ag_b_17__8_dummy == 1)
collapse (sum) tobacco_grow-tob_soy_grow, by(interview__id)
for var tobacco_grow-tob_soy_grow: replace X=1 if X>1 
save "$data\crops grown2020.dta", replace
restore
**
***dummy for crop sales**
tab ag_c_2, g(cropsales)
ren cropsales2 nocropsales
gen sale_maize=0
replace sale_maize=1 if ag_c_2==1 & crop_roster_sale__id==1
g sale_tobacco=0
replace sale_tobacco=1 if ag_c_2==1 & crop_roster_sale__id==2
g sale_groundnut=0
replace sale_groundnut=1 if ag_c_2==1 & crop_roster_sale__id==3
g sale_cowpeas=0
replace sale_cowpeas=1 if ag_c_2==1 & crop_roster_sale__id==6
g sale_commonbean=0
replace sale_commonbean=1 if ag_c_2==1 & crop_roster_sale__id==7
g sale_soyabean=0
replace sale_soyabean=1 if ag_c_2==1 & crop_roster_sale__id==8
g sale_sorghum=0
replace sale_sorghum=1 if ag_c_2==1 & crop_roster_sale__id==9
g sale_sweetpotato=0
replace sale_sweetpotato=1 if ag_c_2==1 & crop_roster_sale__id==12
g sale_tomato=0
replace sale_tomato=1 if ag_c_2==1 & crop_roster_sale__id==15
label variable sale_maize "was maize sold"
label variable sale_tobacco "was tobacco sold "
label variable sale_groundnut "was groundnut sold"
label variable sale_cowpeas "was cowpea sold"
label variable sale_commonbean "was common bean sold"
label variable sale_soyabean "was soyabean sold"
label variable sale_sorghum "was sorghum sold"
label variable sale_sweetpotato "was sweet potato sold "
label variable sale_tomato "was tomato sold"
preserve
collapse (sum) nocropsales sale_maize sale_tobacco sale_groundnut sale_cowpeas ///
sale_commonbean sale_soyabean sale_sorghum sale_sweetpotato sale_tomato, ///
by(interview__id)
for var nocropsales sale_maize-sale_tomato:replace X=1 if X>1
save "$data\crops sold2020.dta", replace
restore
**
***generating total cropped area for each crop (in Hectares)*
tab ag_b_04b_2020,mi
g CropArea=0
replace CropArea = ag_b_04a_2020 if ag_b_04b ==2
replace CropArea = ag_b_04a_2020/ 2.471 if ag_b_04b ==1 
replace CropArea = ag_b_04a_2020/10000 if ag_b_04b ==3
lab var CropArea "Area cropped in Hectares"
g maize_ha = CropArea if crop_roster_sale__id==1
g tobacco_ha = CropArea if crop_roster_sale__id==2
g groundnuts_ha = CropArea if crop_roster_sale__id==3
g cowpeas_ha = CropArea if crop_roster_sale__id==6
g commonbean_ha = CropArea if crop_roster_sale__id==7
g soyabean_ha = CropArea if crop_roster_sale__id==8
g sorghum_ha = CropArea if crop_roster_sale__id==9
g sweetpotato_ha = CropArea if crop_roster_sale__id==12
g tomato_ha = CropArea if crop_roster_sale__id==15
label variable maize_ha "maize area in HA"
label variable tobacco_ha "tobacco area in HA "
label variable groundnuts_ha "groundnut area in HA"
label variable cowpeas_ha "cowpeas area in HA"
label variable commonbean_ha "common bean area in HA "
label variable soyabean_ha "soyabean area in HA"
label variable sorghum_ha "sorghum area in HA "
label variable sweetpotato_ha "sweet potato area in HA"
label variable tomato_ha "tomato area in HA" 
collapse (sum) CropArea, by(interview__id  crop_roster_sale__id)
sum CropArea if crop_roster_sale__id ==1
sum CropArea if crop_roster_sale__id ==2
sum CropArea if crop_roster_sale__id ==3
sum CropArea if crop_roster_sale__id ==6
sum CropArea if crop_roster_sale__id ==7
sum CropArea if crop_roster_sale__id ==8
sum CropArea if crop_roster_sale__id ==9
sum CropArea if crop_roster_sale__id ==12
sum CropArea if crop_roster_sale__id ==15 
reshape wide CropArea, i(interview__id) j(crop_roster_sale__id)
save "$data\Crops Area2020.dta", replace
**
*crop production
use "$data\HCI commercialisation plot crop2020.dta", clear
preserve
keep interview__id interview__id ag_b_2_plot_roster__id crop_roster_sale__id ag_c_1a_units
collapse (sum) ag_c_1a_units, by(interview__id crop_roster_sale__id)
ren ag_c_1a_units output
reshape wide output, i(interview__id) j(crop_roster_sale__id)
save "$data\crop_output2020", replace
restore
**
*INPUTS USE (Labour, Seeds, chemicals) at hhd level
*Use of artificial fertilisers
tab ag_b_28a__1,mi
preserve
keep interview__id ag_b_2_plot_roster__id ag_b_28a__1
collapse (sum) ag_b_28a__1, by(interview__id)
g fert_use=(ag_b_28a__1>0)
lab var fert_use "Household used artificial fertiliser"
drop ag_b_28a__1
save "$data\fert_use", replace
restore
**
*Tractor Tillage services
tab ag_b_29b__1
collapse (sum) ag_b_29b__1, by(interview__id)
g tr_tillage=(ag_b_29b__1>0)
drop ag_b_29b__1
lab var tr_tillage "Household used tractor tillage services"
save "$data\tr_tillage", replace
**
use "$data\fert_use", clear
mer 1:1 interview__id using "$data\tr_tillage"
drop _mer
save "$data\fert_tillage", replace
**
*hired lab used
use "$rawdata\services_hired", clear
order interview__id interview__key ag_b_2_plot_roster__id
g mandays = ag_b_22*ag_b_23
collapse mandays (sum) ag_b_24 other_remun_value, by(interview__id)
save tmp, replace
**
use "$rawdata\Additional_Inputs", clear
order interview__id interview__key crop_roster_sale__id ag_b_2_plot_roster__id
collapse (sum) ag_b_30d, by(interview__id)
ren ag_b_30d add_inputs
lab var add_inputs "Cost of additional inputs"
save "$data\add_inputs2020", replace
**
use "$rawdata\Other_Inputs", clear
order interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id
collapse (sum) ag_b_34, by(interview__id)
save "$data\other_inputs2020", replace

use "$data\fert_tillage", clear
mer 1:1 interview__id using tmp
drop _mer
replace mandays=0 if mandays==.
mer 1:1 interview__id using "$data\add_inputs"
drop _mer
mer 1:1 interview__id using "$data\other_inputs"
drop _mer
ren ag_b_24 hlab_cost
lab var hlab_cost "cost of hired lab"
ren ag_b_34 other_input
lab var other_input "cost of other inputs"
save "$data\input_use", replace
**
****livestock information***
use "$rawdata\livestockroster.dta", clear
*raised
sum ag_d_2 if livestockroster__id==1
sum ag_d_2 if livestockroster__id==2
sum ag_d_2 if livestockroster__id==3
sum ag_d_2 if livestockroster__id==3
sum ag_d_2 if livestockroster__id==4
sum ag_d_2 if livestockroster__id==5
sum ag_d_2 if livestockroster__id==6

**owned
sum ag_d_3 if livestockroster__id==1
sum ag_d_3 if livestockroster__id==2
sum ag_d_3 if livestockroster__id==3
sum ag_d_3 if livestockroster__id==4
sum ag_d_3 if livestockroster__id==5
sum ag_d_3 if livestockroster__id==6
preserve
keep interview__id livestockroster__id ag_d_3
reshape wide ag_d_3, i(interview__id) j(livestockroster__id)
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
save "$data\livestock", replace
restore
collapse (sum) ag_d_14 ag_d_11 ag_d_12 ag_d_12b ag_d_12c, by(interview__id)
lab var ag_d_14 "Live livestock sales"
lab var ag_d_11 "cost of veterinary drugs"
lab var ag_d_12 "cost of feed"
lab var ag_d_12b "labor cost:livestock"
lab var ag_d_12c "other livestock costs"
save "$data\livestockcosts2020", replace
**
use "$rawdata\livestock_produce", clear
collapse (sum) ag_d_19, by(interview__id)
lab var ag_d_19 "sales of livestock produce"
save "$data\live_produce2020", replace
**
*marketing costs
use "$rawdata\Sale_Modality", clear
collapse (sum) ag_c_13, by(interview__id)
lab var ag_c_13 "transport costs"
save "$data\transportcosts2020", replace
**
/*use "$rawdata\Sale_Modality_other", clear
collapse (sum) ag_c_13other, by(interview__id)
lab var ag_c_13other "other crop transport costs"
save "$data\othertransportcosts2020", replace*/
**
use "$rawdata\crop_roster_sale", clear
collapse (sum) ag_c_16 ag_c_17 ag_c_18,by(interview__id)
lab var ag_c_16 "grading costs"
lab var ag_c_17 "curing/milling costs"
lab var ag_c_18 "storing costs"
save "$data\marketingcosts2020", replace
**
use "$rawdata\crop_roster_sale_other", clear
collapse (sum) ag_c_16other ag_c_17other ag_c_18other, by(interview__id)
lab var ag_c_16other "other grading costs"
lab var ag_c_17other "other curing/milling costs
lab var ag_c_18other "other storing costs"
save "$data\marketingcosts_other2020", replace
**
use "$data\transportcosts2020", clear
mer 1:1 interview__id using "$data\marketingcosts2020"
drop _mer
mer 1:1 interview__id using "$data\marketingcosts_other2020"
drop _mer
save "$data\marketingcosts_fin2020", replace
**

**
*CREATE VARIABLES IDENTIFYING WOMEN EMPOWERMENT
use "$rawdata\hhroster", clear
keep hhroster__id hh_a_14 interview__id
order interview__id
so interview__id hhroster__id
save tmp, replace
**
use "$rawdata\ag_b_2_plot_roster", clear
order interview__id
keep interview__id ag_b_2_plot_roster__id ag_b_10__14 ag_b_09__0-ag_b_10__14
save tmp1, replace
*
ren  ag_b_09__0 hhroster__id
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer
keep interview__id ag_b_2_plot_roster__id hh_a_14
reshape wide hh_a_14, i(interview__id) j(ag_b_2_plot_roster__id)
g manage=(hh_a_141==2 | hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2) if ///
hh_a_141!=. | hh_a_142!=. | hh_a_143!=. | hh_a_144!=. | ///
hh_a_145!=. | hh_a_146!=. | hh_a_147!=. | hh_a_148!=. 
drop hh_a_14*
lab var manage "Women involved in primarily managing plots"
save tmp2, replace
*Who primarily decides how the outputs from the plot are used (consumption or sales of crops, etc.)?
use tmp1, clear
ren  ag_b_10__0 hhroster__id
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer
keep interview__id ag_b_2_plot_roster__id hh_a_14
reshape wide hh_a_14, i(interview__id) j(ag_b_2_plot_roster__id)
g manage1=(hh_a_141==2 | hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2) if ///
hh_a_141!=. | hh_a_142!=. | hh_a_143!=. | hh_a_144!=. | ///
hh_a_145!=. | hh_a_146!=. | hh_a_147!=. | hh_a_148!=.
drop hh_a_14*
lab var manage1 "Women involved in deciding how the outputs from the plot are used"
save tmp3, replace
**
use "$rawdata\crop_roster_sale", clear
order interview__id ag_b_2_plot_roster__id
*maize  and tobacco decision
//keep if crop_roster_sale__id==1 | crop_roster_sale__id==2
keep interview__id ag_b_2_plot_roster__id crop_roster_sale__id ag_c_3
duplicates drop interview__id crop_roster_sale__id ag_c_3, force
ren ag_c_3 hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer
keep interview__id hh_a_14 
byso interview__id: egen manage=total(hh_a_14==2)
keep interview__id manage
duplicates drop
replace manage=1 if manage>0
ren manage manage2
lab var manage2 "Women involved in deciding whether to sell crop"
save tmp4, replace
**
use "$rawdata\Sale_Modality", clear
order interview__id ag_b_2_plot_roster__id crop_roster_sale__id
keep interview__id ag_b_2_plot_roster__id crop_roster_sale__id Sale_Modality__id ag_c_15
drop if missing(ag_c_15)
drop ag_b_2_plot_roster__id crop_roster_sale__id Sale_Modality__id
ren ag_c_15 hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
byso interview__id: egen women=total(hh_a_14==2)
drop hh_a_14
duplicates drop
replace women=1 if women>0
lab var women "Women involved in decisions of how revenue from crop sales will be used"
save tmp5, replace
**
*women in owneship of assets-livestock
use "$rawdata\livestockroster", clear
order interview__id
keep if livestockroster__id==1 /*cattle only*/
preserve
keep interview__id ag_d_6a__0 
ren ag_d_6a__0 hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
ren women2 women1
lab var women1 "Women owns cattle"
save tmp6, replace
restore
**
keep interview__id ag_d_6b__0 
ren ag_d_6b__0 hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
lab var women2 "Women responsible for taking care of cattle"
save tmp6, replace
**
keep interview__id ag_d_15__0
g hhroster__id=real(ag_d_15__0)
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer ag_d_15__0 hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
ren women2 women3
lab var women3 "Women responsible in decisions on whether to sell livestock"
save tmp7, replace
**
use tmp2, clear
mer 1:1 interview__id using tmp3
drop _mer
mer 1:1 interview__id using tmp4
drop _mer
mer 1:1 interview__id using tmp5
drop _mer
mer 1:1 interview__id using tmp6
drop _mer
mer 1:1 interview__id using tmp7
drop _mer
save "$data\women_empower2020", replace
**
*agri services and infrastructure
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
save "$data\hhd_services2020", replace
**
use "$rawdata\fertiliser", clear
order interview__id ag_b_2_plot_roster__id crop_roster_sale__id
g conv_input=1
replace conv_input=1 if ag_b_28c==1
replace conv_input=1000 if ag_b_28c==2
replace conv_input=20 if ag_b_28c==3&ag_b_28c_other=="20 litre bucket"
replace conv_input=25 if ag_b_28c==3&ag_b_28c_other=="bags(25kgs double D)"
replace conv_input=0.001 if ag_b_28c==3&ag_b_28c_other=="grams"
replace conv_input=0.2 if ag_b_28c==3&ag_b_28c_other=="litres foliar"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50kg bags" | ag_b_28c_other=="bags" ///
| ag_b_28c_other=="bags" | ag_b_28c_other=="bags" | ag_b_28c_other=="15 ×50kgs bags"
replace conv_input=500 if ag_b_28c==3&ag_b_28c_other=="Scotch carts" | ag_b_28c_other=="Scotch carts"
g fert=conv_input*ag_b_28b if ag_b_28b!=. & conv_input!=.
egen sum_fert=sum(fert), by(interview__id) missing
egen sum_fertcost=sum(ag_b_28d), by(interview__id) missing
keep interview__id sum_fert sum_fertcost
duplicates drop
lab var sum_fert "Fertiliser used in kgs"
lab var sum_fertcost "Cost of fertiliser in usd"
winsor2 sum_fert if sum_fert!=., replace cuts(10 90)
winsor2 sum_fertcost if sum_fertcost!=., replace cuts(10 90)
save "$data\fertileruse2020", replace
**
*INCOME VARIABLES
use "$rawdata\hh_regular", clear
order interview__id interview__key regular_employ__id
keep interview__id hh_e_3 hh_e_4a hh_e_4b__1-hh_e_4b__12 hh_e_4c
collapse (sum) hh_e_3 hh_e_4b__1-hh_e_4b__12 hh_e_4c, by(interview__id)
for var hh_e_4b__*: replace X = 1 if X > 0
reshape long hh_e_4b__, i(interview__id) j(j)
replace hh_e_4c = 0 if hh_e_4b__ == 0
drop hh_e_4b__
ren (j hh_e_3 hh_e_4c) (month totinc_regular monthlyinc_regular)
save "$data\regular_inc_long2020", replace
byso interview__id: egen months = total(monthlyinc_regular>0)
reshape wide monthlyinc_regular, i(interview__id) j(month)
order totinc_regular, after(interview__id)
save "$data\regular_pay2020", replace
**
use "$rawdata\hh_enterprises", clear
order interview__id interview__key
//need to find out how to analyse hh_e_17c__* hh_e_17b__*
keep interview__id hh_e_16 hh_e_17d hh_e_17c__*
/*collapse (sum) hh_e_16 hh_e_17d, by(interview__id)
save "$data\hh_enterprises", replace*/
**

duplicates tag interview__id , g(tagid)
preserve
keep if tagid >=1
save "$data\duplicates2020", replace
restore
drop if tagid >=1
drop tagid
reshape long hh_e_17c__, i(interview__id) j(j)
order hh_e_17c__, after(j)
*some hhlds reported receiving income in one month but not shown clearly in the data
g t_t=.
byso interview__id:egen tt=total( hh_e_17c__)
replace t_t=1 if hh_e_16!=hh_e_17d&tt==1
replace hh_e_17d = hh_e_16 if t_t == 1 
drop t_t tt
replace hh_e_17d = 0 if interview__id == "7660b27f6a35448ab6167ab749d64adb"
g balance = hh_e_16-hh_e_17d /*balance of income left after removing the highest income*/
g hh_e_17c = hh_e_17c__ if hh_e_17c__!=1
replace hh_e_17c = 0 if hh_e_17c == .
byso interview__id: egen tot_hh_e_17c=total(hh_e_17c) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_17c = rank(-hh_e_17c), by(interview__id)
replace rank_hh_e_17c = 0 if hh_e_17c == 0
replace rank_hh_e_17c = 1 + rank_hh_e_17c if rank_hh_e_17c>0
drop hh_e_17c
g month_inc_ent = (rank_hh_e_17c/tot_hh_e_17c)*balance
replace month_inc_ent = hh_e_17d if hh_e_17c__ == 1
keep interview__id j hh_e_16 month_inc_ent
ren (j hh_e_16) (month totinc_enter)
replace month_inc_ent=0 if month_inc_ent == .&totinc_enter != .a&totinc_enter != .
byso interview__id: egen months_ent = total(month_inc_ent>0)
save "$data\hh_ent_inc_long2020", replace
reshape wide month_inc_ent, i(interview__id) j(month)
order totinc_enter, after(interview__id)
save "$data\hh_ent_inc12020", replace
**
use "$data\duplicates2020", clear
drop tagid
egen id = group(interview__id hh_e_16)
drop if id == .
reshape long hh_e_17c__, i(id) j(j)
order interview__id
ren j month
order hh_e_17c__, after(month)
g t_t=.
byso interview__id id:egen tt=total( hh_e_17c__)
replace t_t=1 if hh_e_16!=hh_e_17d&tt==1
replace hh_e_17d = hh_e_16 if t_t == 1 
drop t_t tt
g balance = hh_e_16-hh_e_17d /*balance of income left after removing the highest income*/
g hh_e_17c = hh_e_17c__ if hh_e_17c__!=1
replace hh_e_17c = 0 if hh_e_17c == .
byso interview__id id: egen tot_hh_e_17c=total(hh_e_17c) /*total for months after removing months with high value ranked 1*/
egen rank_hh_e_17c = rank(-hh_e_17c), by(interview__id id)
replace rank_hh_e_17c = 0 if hh_e_17c == 0
replace rank_hh_e_17c = 1 + rank_hh_e_17c if rank_hh_e_17c>0
drop hh_e_17c
g month_inc_ent = (rank_hh_e_17c/tot_hh_e_17c)*balance
replace month_inc_ent = hh_e_17d if hh_e_17c__ == 1
keep interview__id month hh_e_16 month_inc_ent
ren hh_e_16 totinc_enter
replace month_inc_ent=0 if month_inc_ent == .&totinc_enter != .a&totinc_enter != .
collapse (sum) totinc_enter month_inc_ent, by(interview__id month)
byso interview__id: egen months_ent = total(month_inc_ent>0)
save "$data\hh_ent_inc1_long2020", replace
reshape wide month_inc_ent, i(interview__id) j(month)
order totinc_enter, after(interview__id)
save "$data\hh_ent_inc22020", replace
append using "$data\hh_ent_inc12020"
save "$data\hh_ent_income2020", replace
*long data
use "$data\hh_ent_inc_long2020", clear
append using "$data\hh_ent_inc1_long2020"
save "$data\hh_ent_income_long_fin2020", replace
**
*Timing of income from crop sales
use "$rawdata\crop_roster_sale", clear
order interview__id interview__key ag_b_2_plot_roster__id
keep interview__id ag_b_2_plot_roster__id crop_roster_sale__id ag_c_5 ag_c_6 ag_c_7__*
egen id = group(interview__id ag_b_2_plot_roster__id crop_roster_sale__id)
reshape long ag_c_7__, i(id) j(month)
drop ag_b_2_plot_roster__id crop_roster_sale__id
order interview__id
byso id: egen tot = total(ag_c_7__) /*to be used to clean ag_c_6*/
byso id:replace ag_c_6 = 100 if tot == 1
g tot_diff = tot-ag_c_7__
replace ag_c_6 = ag_c_6/100
g cropsale_month = (tot_diff/tot)*ag_c_5
replace cropsale_month = 0 if ag_c_7__ == 0
replace cropsale_month = ag_c_5 if tot == 1&ag_c_7__ == 1
drop ag_c_6 ag_c_7__ tot tot_diff
collapse (sum) ag_c_5 cropsale_month, by(interview__id month)
ren ag_c_5 tot_cropsales
save "$data\cropsales_month_long2020", replace
byso interview__id: egen months_cropsale = total(cropsale_month>0)
reshape wide cropsale_month, i(interview__id) j(month)
order tot_cropsales, after(interview__id)
save "$data\cropsales_month_wide2020", replace
**
*Income from livestock sales
use "$rawdata\livestockroster", clear
order interview__id interview__key
keep interview__id ag_d_14
collapse (sum) ag_d_14, by(interview__id)
ren ag_d_14 livestocksale
save "$data\livestocksale_inc2020", replace
**
*Livestock Produce
use "$rawdata\livestock_produce", clear
order interview__id interview__key
keep interview__id livestock_produce__id ag_d_19 ag_d_20a__1-ag_d_20c
//drop if interview__id == "00d88b6fe84d4e0abdc102154e065191"
egen id = group(interview__id livestock_produce__id)
reshape long ag_d_20a__ ag_d_20b__, i(id)
order interview__id livestock_produce__id
ren _j month
drop livestock_produce__id
byso id: egen tot = total(ag_d_20a__)
byso id: egen tot_ = total(ag_d_20b__)
g tot_diff = tot_ - ag_d_20b__
g balance = ag_d_19 - ag_d_20c if tot>1
g livprodsales_month = (tot_diff/tot_)*balance if ag_d_20b__>1
replace livprodsales_month = ag_d_20c if ag_d_20b__==1
replace livprodsales_month = ag_d_19 if tot == 1
replace livprodsales_month = 0 if livprodsales_month == . | ag_d_20a__ == 0
collapse (sum) ag_d_19 livprodsales_month, by(interview__id month)
save "$data\livestock_produce_long2020", replace
byso interview__id: egen months_livestock = total(livprodsales_month>0)
*
reshape wide livprodsales_month, i(interview__id) j(month)
order ag_d_19, after(interview__id)
save "$data\livestock_produce_wide2020", replace
**

**********************************************************************
*Merging all the datasets
use "$data\Household Panel_2020_fin.dta", clear
mer m:m interview__id using "$data\HCI commercialisation plot crop2020.dta"
drop _mer
order hhroster__id, before(individ_id)
mer m:m interview__id hhroster__id using "$data\hhd_demographics2020"
drop _mer
mer m:1 interview__id using "$data\AssetIndex_MPI.dta"
drop _mer
mer m:1 interview__id using "$data\crops grown2020.dta"
drop _mer
mer m:1 interview__id using "$data\crops sold2020.dta"
drop _mer
mer m:1 interview__id using "$data\Crops Area2020.dta"
drop _mer
mer m:1 interview__id using "$data\crop_output2020"
drop _mer
mer m:1 interview__id using "$data\input_use" 
drop _mer
mer m:1 interview__id using "$data\livestock"
drop _mer
mer m:1 interview__id using "$data\livestockcosts2020"
drop _mer
mer m:1 interview__id using "$data\women_empower2020"
drop _mer
mer m:1 interview__id using "$data\hhd_services2020"
drop _mer
mer m:1 interview__id using  "$data\fertileruse2020"
drop _mer
mer m:1 interview__id using "$data\add_inputs2020"
drop _mer
mer m:1 interview__id using "$data\other_inputs2020"
drop _mer
mer m:1 interview__id using "$data\live_produce2020"
drop _mer
mer m:1 interview__id using "$data\marketingcosts_fin2020"
drop _mer
mer m:1 interview__id using "$data\regular_pay2020"
drop _mer
mer m:1 interview__id using "$data\hh_ent_income2020"
drop _mer
mer m:1 interview__id using "$data\cropsales_month_wide2020"
drop _mer
mer m:1 interview__id using "$data\livestocksale_inc2020"
drop _mer
mer m:1 interview__id using  "$data\livestock_produce_wide2020"
drop _mer
replace hh_a_16 =1 if hhroster__id==1&interview__id=="24be4a23a0ff4d4a9fb3c69d46f25b0d"
replace hh_a_16 =1 if hhroster__id==1&interview__id=="68dbe4f723744d4aae74a159cc25fa06"
replace hh_a_16=1 if hhroster__id==1&interview__id=="761ba53fc0d34d11adedba0101ee2c85"
replace hh_a_16=1 if hhroster__id==1&interview__id=="81a2f8bbefe247098b7ad5eaf4f1600c"
keep if hh_a_16==1
duplicates drop interview__id, force
winsor2 sum_ag_c_5 if sum_ag_c_5!=., replace cuts(10 90) 
winsor2 sum_prod_value if sum_prod_value!=., replace cuts(10 90)
g year=2020
ren hh_a_06 HHID
order HHID year, before(hh_a_05b)
save "$data\household_finmerged2020", replace
********************************************************************************
*Appending round 1 and 2 datasets to create panel
use  "$data\household_finmerged2020", clear
drop interview__id hhroster__id individ_id interview__key
*resolve supervisor and enumerator names
for var hh_a_07 hh_a_08:decode X, g(_X)
order _hh_a_07 _hh_a_08, before(hh_a_09)
drop hh_a_07 hh_a_08
ren (_hh_a_07 _hh_a_08)(hh_a_07 hh_a_08)
append using "$data\household_finmerged2018", force
so HHID year
*some ids were given to two different households:creating new ids
replace HHID=1002 if HHID==1&hh_a_09=="enos mapuranga"
replace HHID=1003 if HHID==1&hh_a_09=="stobio chimwara"
replace HHID=1004 if HHID==112&hh_a_09=="solomon muzembe"
replace HHID=1005 if HHID==200&hh_a_09=="Rachel Chari"
replace HHID=1006 if HHID==288&hh_a_09=="Stephen Chipunza"
replace HHID=1007 if HHID==288&hh_a_09=="Zeria Mazarura"
replace HHID=1008 if HHID==305&hh_a_09=="shingirai kudzadombo"
replace HHID=1009 if HHID==369&hh_a_09=="solomon chiwashira"
replace HHID=1010 if HHID==378&hh_a_09=="nelson tembo"
replace HHID=1011 if HHID==510&hh_a_09=="robert mereki"
replace HHID=1012 if HHID==523&hh_a_09=="Anslem Makani"
replace HHID=1013 if HHID==561&hh_a_09=="conrad chisaira"
replace HHID=1014 if HHID==562&hh_a_09=="crispen zhakata"
replace HHID=1015 if HHID==563&hh_a_09=="charity mariseni"
replace HHID=1016 if HHID==564&hh_a_09=="joshphat chiwashira"
replace HHID=1017 if HHID==565&hh_a_09=="Alexio Chasakara"
replace HHID=1018 if HHID==566&hh_a_09=="kelvin muchenje"
replace HHID=1019 if HHID==567&hh_a_09=="Wonder Manyonga"570
replace HHID=1020 if HHID==568&hh_a_09=="Eneress Makombo"
replace HHID=1021 if HHID==569&hh_a_09=="Pearson Daundera"
replace HHID=1022 if HHID==570&hh_a_09=="Sarah Nyirongo"
replace HHID=1023 if HHID==571&hh_a_09=="nelson chikuni"
replace HHID=1024 if HHID==572&hh_a_09=="shine chikuni"
replace HHID=1025 if HHID==573&hh_a_09=="Lovemore Nyamurowa"
replace HHID=1026 if HHID==574&hh_a_09=="Beauty Muringani"
replace HHID=1027 if HHID==575&hh_a_09=="Steward Gomo"
replace HHID=1028 if HHID==576&hh_a_09=="stella mupara"
replace HHID=1029 if HHID==577&hh_a_09=="luke paneya"
replace HHID=1030 if HHID==578&hh_a_09=="Edina Nyabotso"
replace HHID=1031 if HHID==579&hh_a_09=="Solomon Nzvimbo"
replace HHID=1032 if HHID==598&hh_a_09=="Charles Soza"
replace HHID=1033 if HHID==.a&hh_a_09=="knowledge dandawa"
replace HHID=1034 if HHID==.a&hh_a_09=="charles mhako"
replace HHID=1035 if HHID==.a&hh_a_09=="akim makwanda"
duplicates tag HHID, g(panel) /*creating panel dummy*/
order panel
replace panel=2 if panel==0&year==2020
lab def panel 0 "2018 only" 1 "2018 and 2020" 2 "2020 only"
lab val panel panel
**
*sorting variables
tab hh_a_14, g(gender)
ren (gender1 gender2) (male female)
inspect hh_a_15  /*age */
sum hh_a_15, d
ren hh_a_15 age
winsor2 age if age!=., replace cuts(1 99) 
tab hh_a_18, mi  /*marital status */
tab hh_a_18, g(married)
inspect hh_a_19 /*years of schooling*/
sum hh_a_19, d
winsor2 hh_a_19 if hh_a_19!=., replace cuts(5 95)
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
tab hh_a_25a, g(headman)
tab hh_a_26a, g(headman_spouse)
tab hh_a_27a, g(chief)
tab hh_a_28a, g(mobile)
winsor2 hh_a_28d if hh_a_28d!=., replace cuts(15 85)
tab hh_a_28e, g(mobile_inf)
tab hh_a_31,g(covid)
tab hh_a_32,g(foodsale_covid)
tab hh_a_33, g(foodstck_covid)
tab hh_a_34, g(foodcost_covid)
tab hh_a_35a, g(col_covid)
tab hh_a_36a, g(farmeff_covid)
tab hh_a_37a, g(workeff_covid)
tab hh_a_38a, g(saleeff_covid)
tab hh_z_1a, g(contrfarm)
tab hh_z_1b, g(extension)
winsor2 hh_z_2 if hh_z_2!=., replace cuts(10 90) /*contract years*/
tab hh_z_6a, g(mkt_info)
winsor2 hh_z_5b if hh_z_5b!=., replace cuts(10 90) /*extension frequency*/
tab hh_z_7a, g(credit)
tab hh_z_7b,g(obtain_loan)
tab hh_e_14, g(hhenter)
tab hh_e_32, g(subj_sta) /*sublective status*/
tab hh_e_33,g(circum) /*circumstances*/
tab hh_e_34,g(income_statu)  /*income status*/
tab hh_e_35,g(wellbeing)
tab hh_e_36, g(ladder_st)
tab hh_f_1a_male, g(malediet)
tab hh_f_1a_female, g(female_diet)
for var hh_f_1b_male__*: tab X, mi
egen HDDS =  rowtotal(hh_f_1b_male__1-hh_f_1b_male__20)
sum HDDS, d
lab var HDDS "Household dietary diversity"
for var hh_f_1b_female__*: tab X, mi
egen HDDS_f = rowtotal(hh_f_1b_female__1-hh_f_1b_female__20)
sum HDDS_f, d
lab var HDDS_f "Female household dietary diversity score"
for var hh_f_2__*: tab X, mi
egen hunger_index = rowtotal(hh_f_2__1-hh_f_2__9)
sum hunger_index, d
tab hh_f_7a, g(dailytasks)
tab hh_f_8a, g(hhdtasks)
tab hh_f_9, g(cookingtime)
tab hh_f_10, g(childdeath)
tab hh_f_11, g(salary_dec)
tab hh_f_12, g(exp_dec)
**
lab var sum_ag_c_16 "How much household spend on grading"
lab var sum_ag_c_17 "How much household spend on curing/milling"
lab var sum_ag_c_18 "How much household spend on storing 
lab var sum_ag_b_27b "Costof buying seed"
lab var sum_ag_b_29d "Total cos of tillage"
lab var HCI "Household commercialisation index"
lab var output1 "Maize production in kgs"
lab var output2 "Tobacco production in kgs"
lab var output3 "Groundnut production in kgs"
lab var output4 "Wheat production in kgs"
lab var output6 "Cowpeas production in kgs"
lab var output7 "Commonn beans production in kgs"
lab var output8 "Soya beans production in kgs"
lab var output9 "Sorghum production in kgs"
lab var output11 "Irish production in kgs"
lab var output12 "Sweet potato production in kgs"
lab var output13 "Onions production in kgs" 
lab var output15 "Tomato production in kgs"
lab var output17 "Butternut production in kgs"
lab var output18 "Vegetable production in kgs" 
lab var output10 "Rice production in kgs"
lab var output16 "Cabbage production in kgs"
lab var hunger_index "Hunger Index"
drop hh_a_38c-AG_module_endtime hh_z_1a hh_z_1b hh_z_6a hh_z_6b__6 hh_z_7a hh_z_7b hh_z_7d__6 ///
hh_z_7e__5 hh_z_7f income_module_start_date income_module_start_time hh_e_1b hh_e_1a__6 ///
tagid income_module_respondent hh_e_14 hh_e_15__0-hh_e_15__19 hh_e_19b1__0-hh_e_19b1__14 ///
hh_e_19b2__0-hh_e_19b2__14 hh_e_19b3__0-hh_e_19b3__14 hh_e_19a_others__0-hh_e_19a_others__2 ///
hh_e_24mobile__0-hh_e_24mobile__14 hh_e_25a-hh_e_31b hh_e_32 hh_e_33 hh_e_34 hh_e_35 hh_e_36 ///
income_module_end_date-FS_respondent_male FS_Male_availability hh_f_1a_male ///
FS_respondent_female FS_Female_availability hh_f_1a_female carework_id__0-carework_id__14 ///
hh_f_7a hh_f_7b hh_f_8a hh_f_8a hh_f_9 hh_f_10 hh_f_11 hh_f_11 FS_module_enddate FS_module_endtime ///
inc_adult_fem female_inc_avail hh_f_13b AF_module_enddate-assignment__id ///
migrant status hh_a_14 hh_a_15_months hh_a_16 hh_a_17 hh_a_18 hh_a_20 hh_a_21 ///
hh_a_21_other hh_a_22 hh_a_22_other hh_a_23 migrantroster__id-cr conv_harv ///
conv_sale regprice_crop x hh_a_131-hh_f_6d16 cultivated_year ssSys_IRnd hh_a_13__0-hh_a_13a__4 ///
refusal hh_a_02a interview_start_date interview_start_time hh_a_28b__0-hh_a_28b__14 hh_a_28e hh_a_26a
save "$data\hhd_final_panel_merged", replace
*****

exit




















































































