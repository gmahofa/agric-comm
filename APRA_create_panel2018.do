clear all
set more off, perm
global root  "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global rawdata "$root\rawdata\APRA_ZIM_2018_3_STATA_ALL"
global tmp "C:\Users\Mahofa"
global code "$root\code"
global output "$root\output"
global data "$root\data"

use "$rawdata\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1", clear
************************************************************
*1. Check if all surveys had consent. If not drop them. 
sum hh_a_02 if hh_a_02==2
*all have consent
************************************************************

*CLEANING THE WARDS
*Fix hh_a_04b ward numbers
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
tab hh_a_05b
tab hh_a_05b, nol
label define hh_a_05b 18 "Forrester J" 19 "Forrester K", add
*Populating the Forrester J and K wards (based on the comments section on variable hh_a_05b, attached excel file and also from extension officer)
replace hh_a_05b=18 if interview__id=="661fe814ce334b929c2d57ad2bbc03c8"| interview__id=="06bbb9041529440490f2efb7c21756cf"| interview__id=="0e9a7866a9734f4f962a0da2879e52a1"| ///
interview__id=="1a61034dab974043bf269bfee94c2795"| interview__id=="2831b889b7394b08a55a51e20e1bcb29"| interview__id=="37bd818aca5540348e9e1d1816fa0dad"| ///
interview__id=="3fb6d773092745d58a9d135be9463643" | interview__id=="5984553e92c24393b2cd878625c331cd"| ///
interview__id=="5ec02edb08b74cb3b8583c08e1f93e09"| interview__id=="5f815475b40a4f62bb1b4f5cfcb02592"| interview__id=="753c3132387f424ca9075dcb932ddb98"| ///
interview__id=="a98c09e2be4c4de3bde78a6ace7836d5"| interview__id=="b7a68202aa1644568d1f8bc268cb4029"| interview__id=="bedb890d168f4b2694da814e8af2f79b"| ///
interview__id=="c228dacfd937423789130bc211fe3b2f"| interview__id=="e30c14e5154a44b190c48a904b17d24d"| interview__id=="ebf2829dab75448a93428ef98a34932f"| ///
interview__id=="f14073b61e744f19b2e6f4d61eb9ced5"| interview__id=="fd941fcfb01e4139ba82ab433af7768a"| interview__id=="fed34b49086a4dc98b451001940de159"
replace hh_a_05b=19 if interview__id=="03b626217f0d41ed9a17fe279beb31a6"| interview__id=="12ae03d9982d425b8d42c5ae2616bb43"| interview__id=="1a8c3716d5174be5a6a47ef2fff9d264" ///
| interview__id=="25c12f5ede8d4428beb9e78f18d4098f"| interview__id=="2b584020cf074f9faecf3b90e9ba5946"| interview__id=="341ec3884a904dd982288bd062256723"| interview__id=="3707bb5bf51a4c7a9a996f7e26816842" ///
| interview__id=="39377848d8c84a8f9a68b44094654c07"| interview__id=="3fb0e8bc84bc4af5a1e58a03a4a73d48"| interview__id=="46989c3bdd9e43d8b8c4758023b96013"| interview__id=="4b1aee91818649e1b9405235cf5b2071" ///
| interview__id=="568eddf9eb3d460ba43b6d902da852b9"| interview__id=="60623fdc034447bb8173ae40e35e515d"| interview__id=="6828012507e94a2596c2c94b7b1728f7"| interview__id=="69c03caf88fc469cafc89f214df5d3dd" ///
| interview__id=="6fdbf179199f46d3890206a6b00363dc"| interview__id=="7344e04e0e8245d9adbdd7a3fc29139c"| interview__id=="81d8589cec9047feade9988c0fb13074"| interview__id=="92856c3b05e943cd853c9e3fafe21ace" ///
| interview__id=="92899426d29d4e09995e1266919932c2"| interview__id=="97170dd2d90c4bccb40d86fd689e051c"| interview__id=="a2eb39624707486c83b768c8c0c49bd8"| interview__id=="a7e4fbfe4e22408f992172232b2a7217" ///
| interview__id=="b0d1bae022cb4c52b25ad9516d09a109"| interview__id=="cb214b23603044d1bbcdd132d5afda7b"| interview__id=="cd9158190a144e8d8e8753eda82f8c7b"| interview__id=="cdac3f8a613f4cfab842f31a1245b4fb" ///
| interview__id=="da8879d006364548a2fe8c7fe365cef7"| interview__id=="dedf9a4632bf4b0c9bc9a1c0408bc470"| interview__id=="e9ebcbf476914d04881a83e9fdb8ee8b"| interview__id=="f29dc6f1dc5442ae8c9eb4a4b6863481" ///
| interview__id=="f5269ae6fada4599873171fb07cc6dae"| interview__id=="fb93c2b64cb94a6d837237e217f01d26"
replace hh_a_05b=18 if hh_a_05b==6
*Fix 2 remaining ward numbers
replace hh_a_04b = 27 if hh_a_04b==3
replace hh_a_04b = 27 if hh_a_04b==2
*Fix Area
replace hh_a04b1 = 1 if  hh_a_05b==11| hh_a_05b==10| hh_a_05b==8| hh_a_05b==9| hh_a_05b==7| hh_a_05b==6| hh_a_05b==5| hh_a_05b==18| hh_a_05b==3| hh_a_05b==4| hh_a_05b==19
replace hh_a04b1 = 2 if  hh_a_05b==16| hh_a_05b==17| hh_a_05b==15|  hh_a_05b==14 | hh_a_05b==1| hh_a_05b==2|  hh_a_05b==13
format hh_a_04b %9.0fc
replace hh_a_04b=27 if hh_a_04b==6
drop if interview__status=="RejectedByHeadquarters"
drop if interview__status=="RejectedBySupervisor"
save "$data\master2018", replace

****************************************************************************
**************II. MERGE WITH HOUSEHOLD MEMBERS & MIGRANTS*******************
****************************************************************************
use "$data\master2018", clear
foreach var in hh_a_13__0 hh_a_13__1 hh_a_13__2 hh_a_13__3 hh_a_13__4 hh_a_13__5 ///
hh_a_13__6 hh_a_13__7 hh_a_13__8 hh_a_13__9 hh_a_13__10 hh_a_13__11 hh_a_13__12 ///
hh_a_13__13 hh_a_13__14{
replace `var'="" if `var'=="##N/A##"
}

*Migrants (hh_a_13_15 onwards)
rename hh_a_13a__0 hh_a_13__15
rename hh_a_13a__1 hh_a_13__16
rename hh_a_13a__2 hh_a_13__17
rename hh_a_13a__3 hh_a_13__18
rename hh_a_13a__4 hh_a_13__19
reshape long hh_a_13__, i(interview__id) j(id)
gen migrant=1 if id>14
replace migrant=0 if id<15
rename hh_a_13__ hh_a_13
drop if hh_a_13=="##N/A##"
drop if hh_a_13==""
replace id= id+1
rename id individ_id
*Check for duplicates in names
/*
duplicates tag interview__id hh_a_13, g(x)
br if x
br interview__id hh_a_13 individ_id if x
*/
*Do necessary replacements
replace hh_a_13="Christopher Panganai II" if hh_a_13=="Christopher Panganai" & individ_id==5
*Create new dataset
save "$data\Household Panel.dta", replace
*Use hhroster and do necessary replacements (As above)
use "$rawdata\hhroster.dta", clear
replace hh_a_13="Christopher Panganai II" if hh_a_13=="Christopher Panganai" & hhroster__id==5
drop if hh_a_13==""
save "$data\hhroster_modif.dta", replace
*merge with ALL members
use "$data\Household Panel.dta", replace
merge 1:1 interview__id hh_a_13 using "$data\hhroster_modif.dta"
drop _merge
save "$data\Household Panel_1.dta", replace
*Use migrant roster
use "$rawdata\migrantroster.dta", clear
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
drop if hh_a_13==""
save "$data\migrantroster_modif.dta", replace

*Merge with Household panel
use "$data\Household Panel_1.dta", replace
merge 1:1 interview__id hh_a_13 using "$data\migrantroster_modif.dta"
drop if _merge==2
drop _merge
//foreach var in hh_a_07 hh_a_08 hh_a_09{
//replace `var'=proper(`var')
//}
*drop x
drop if interview__id=="21eaa3d0c74943fcb2a2b7ab8e5eb4b1" |interview__id=="5ec02edb08b74cb3b8583c08e1f93e09" ///
|interview__id== "5f5aecd6c973448294a866906a3e89c2"|interview__id== "820ef58c97c5442cb2a7f7ff3f4a27e2" ///
|interview__id== "a34da15cadea435885ce0037035d45eb" |interview__id=="03205d2a6c31419f8abd2a8b28686470" ///
|interview__id== "099d62f347c64c3db98b920d31944690"|interview__id== "0e3762f3aa0f4ffbbb02a48beef2e3ab" ///
|interview__id== "0e9a7866a9734f4f962a0da2879e52a1"|interview__id== "1a61034dab974043bf269bfee94c2795" ///
|interview__id== "1c3828aa50704c439460e882214b3aed"|interview__id== "1f10d8af9ab845609775404ece32a2bb" ///
|interview__id== "265469fbfca34fde9ef3ee0a48bae3de"|interview__id== "27720dbe282d407991445d9b210ee681" ///
|interview__id== "389f1f1001da4e838538dc6b92c77bf5"|interview__id== "4c9a6418ab8c4860baa2dc73d7e3335a" ///
|interview__id== "5713137a58734a948d7967d7befedb4b"|interview__id== "5930316c79894f3d99ceb1e7c8d09852" ///
|interview__id== "69187c418be440249e86cc8d3f90e4c0"|interview__id== "6a7fb16fc32c4246896fc6833293c2bf" ///
|interview__id== "84bb9ac743664073b4ff59686ef75e96"|interview__id== "86138e70e9f54894aa8f3fdc8d729808" ///
|interview__id== "8e738697caca4defbf305161ae909f15"|interview__id== "a050158a3a25470484ad1471beab929d" ///
|interview__id== "b670a954e1a848ff897c2f1395061f33"|interview__id== "bbe63fabbd454d49a9ec538f8b50d2a4" ///
|interview__id== "fd941fcfb01e4139ba82ab433af7768a"
save "$data\Household Panel_fin.dta", replace

****************************************************************************
*****************************III. AGRICULTURE*******************************
****************************************************************************
*merging with plots & crops
*Was plot cultivated this year?
*Any missing ovserations dropped
//cd "$data"
use "$rawdata\ag_b_2_plot_roster.dta", clear
*br if ag_b_12==-999999999
*drop if cultivated_year==-999999999
merge 1:m interview__id ag_b_2_plot_roster__id using "$rawdata\crop_roster_sale.dta"
*there are plots where other crops are grow, so 87 left in master
drop if _merge==2
drop _merge
*minimum other crops * dont analyse other crops in zim
merge m:m interview__id ag_b_2_plot_roster__id using "$rawdata\crop_roster_sale_other.dta"
drop _merge
drop if interview__id=="21eaa3d0c74943fcb2a2b7ab8e5eb4b1" |interview__id=="5ec02edb08b74cb3b8583c08e1f93e09" ///
|interview__id== "5f5aecd6c973448294a866906a3e89c2"|interview__id== "820ef58c97c5442cb2a7f7ff3f4a27e2" ///
|interview__id== "a34da15cadea435885ce0037035d45eb" |interview__id=="03205d2a6c31419f8abd2a8b28686470" ///
|interview__id== "099d62f347c64c3db98b920d31944690"|interview__id== "0e3762f3aa0f4ffbbb02a48beef2e3ab" ///
|interview__id== "0e9a7866a9734f4f962a0da2879e52a1"|interview__id== "1a61034dab974043bf269bfee94c2795" ///
|interview__id== "1c3828aa50704c439460e882214b3aed"|interview__id== "1f10d8af9ab845609775404ece32a2bb" ///
|interview__id== "265469fbfca34fde9ef3ee0a48bae3de"|interview__id== "27720dbe282d407991445d9b210ee681" ///
|interview__id== "389f1f1001da4e838538dc6b92c77bf5"|interview__id== "4c9a6418ab8c4860baa2dc73d7e3335a" ///
|interview__id== "5713137a58734a948d7967d7befedb4b"|interview__id== "5930316c79894f3d99ceb1e7c8d09852" ///
|interview__id== "69187c418be440249e86cc8d3f90e4c0"|interview__id== "6a7fb16fc32c4246896fc6833293c2bf" ///
|interview__id== "84bb9ac743664073b4ff59686ef75e96"|interview__id== "86138e70e9f54894aa8f3fdc8d729808" ///
|interview__id== "8e738697caca4defbf305161ae909f15"|interview__id== "a050158a3a25470484ad1471beab929d" ///
|interview__id== "b670a954e1a848ff897c2f1395061f33"|interview__id== "bbe63fabbd454d49a9ec538f8b50d2a4" ///
|interview__id== "fd941fcfb01e4139ba82ab433af7768a"
*Drop if no crops reported
*if no crop harvest
*drop if ag_c_1a==.
*renumber plots
*replace ag_b_plot_roster__id=ag_b_plot_roster__id+1
*Keep all plots cultivated this year
drop if ag_b_12==2
save "$data\plots_current year.dta", replace
*Sellers & NoN-Selling HHs
*ag_c_2 gen dummy identifying HHs that sell and that dont
 
*******************************************
*******************Crops*******************
*******************************************
*******create dummy variables for crops****
forv i=1/18{
foreach var in  ag_b_17__`i'{
gen `var'_dummy=1 if `var'>0
replace `var'_dummy=0 if `var'==0
order `var'_dummy, after(`var')
copydesc `var' `var'_dummy
}
}  

gen ag_b_17__21_dummy=1 if ag_b_17__21>0
replace ag_b_17__21=0 if ag_b_17__21==0

forv i=1/18{
foreach var in ag_b_17__`i'_dummy {
replace `var'=0 if crop_roster_sale__id!=`i'
}
}

replace ag_b_17__21_dummy=0 if crop_roster_sale__id!=21
save "$data\plots_current year.dta", replace

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
/*cd "$data"
use "plots_current year.dta", clear*/
replace ag_c_5=. if ag_c_5<0
replace ag_c_2=. if ag_c_2<0
save "$data\plots_current year.dta", replace
*crop+other crop
replace ag_c_5=0 if ag_c_2==2
*
replace ag_c_5other=. if ag_c_5other<0
replace ag_c_1a=. if ag_c_1a<-1
replace ag_c_1a=. if ag_c_1a==.a
replace ag_c_1b=. if ag_c_1b==.a
replace ag_c_4a=. if ag_c_4a==.a
replace ag_c_4b=. if ag_c_4b==.a
*
*Fix outliers 
*Maize
replace ag_c_1b=2 if ag_c_1b==1 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="2b584020cf074f9faecf3b90e9ba5946" ///
| ag_c_1b==1  & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==1 & interview__id=="333f9824eebf4490a9f33453bc38c3f9"
replace ag_c_4a=2.5 if ag_c_4a==25 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="3707bb5bf51a4c7a9a996f7e26816842"
replace ag_c_4a=3.5 if ag_c_4a==3500 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="86210cd5b3c94476aea494a56cb35ad7"
replace ag_c_4a=1.5 if ag_c_4a==1500 &  ag_b_2_plot_roster__id==2 & crop_roster_sale__id==1 & interview__id=="94541bb18f69441ba55b56f563e51a51"
replace ag_c_4b=3 if ag_c_4b==14 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==1 & interview__id=="94541bb18f69441ba55b56f563e51a51"
replace ag_c_4a=1.5 if ag_c_4a==1500 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==1 & interview__id=="c945c86effc84e0cbeeb5c463775e01f"
replace ag_c_4a=1.5 if ag_c_4a==15 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="d54c82a9fefa4e5092c8b2e2ea3caaca"
replace ag_c_4b=3 if ag_c_4b==2 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="dddcabe7c7d74b9ab7adc54db7e0fb4e"
replace ag_c_4b=3 if ag_c_4b==2 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="e41ac7d7ec37464fb073f5bc25065987"
replace ag_c_4a=1.5 if ag_c_4a==1500 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="e41ac7d7ec37464fb073f5bc25065987"
replace ag_c_5=590 if ag_c_5==585000 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==1 & interview__id=="e41ac7d7ec37464fb073f5bc25065987"
replace ag_c_4b=3 if ag_c_4b==2 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==1 & interview__id=="49da425663b24a2ab50ed204d3c00ab3"



*Tobacco
replace ag_c_4b=14 if ag_c_4b==3 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==2 & interview__id=="43738a95fdc34822838583f3ee88d4ea"
replace ag_c_5=1200 if ag_c_5==12000 &  ag_b_2_plot_roster__id==2 & crop_roster_sale__id==2 & interview__id=="43738a95fdc34822838583f3ee88d4ea"
replace ag_c_4b=14 if ag_c_4b==3 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==2 & interview__id=="568eddf9eb3d460ba43b6d902da852b9"
replace ag_c_4b=14 if ag_c_4b==3 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==2 & interview__id=="7f17461526b74b5797d39206a73378dc"
replace ag_c_1b=5 if ag_c_1b==1 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==2 & interview__id=="84f2f500681043d9832ba7eb82be444f"
replace ag_c_4b=14 if ag_c_4b==3 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==2 & interview__id=="94c4d3a62d9c4424b58b13f5784b11c0"
replace ag_c_4b=2 if ag_c_4b==5 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==2 & interview__id=="cdac3f8a613f4cfab842f31a1245b4fb"
replace ag_c_1b=5 if ag_c_1b==1 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==2 & interview__id=="d50e690e776944339e3c2673686445f2"
replace ag_c_4b=14 if ag_c_4b==13 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==2 & interview__id=="3289dc336fff4cb79bd028ee8989732a"
replace ag_c_4b=2 if ag_c_4b==1 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==2 & interview__id=="49da425663b24a2ab50ed204d3c00ab3"
replace ag_c_4b=14 if ag_c_4b==13 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==2 & interview__id=="6a18cc6ab9bb43bfaa8226e00c0f852c"
replace ag_c_4a=1000 if ag_c_4a==10 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==3 & interview__id=="6e9c35d92a884f0ea74c8b7f95ed3234"
replace ag_c_4b=14 if ag_c_4b==1 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==2 & interview__id=="abca391b556d493e8facf1ccd2ac8a34"
replace ag_c_1b=1 if ag_c_1b==2 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==2 & interview__id=="6301ba7595844a86847e125a974533fc"
replace ag_c_1a=1.1 if ag_c_1a==1150.00 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==7 & interview__id=="9c4e60f9e62447a4bbfeee48dfe3a109"


*crop 7 & 8
replace ag_c_4a=1.5 if ag_c_4a==1500 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==8 & interview__id=="4d41de32230942709b3894364086a315"
replace ag_c_4a=5.5 if ag_c_4a==5500 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==8 & interview__id=="82b26412d98f4780b58e9bf14dfaf594"
replace ag_c_1b=2 if ag_c_1b==1 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==7 & interview__id=="8e738697caca4defbf305161ae909f15"
replace ag_c_4a=1.5 if ag_c_4a==15 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==8 & interview__id=="98d771d409df44958c7d6284306d5ec6"
replace ag_c_4a=2.5 if ag_c_4a==25 & ag_b_2_plot_roster__id==1 & crop_roster_sale__id==8 & interview__id=="e40238e0e38e469bae1b9a83ea197c2a"
replace ag_c_4b=2 if ag_c_4b==1 & ag_b_2_plot_roster__id==4 & crop_roster_sale__id==7 & interview__id=="823c1b2dc4bb42c9a558f3bb3f574cfe"
replace ag_c_1b=1 if ag_c_1b==2 & ag_b_2_plot_roster__id==2 & crop_roster_sale__id==8 & interview__id=="e8df4c79c98b431c94821d781b9338a5"

*16 crop
replace ag_c_4a=250 if ag_c_4a==300 & ag_b_2_plot_roster__id==3 & crop_roster_sale__id==16 & interview__id=="0e9a7866a9734f4f962a0da2879e52a1"
replace ag_c_4a=80 if ag_c_4a==800 & ag_b_2_plot_roster__id==4 & crop_roster_sale__id==12 & interview__id=="b9759d50da1c473ab2482e6b8cc74e4f"

*sum by HH
egen sum_ag_c_1a=sum(ag_c_1a), by(interview__id) missing /*production*/
egen sum_ag_c_5=sum(ag_c_5), by(interview__id) missing /*sales value*/

*added 30 Nov Amrita
*costs
replace ag_c_16=. if ag_c_16<0
replace ag_c_17=. if ag_c_17<0
replace ag_c_18=. if ag_c_18<0
replace ag_b_27b=. if ag_b_27b<0
replace ag_b_29d=. if ag_b_29d<0
replace ag_c_16other=. if ag_c_16other<0
replace ag_c_17other=. if ag_c_17other<0
replace ag_c_18other=. if ag_c_18other<0
egen sum_ag_c_16=sum(ag_c_16), by(interview__id) missing
egen sum_ag_c_17=sum(ag_c_17), by(interview__id) missing
egen sum_ag_c_18=sum(ag_c_18), by(interview__id) missing
egen sum_ag_b_27b=sum(ag_b_27b), by(interview__id) missing
egen sum_ag_b_29d=sum(ag_b_29d), by(interview__id) missing
egen sum_ag_c_16other=sum(ag_c_16other) , by(interview__id) missing
egen sum_ag_c_17other=sum(ag_c_17other), by(interview__id) missing
egen sum_ag_c_18other=sum(ag_c_18other), by(interview__id) missing

***************************************************************
*bunch conversion unclear
*IMPUTE price to VALUE HARVEST
*price imputed SALES HARVESTS QUANT
*ag_c_4b crop sale quant unit ag_c_4b_other other units
replace ag_c_4b=. if ag_c_4b<-1
*conversion factors for harvest where prodn sold to calcualte HCI 
*check units
*tab ag_c_1b_other if ag_b_17__1_dummy==1 | ag_b_17__2_dummy==1
*Harvest
*Kg PRODUCTION QUANTITIES (if sold!!!!)
gen conv_harv=1 if ag_c_1b==1
*Tons
replace conv_harv=1000 if ag_c_1b==2
***Bales (all bales for tobacco)
*Tobacco
replace conv_harv=80 if ag_c_1b==5 & crop_roster_sale__id==2
**Bundles
*sorghum (1) reported incorrectly
*this should be "20 litre tin==20 Kg"
*add label/coding
replace conv_harv=20 if ag_c_1b==4 & crop_roster_sale__id==9
*Onion
replace conv_harv=1 if ag_c_1b==4 & crop_roster_sale__id==13
replace conv_harv=0.01 if ag_c_1b==3 & crop_roster_sale__id==13 & ag_c_1b_other=="bulbs of king onions"
*Vegetable
replace conv_harv=1 if ag_c_1b==4 & crop_roster_sale__id==18
*Others
*50kg bag
replace conv_harv=50 if ag_c_1b==3 & ag_c_1b_other=="50 kg bags" | ag_c_1b==3 & ag_c_1b_other=="50 kg bag" ///
| ag_c_1b==3 & ag_c_1b_other=="50 kgs bag" | ag_c_1b==3 & ag_c_1b_other=="50 kgs bags" | ag_c_1b==3 & ag_c_1b_other=="50kg bags" ///
| ag_c_1b==3 & ag_c_1b_other=="50 kg bags unshelled" | ag_c_1b==3 & ag_c_1b_other=="50kg bags unshelled" ///
| ag_c_1b==3 & ag_c_1b_other=="bags of 50 kg unshelled nuts" | ag_c_1b==3 & ag_c_1b_other=="bags unshelled groundnuts" ///
| ag_c_1b==3 & ag_c_1b_other=="50 kgs unshelled"| ag_c_1b==3 & ag_c_1b_other== "50 bags not shelled" ///
| ag_c_1b==3 & ag_c_1b_other=="50 kg bags of unshelled groundnut" | ag_c_1b==3 & ag_c_1b_other=="50 kg of unshelled" ///
| ag_c_1b==3 & ag_c_1b_other=="50 kg bags,unshelled"| ag_c_1b==3 & ag_c_1b_other== "50 kg of unshelled grains" ///
|ag_c_1b==3 & ag_c_1b_other== "50 kg unshelled nuts" | ag_c_1b==3 & ag_c_1b_other=="50 bags of unshelled groundnuts" ///
|ag_c_1b==3 & ag_c_1b_other== "50 kg bags of unshelled nuts" | ag_c_1b==3 & ag_c_1b_other== "50 kg bags of shelled cowpeas" ///
| ag_c_1b==3 & ag_c_1b_other== "50 kg bags unshelled groundnuts"
*15 kg bags/pockets of ??
replace conv_harv=15 if ag_c_1b_other=="15 kg bags"| ag_c_1b_other== "15 kg pockets" | ag_c_1b_other=="15kg pockets"
*20 litre buckets
replace conv_harv=20 if ag_c_1b_other=="20 liter buckets"| ag_c_1b_other== "20 litre bucket" ///
| ag_c_1b_other=="20 litre buckets"| ag_c_1b_other=="20 litre buckets or tins" ///
| ag_c_1b_other=="20 litre tins"| ag_c_1b_other== "20 ltr buckets" ///
| ag_c_1b_other== "20 ltr tins"| ag_c_1b_other==   "20litre buckets"| ag_c_1b_other== "20ltr buckets" 
*1 Scoth cart is approx 800 L (each litre approx 0.32 kg) , so 256 kg
replace conv_harv=500 if ag_c_1b==3 & ag_c_1b_other=="Scotch carts"
*head of cabbage
replace conv_harv=0.5 if ag_c_1b==3 & ag_c_1b_other=="heads" & crop_roster_sale__id==16
*butternut
replace conv_harv=0.5 if ag_c_1b==3 & ag_c_1b_other=="heads" & crop_roster_sale__id==17
*90kg bags
replace conv_harv=90 if ag_c_1b==3 & ag_c_1b_other=="90 kg bags"
*bunch
replace conv_harv=1 if ag_c_1b==3 & ag_c_1b_other=="bunches" & crop_roster_sale__id==13
*bags of beans
replace conv_harv=50 if ag_c_1b==3 & ag_c_1b_other=="bags" & crop_roster_sale__id==7
replace conv_harv=50 if ag_c_1b==3 & ag_c_1b_other=="Bags unshelled beans." & crop_roster_sale__id==7
*maize cart & cob
replace conv_harv=500 if ag_c_1b==3 & ag_c_1b_other=="carts"
replace conv_harv=0.2 if ag_c_1b==3 & ag_c_1b_other=="cobs"
replace conv_harv=1 if ag_c_1b==3 & ag_c_1b_other=="litre tin"
*tomato
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
& interview__id=="7dfd4a8ec8594fd892e70e1f330c2461"

*use harvest quant units conversion to give prod quant
replace ag_c_1a=. if ag_c_1a<0
replace ag_c_1aother=. if ag_c_1aother<0

*NEED TO DIVIDE SALES QUANTITY WITH SALES value to impute prices
*prices below to value harevst
replace ag_c_4b=. if ag_c_4b<0
replace ag_c_4bother=. if ag_c_4bother<-1
gen conv_sale=1 if ag_c_4b==2
replace conv_sale=0.001 if ag_c_4b==1
replace conv_sale=1000 if ag_c_4b==3

*1 litre
replace conv_sale=1 if ag_c_4b==4
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
replace conv_sale=15 if ag_c_4b_other=="15 kg bags"| ag_c_4b_other== "15 kg pockets" | ag_c_4b_other=="15kg pockets"
*
replace conv_sale=15 if ag_c_4b_other=="15 kg bags"| ag_c_4b_other== "15 kg pockets" | ag_c_4b_other=="15kg pockets"
*
replace conv_sale=50 if ag_c_4b==15 & ag_c_4b_other=="50kg bags unshelled" 
*
replace conv_sale=7 if ag_c_4b==15 & ag_c_4b_other=="65 x 30 crates" 
*boxes
replace conv_sale=7 if ag_c_4b==15 & ag_c_4b_other=="boxes" & crop_roster_sale__id==15
*bulbs
replace conv_sale=0.01 if ag_c_4b==15 & crop_roster_sale__id==13 & ag_c_4b_other=="bulbs"
*cart
replace conv_sale=500 if ag_c_4b==15 & ag_c_4b_other=="carts"
*cobs
replace conv_sale=0.2 if ag_c_4b==15 & ag_c_4b_other=="cobs"
*
replace conv_sale=7 if ag_c_4b==15 & ag_c_4b_other=="crates" & crop_roster_sale__id==15 
*
replace conv_sale=0.5 if ag_c_4b==15 & ag_c_4b_other=="heads" & crop_roster_sale__id==16
*
replace conv_sale=0.5 if ag_c_4b==15 & ag_c_4b_other=="heads of water melons" 
*
replace conv_sale=28 if ag_c_4b==15 & ag_c_4b_other=="pick up trucks" & crop_roster_sale__id==15 
*
replace conv_sale=15 if ag_c_4b==15 & ag_c_4b_other=="pockets" & crop_roster_sale__id==11
**********************************************
//Conversions
gen ag_c_1a_units=ag_c_1a*conv_harv if ag_c_1a!=.
gen ag_c_4a_units=ag_c_4a*conv_sale if ag_c_4a!=.
*account stock sales
replace ag_c_4a_units=ag_c_1a_units if ag_c_1a_units<ag_c_4a_units
*impute price using value sales divided by value quant sold
 gen regprice_crop=ag_c_5/ag_c_4a_units
 *clean up prices
 *egen x= mean(regprice_crop) if regprice_crop!=., by(crop_roster_sale__id)
 *range tobacco price
*replace regprice_crop=x if regprice_crop>10 & regprice_crop!=. | regprice_crop<10 & regprice_crop!=.
*drop x
*value production by imputed prices
gen prod_value= ag_c_1a_units*regprice_crop if ag_c_1a_units!=. & regprice_crop!=.
egen sum_prod_value=sum(prod_value), by(interview__id) missing
gen HCI= (sum_ag_c_5/sum_prod_value)*100 if sum_ag_c_5!=. & sum_prod_value!=. 
*replace if HCI is above 100 (slightly)
replace HCI=100 if HCI>101 & HCI!=.
*Duplicates in terms of interview__id sum_ag_c_5
gen x=ag_c_2
replace x=. if ag_c_2==2
egen crop_sale=max(x), by(interview__id) 
replace crop_sale=0 if crop_sale==.
egen sum_ag_c_1a_units=sum(ag_c_1a_units), by(interview__id) missing
lab var sum_ag_c_1a_units "Production quantity in kgs"
lab var sum_ag_c_5 "Gross value of crop sales"
save "$data\HCI commercialisation plot crop.dta", replace

**************************************************************************
*9 Oct 2018* Amrita
**************************************************************************

***HH Demographics
*Creating Household size variable 
/*use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1.dta"
rename ( hh_a_13__0  hh_a_13__1  hh_a_13__2  hh_a_13__3  hh_a_13__4  hh_a_13__5  hh_a_13__6  hh_a_13__7  hh_a_13__8  hh_a_13__9  hh_a_13__10  hh_a_13__11  hh_a_13__12  hh_a_13__13  hh_a_13__14 ) S_= 
reshape long S_ , i( interview__id ) string
by interview__id S_, sort: gen nvals = (_n == 1) * (S_ != "##N/A##")
by interview__id : replace nvals = sum(nvals)
by interview__id : replace nvals = nvals[_N]
reshape wide S_, i( interview__id ) string
rename S_* *
gen HouseholdSize = nvals
sum HouseholdSize */
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
save "$data\hhd_demographics", replace


**OUTCOME INDICATORS (Vine)

****1. Generating assets index using PCA****
use "$rawdata\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1.dta", clear
*retrieving assets involving string variables (asbestos)
count if hh_e_25b == "Asbestos"
label define hh_e_25a  10 "asbestos", add
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "asbestos"
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "Asbestos"
replace hh_e_25a=10 if hh_e_25a==9 & hh_e_25b== "asbestos roof"
replace hh_e_26a=9  if hh_e_26a==10 & hh_e_26b== "Bricks with mortar mixed with cement" | hh_e_26b== "bricks and cement" | hh_e_26b== "bricks and mortar mixed with cement" | hh_e_26b== "bricks and mud"
 
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
global xlist hh_e_23a__1  hh_e_23a__2  hh_e_23a__3  hh_e_23a__4  hh_e_23a__5  hh_e_23a__6  hh_e_23a__7  hh_e_23a__8  hh_e_23a__9  hh_e_23a__10  hh_e_23a__11 hh_e_24a__1  hh_e_24a__2  hh_e_24a__3  hh_e_24a__4  hh_e_24a__6  hh_e_24a__7  hh_e_24a__8  hh_e_24a__9  hh_e_24a__10 roof_noroof  roof_grass  roof_corrugated  roof_wood  roof_cement  roof_other  roof_Asbestos Wall_dirt  Wall_woodbamboo  Wall_stone  Wall_ConcreteCement  Wall_Cement  Wall_Woodplanks  Wall_TiledBricks  Wall_Others floor_dirt  floor_cowdung  floor_cowdungandsoil  floor_stone  floor_concrete  floor_cement  floor_tiledbricks toilet_nofacility  toilet_pitlatrine  toilet_ventilated  toilet_flush  toilet_other Water_natural  Water_unprotectedwell  Water_protectedwell  Water_pipedsupply  Water_Borehole Lighting_candles  Lighting_firewood  Lighting_paraffin  Lighting_electricity  Lighting_gas  Lighting_solar  Lighting_other  Lighting_Nosource  Lighting_Torch cookingfuel_Driedleaves cookingfuel_firewood cookingfuel_parafin cookingfuel_electricity cookingfuel_gas cookingfuel_solar
global id interview__id
pca $xlist, mineigen(1)
predict WealthIndex
xtile WealthClass= WealthIndex, nq(3)

***Creating Production Asset Index (only focusing on the 11 production equipment)
global xlist hh_e_23a__1  hh_e_23a__2  hh_e_23a__3  hh_e_23a__4  hh_e_23a__5  hh_e_23a__6  hh_e_23a__7  hh_e_23a__8  hh_e_23a__9  hh_e_23a__10  hh_e_23a__11
global id interview__id
pca $xlist, mineigen(1) 
predict ProductionAssetIndex
xtile ProductionAssetClass= ProductionAssetIndex, nq(3)


*3. Any child death in the family (hh_f_10)
gen ChildDeath=0
replace ChildDeath=1 if hh_f_10==1

*4. Whether a member is malnourished (hh_f_2__1; hh_f_2__2; hh_f_2__3; hh_f_2__4; hh_f_2__5; hh_f_2__6; hh_f_2__7; hh_f_2__8; hh_f_2__9)

***household considered malnourished if they experience any of the listed cases
gen Malnourished=0
replace Malnourished=1 if hh_f_2__1==1| hh_f_2__2==1| hh_f_2__3==1| hh_f_2__4==1| hh_f_2__5==1| hh_f_2__6==1| hh_f_2__7==1| hh_f_2__8==1| hh_f_2__9==1

*5. Household has no electricity (hh_e_31a) 
**household has no electricity if primary source of lighting is not electricity
gen NoElectricity= 0
replace NoElectricity= 1 if hh_e_31a !=6

*6. Household’s sanitation facility is not improved (hh_e_28a) 
**improved sanitation includes pit latrine, ventilated pit latrine and flush toilet. The rest are unimproved options (no facility, field, bush, bucket, thatch )
gen UnimprovedSanitation=0
replace UnimprovedSanitation=1 if hh_e_28a==1 | hh_e_28a==2 | hh_e_28a==6


*7. Household does not have access to safe drinking water (If hh_e_30a)
***safe drinking water regarded as protected well/spring, taped water and borehole. The rest are considered unsafe (natural river, unprotected wells)
generate UnsafeDrinkingWater=0
replace UnsafeDrinkingWater =1 if hh_e_30a==1|hh_e_30a==2

*8. Household has a mud or sand floor (hh_e_27a)
**Improved floor covers any of: (a) Concrete (b) Cement (c) Wood Planks (d) Tiled/Bricks. The rest are considered unimproved (dirt, dung, dung and soil, stone) 
generate UnImprovedFloor=0
replace UnImprovedFloor =1 if hh_e_27a==1|hh_e_27a==2|hh_e_27a==3|hh_e_27a==4

*9. Household cooks with wood or charcoal (hh_e_29a)
**Improved cooking covers electricity, paraffin/ kerosene, gas and solar. The rest are unimproved (leaves, cow-dung, firewood, charcoal) 
generate UnimprovedCookingFuel=0
replace UnimprovedCookingFuel=1 if hh_e_29a==1|hh_e_29a==2|hh_e_29a==3|hh_e_29a==4

*10. Household does not own more than one asset (radio, TV, telephone, bike, motorbike,refrigerator), and does not own car (hh_e_24a).

***series of assets dummies (1=Yes, 0=No) on the consumer durables 
egen NumberDurableAssets = anycount(hh_e_24a__3 hh_e_24a__4 hh_e_24a__5 hh_e_24a__7 hh_e_24a__8 hh_e_24a__9), values(1)
gen AssetsDeprived=0
replace AssetsDeprived=1 if NumberDurableAssets<2 & hh_e_24a__10==0
save "$data\Assets_index.dta2018", replace

***GENERATING THE MULTIDIMENSIONAL POVERTY INDEX (MPI)*** 

use "$rawdata\hhroster.dta", clear

reshape wide hh_a_13 hh_a_14 hh_a_15 hh_a_15_months hh_a_16 hh_a_17 hh_a_18 ///
hh_a_19 hh_a_20 hh_a_21 hh_a_21_other hh_a_22 hh_a_23 hh_f_5 hh_f_6a hh_f_6b ///
hh_f_6c hh_f_6d  hh_a_22_other LackSchooling OutofSchool, i(interview__id) ///
j(hhroster__id)
*1. There is a member that does not have 5 Years of Schooling (years of schooling variable hh_a_19)
egen no5years = anycount( hh_a_191 hh_a_192 hh_a_193 hh_a_194 hh_a_195 hh_a_196 hh_a_197 hh_a_198 hh_a_199 hh_a_1910 hh_a_1911 hh_a_1912 hh_a_1913 hh_a_1914 hh_a_1915 ), values(1 2 3 4)
gen LackSchooling=0
replace LackSchooling=1 if no5years >0

*2. Any school age child is not in primary school (hh_a_23)
egen outschool = anycount( hh_a_231 hh_a_232 hh_a_233 hh_a_234 hh_a_235 hh_a_236 hh_a_237 hh_a_238 hh_a_239 hh_a_2310 hh_a_2311 hh_a_2312 hh_a_2313 hh_a_2314 hh_a_2315 ), values(1)
gen OutofSchool=0
replace OutofSchool=1 if outschool >0
save "$data\hhroster_wide without schooling2018.dta", replace 

*(ON LAPTOP) use "C:\Users\ShakinahGlory\OneDrive\APRA\STATA Data\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1.dta" 

//use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1.dta"


//save "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1_VineFile.dta"
use "$data\Assets_index.dta2018", clear
***MPI stata code**
merge 1:1 interview__id using "$data\hhroster_wide without schooling2018.dta"
drop _mer
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) d3(NoElectricity ///
UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor UnimprovedCookingFuel ///
AssetsDeprived) w1(0.16 0.16) w2(0.16 0.16) w3(0.06 0.06 0.06 0.06 0.06 0.06), ///
cutoff(0.3) deprivedscore(MPI_score) depriveddummy(MPI_class)

*no weights
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) d3(NoElectricity ///
UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor UnimprovedCookingFuel ///
AssetsDeprived), cutoff(0.3) deprivedscore(MPI_score1) depriveddummy(MPI_class1)

*by Mvurwi vs Concession (Hotspot-Coldspot)
mpi d1(LackSchooling OutofSchool) d2(ChildDeath Malnourished) d3(NoElectricity ///
UnimprovedSanitation UnsafeDrinkingWater UnImprovedFloor UnimprovedCookingFuel ///
AssetsDeprived), cutoff(0.3) by ( hh_a04b1 )
save "$data\AssetIndex_MPI2018.dta", replace
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
save "$data\crops grown.dta", replace
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
save "$data\crops sold.dta", replace
restore
**
***generating total cropped area for each crop (in Hectares)*
tab ag_b_04b,mi
g CropArea=0
replace CropArea = ag_b_04a if ag_b_04b ==2
replace CropArea = ag_b_04a/ 2.471 if ag_b_04b ==1 
replace CropArea = ag_b_04a/10000 if ag_b_04b ==3
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
drop if crop_roster_sale__id==.
reshape wide CropArea, i(interview__id) j(crop_roster_sale__id)
save "$data\Crops Area.dta", replace
**
*crop production
use "$data\HCI commercialisation plot crop.dta", clear
preserve
keep interview__id interview__id ag_b_2_plot_roster__id crop_roster_sale__id ag_c_1a_units
collapse (sum) ag_c_1a_units, by(interview__id crop_roster_sale__id)
ren ag_c_1a_units output
drop if crop_roster_sale__id==.
reshape wide output, i(interview__id) j(crop_roster_sale__id)
save "$data\crop_output", replace
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
save "$data\fert_use2018", replace
restore
**
*Tractor Tillage services
tab ag_b_29b__1
collapse (sum) ag_b_29b__1, by(interview__id)
g tr_tillage=(ag_b_29b__1>0)
drop ag_b_29b__1
lab var tr_tillage "Household used tractor tillage services"
save "$data\tr_tillage2018", replace
**
use "$data\fert_use2018", clear
mer 1:1 interview__id using "$data\tr_tillage2018"
drop _mer
save "$data\fert_tillage2018", replace
**
*hired lab used
use "$rawdata\services_hired", clear
order interview__id interview__key ag_b_2_plot_roster__id
g mandays = ag_b_22*ag_b_23
collapse mandays (sum) ag_b_24 other_remun_value, by(interview__id)
lab var other_remun_value other_hlab_remun_val
save tmp1, replace
**
use "$rawdata\Additional_Inputs", clear
order interview__id interview__key crop_roster_sale__id ag_b_2_plot_roster__id
collapse (sum) ag_b_30d, by(interview__id)
ren ag_b_30d add_inputs
lab var add_inputs "Cost of additional inputs"
save "$data\add_inputs", replace
**
use "$rawdata\Other_Inputs", clear
order interview__id interview__key ag_b_2_plot_roster__id crop_roster_sale__id
collapse (sum) ag_b_34, by(interview__id)
save "$data\other_inputs", replace
**
use "$data\fert_tillage2018", clear
mer 1:1 interview__id using tmp1
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
save "$data\input_use2018", replace
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
save "$data\livestock2018", replace
restore
collapse (sum) ag_d_14 ag_d_11 ag_d_12 ag_d_12b ag_d_12c, by(interview__id)
lab var ag_d_14 "Live livestock sales"
lab var ag_d_11 "cost of veterinary drugs"
lab var ag_d_12 "cost of feed"
lab var ag_d_12b "labor cost:livestock"
lab var ag_d_12c "other livestock costs"
save "$data\livestockcosts", replace
**
use "$rawdata\livestock_produce", clear
collapse (sum) ag_d_19, by(interview__id)
lab var ag_d_19 "sales of livestock produce"
save "$data\live_produce", replace
**
*marketing costs
use "$rawdata\Sale_Modality", clear
collapse (sum) ag_c_13, by(interview__id)
lab var ag_c_13 "transport costs"
save "$data\transportcosts", replace
**
use "$rawdata\Sale_Modality_other", clear
collapse (sum) ag_c_13other, by(interview__id)
lab var ag_c_13other "other crop transport costs"
save "$data\othertransportcosts", replace
**
use "$rawdata\crop_roster_sale", clear
collapse (sum) ag_c_16 ag_c_17 ag_c_18,by(interview__id)
lab var ag_c_16 "grading costs"
lab var ag_c_17 "curing/milling costs"
lab var ag_c_18 "storing costs"
save "$data\marketingcosts", replace
**
use "$rawdata\crop_roster_sale_other", clear
collapse (sum) ag_c_16other ag_c_17other ag_c_18other, by(interview__id)
lab var ag_c_16other "other grading costs"
lab var ag_c_17other "other curing/milling costs
lab var ag_c_18other "other storing costs"
save "$data\marketingcosts_other", replace
**
use "$data\transportcosts", clear
mer 1:1 interview__id using "$data\othertransportcosts"
drop _mer
mer 1:1 interview__id using "$data\marketingcosts"
drop _mer
mer 1:1 interview__id using "$data\marketingcosts_other"
drop _mer
save "$data\marketingcosts_fin", replace
***
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
for var ag_b_09__* ag_b_10__*: replace X="" if X=="##N/A##"
save tmp1, replace
*
g hhroster__id=real(ag_b_09__0) 
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer
keep interview__id ag_b_2_plot_roster__id hh_a_14
reshape wide hh_a_14, i(interview__id) j(ag_b_2_plot_roster__id)
g manage=(hh_a_141==2 | hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2) if ///
hh_a_141!=. | hh_a_142!=. | hh_a_143!=. | hh_a_144!=. | ///
hh_a_145!=. | hh_a_146!=. | hh_a_147!=. | hh_a_148!=. | hh_a_149!=.
drop hh_a_14*
lab var manage "Women involved in primarily managing plots"
save tmp2, replace
*Who primarily decides how the outputs from the plot are used (consumption or sales of crops, etc.)?
use tmp1, clear
g hhroster__id=real(ag_b_10__0) 
so interview__id hhroster__id
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer
keep interview__id ag_b_2_plot_roster__id hh_a_14
reshape wide hh_a_14, i(interview__id) j(ag_b_2_plot_roster__id)
g manage1=(hh_a_141==2 | hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | ///
hh_a_145==2 | hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2) if ///
hh_a_141!=. | hh_a_142!=. | hh_a_143!=. | hh_a_144!=. | ///
hh_a_145!=. | hh_a_146!=. | hh_a_147!=. | hh_a_148!=. | hh_a_149!=.
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
g hhroster__id=real(ag_c_3)
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
egen cropid=group(ag_b_2_plot_roster__id crop_roster_sale__id)
keep interview__id hh_a_14 cropid
reshape wide hh_a_14, i(interview__id) j(cropid)
g manage2=(hh_a_141==2 | hh_a_142==2 | hh_a_143==2 | hh_a_144==2 | hh_a_145==2 ///
| hh_a_146==2 | hh_a_147==2 | hh_a_148==2 | hh_a_149==2 | hh_a_1410==2 | hh_a_1411==2 ///
| hh_a_1412==2 | hh_a_1413==2 | hh_a_1414==2 | hh_a_1414==2 | hh_a_1416==2 | hh_a_1417==2 ///
| hh_a_1418==2 | hh_a_1419==2 | hh_a_1420==2 | hh_a_1421==2 | hh_a_1422==2 | hh_a_1423==2 ///
| hh_a_1424==2 | hh_a_1425==2 | hh_a_1426==2 | hh_a_1427==2 | hh_a_1428==2 | hh_a_1429==2 ///
| hh_a_1430==2 | hh_a_1431==2 | hh_a_1432==2 | hh_a_1433==2 | hh_a_1434==2 | hh_a_1435==2 ///
| hh_a_1436==2 | hh_a_1437==2 | hh_a_1438==2 | hh_a_1439==2 | hh_a_1440==2 | hh_a_1441==2 ///
| hh_a_1442==2 | hh_a_1443==2 | hh_a_1444==2 | hh_a_1445==2 | hh_a_1446==2 | hh_a_1447==2 ///
| hh_a_1448==2 | hh_a_1449==2 | hh_a_1450==2 | hh_a_1451==2 | hh_a_1452==2 | hh_a_1453==2 ///
| hh_a_1454==2 | hh_a_1455==2 | hh_a_1456==2 | hh_a_1457==2) if hh_a_141!=. | hh_a_142!=. ///
| hh_a_143!=. | hh_a_144!=. | hh_a_145!=. | hh_a_146!=. | hh_a_147!=. | hh_a_148!=. ///
| hh_a_149!=. | hh_a_1410!=. | hh_a_1411!=. ///
| hh_a_1412!=. | hh_a_1413!=. | hh_a_1414!=. | hh_a_1414!=. | hh_a_1416!=. | hh_a_1417!=. ///
| hh_a_1418!=. | hh_a_1419!=. | hh_a_1420!=. | hh_a_1421!=. | hh_a_1422!=. | hh_a_1423!=. ///
| hh_a_1424!=. | hh_a_1425!=. | hh_a_1426!=. | hh_a_1427!=. | hh_a_1428!=.| hh_a_1429!=. ///
| hh_a_1430!=. | hh_a_1431!=. | hh_a_1432!=. | hh_a_1433!=. | hh_a_1434!=. | hh_a_1435!=. ///
| hh_a_1436!=. | hh_a_1437!=. | hh_a_1438!=. | hh_a_1439!=. | hh_a_1440!=. | hh_a_1441!=. ///
| hh_a_1442!=. | hh_a_1443!=. | hh_a_1444!=. | hh_a_1445!=. | hh_a_1446!=. | hh_a_1447!=. ///
| hh_a_1448!=. | hh_a_1449!=. | hh_a_1450!=. | hh_a_1451!=. | hh_a_1452!=. | hh_a_1453!=. ///
| hh_a_1454!=. | hh_a_1455!=. | hh_a_1456!=. | hh_a_1457!=.
drop hh_a_14*
lab var manage2 "Women involved in deciding whether to sell crop"
save tmp4, replace
**
use "$rawdata\Sale_Modality", clear
order interview__id ag_b_2_plot_roster__id crop_roster_sale__id
keep interview__id ag_b_2_plot_roster__id crop_roster_sale__id Sale_Modality__id ag_c_15
drop if missing(ag_c_15)
drop ag_b_2_plot_roster__id crop_roster_sale__id Sale_Modality__id
g hhroster__id=real(ag_c_15)
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer ag_c_15 hhroster__id
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
replace ag_d_6a__0="." if ag_d_6a__0=="-999999999"
g hhroster__id=real(ag_d_6a__0)
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer ag_d_6a__0 hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
ren women2 women1
lab var women1 "Women owns cattle"
save tmp6, replace
restore
**
preserve
keep interview__id ag_d_6b__0 
g hhroster__id=real(ag_d_6b__0)
mer m:m interview__id hhroster__id using tmp
keep if _mer==3
drop _mer ag_d_6b__0 hhroster__id
tab hh_a_14, g(women)
drop hh_a_14 women1
lab var women2 "Women responsible for taking care of cattle"
save tmp6, replace
restore
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
save "$data\women_empower", replace
**
*AGRI SERVICES AND INFRASTRUCTURE
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
use "$rawdata\fertiliser", clear
order interview__id ag_b_2_plot_roster__id crop_roster_sale__id
g conv_input=1
replace conv_input=1 if ag_b_28c==1
replace conv_input=1000 if ag_b_28c==2
replace conv_input=20 if ag_b_28c==3&ag_b_28c_other=="20 litre bucket"
replace conv_input=1 if ag_b_28c==3&ag_b_28c_other=="5 litre galon"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50 kg bag"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50 kg bags"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50 kgs bag"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50 kgs bags"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50kg bags"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50kgs bag"
replace conv_input=50 if ag_b_28c==3&ag_b_28c_other=="50kgs bags"
replace conv_input=500 if ag_b_28c==3&ag_b_28c_other=="carts"
replace conv_input=0.2 if ag_b_28c==3&ag_b_28c_other=="liters" | ag_b_28c_other=="litres"
g fert=conv_input*ag_b_28b if ag_b_28b!=. & conv_input!=.
egen sum_fert=sum(fert), by(interview__id) missing
egen sum_fertcost=sum(ag_b_28d), by(interview__id) missing
keep interview__id sum_fert sum_fertcost
duplicates drop
lab var sum_fert "Fertiliser used in kgs"
lab var sum_fertcost "Cost of fertiliser in usd"
winsor2 sum_fert if sum_fert!=., replace cuts(10 90)
winsor2 sum_fertcost if sum_fertcost!=., replace cuts(5 95)
save "$data\fertileruse", replace
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
save "$data\regular_inc_long", replace
byso interview__id: egen months = total(monthlyinc_regular>0)
reshape wide monthlyinc_regular, i(interview__id) j(month)
save "$data\regular_pay", replace
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
save "$data\duplicates", replace
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
save "$data\hh_ent_inc_long", replace
reshape wide month_inc_ent, i(interview__id) j(month)
order totinc_enter, after(interview__id)
save "$data\hh_ent_inc1", replace
**
use "$data\duplicates", clear
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
save "$data\hh_ent_inc1_long", replace
reshape wide month_inc_ent, i(interview__id) j(month)
order totinc_enter, after(interview__id)
save "$data\hh_ent_inc2", replace
append using "$data\hh_ent_inc1"
save "$data\hh_ent_income", replace
*long data
use "$data\hh_ent_inc_long", clear
append using "$data\hh_ent_inc1_long"
save "$data\hh_ent_income_long_fin", replace
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
save "$data\cropsales_month_long", replace
byso interview__id: egen months_cropsale = total(cropsale_month>0)
reshape wide cropsale_month, i(interview__id) j(month)
order tot_cropsales, after(interview__id)
save "$data\cropsales_month_wide", replace
**
*Income from livestock sales
use "$rawdata\livestockroster", clear
order interview__id interview__key
keep interview__id ag_d_14
collapse (sum) ag_d_14, by(interview__id)
ren ag_d_14 livestocksale
save "$data\livestocksale_inc", replace
**
*Livestock Produce
use "$rawdata\livestock_produce", clear
order interview__id interview__key
keep interview__id livestock_produce__id ag_d_19 ag_d_20a__1-ag_d_20c
drop if interview__id == "00d88b6fe84d4e0abdc102154e065191"
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
save "$data\livestock_produce_long", replace
byso interview__id: egen months_livestock = total(livprodsales_month>0)
*
reshape wide livprodsales_month, i(interview__id) j(month)
order ag_d_19, after(interview__id)
save "$data\livestock_produce_wide", replace
**

*OTHER INCOMES AND SUBJECTIVE POVERTY MEASURES
use "$rawdata\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1", clear
keep interview__id hh_e_20_1-hh_e_19a_others__2 hh_e_32-hh_e_36

**************
*Merging all the datasets
use "$data\Household Panel_fin.dta", clear
mer m:m interview__id using "$data\HCI commercialisation plot crop.dta"
drop _mer
order hhroster__id, before(individ_id)
mer m:m interview__id hhroster__id using "$data\hhd_demographics"
drop if _mer==2
drop _mer
mer m:1 interview__id using "$data\AssetIndex_MPI2018.dta"
keep if _mer==3
drop _mer
mer m:1 interview__id using "$data\crops grown.dta"
drop _mer
mer m:1 interview__id using "$data\crops sold.dta"
drop _mer
mer m:1 interview__id using "$data\Crops Area.dta"
drop _mer
mer m:1 interview__id using "$data\crop_output"
drop _mer
mer m:1 interview__id using "$data\input_use2018" 
drop if _mer==2
drop _mer
mer m:1 interview__id using "$data\livestock2018"
drop if _mer==2
drop _mer
mer m:1 interview__id using "$data\livestockcosts"
drop _mer
mer m:1 interview__id using "$data\women_empower"
drop _mer
mer m:1 interview__id using "$data\hhd_services"
drop _mer
mer m:1 interview__id using "$data\fertileruse"
drop _mer
mer m:1 interview__id using "$data\add_inputs"
drop _mer
mer m:1 interview__id using "$data\other_inputs"
drop _mer
mer m:1 interview__id using "$data\live_produce"
drop _mer
mer m:1 interview__id using "$data\marketingcosts_fin"
drop _mer
mer m:1 interview__id using "$data\regular_pay"
drop _mer
mer m:1 interview__id using "$data\hh_ent_income"
drop _mer
mer m:1 interview__id using "$data\cropsales_month_wide"
drop _mer
mer m:1 interview__id using "$data\livestocksale_inc"
drop _mer
mer m:1 interview__id using  "$data\livestock_produce_wide"
drop _mer
keep if hh_a_16==1 /*household level data*/
duplicates drop interview__id, force
winsor2 sum_ag_c_5 if sum_ag_c_5!=., replace cuts(10 90) 
winsor2 sum_prod_value if sum_prod_value!=., replace cuts(10 90)
g year=2018
ren hh_a_06 HHID
order HHID year, before(hh_a_05b)
*resolve supervisor and enumerator names
for var hh_a_07 hh_a_08:decode X, g(_X)
order _hh_a_07 _hh_a_08, before(hh_a_09)
drop hh_a_07 hh_a_08
ren (_hh_a_07 _hh_a_08)(hh_a_07 hh_a_08)
drop interview__id hhroster__id individ_id interview__key
save "$data\household_finmerged2018", replace
**

exit




/*use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\plots_current year.dta"
collapse (sum) ag_b_17__1 - ag_b_17__21 , by( interview__key )
foreach var of varlist ag_b_17__1 - ag_b_17__21 {
  replace `var' = 1 if `var' > 1
}

save "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\crops grown.dta"


***dummy for crop sales**
use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\plots_current year.dta" 
gen sale_maize=0
replace sale_maize=1 if ag_c_2==1 & crop_roster_sale__id==1
gen sale_tobacco=0
replace sale_tobacco=1 if ag_c_2==1 & crop_roster_sale__id==2
gen sale_groundnut=0
replace sale_groundnut=1 if ag_c_2==1 & crop_roster_sale__id==3
gen sale_cowpeas=0
replace sale_cowpeas=1 if ag_c_2==1 & crop_roster_sale__id==6
gen sale_commonbean=0
replace sale_commonbean=1 if ag_c_2==1 & crop_roster_sale__id==7
gen sale_soyabean=0
replace sale_soyabean=1 if ag_c_2==1 & crop_roster_sale__id==8
gen sale_sorghum=0
replace sale_sorghum=1 if ag_c_2==1 & crop_roster_sale__id==9
gen sale_sweetpotato=0
replace sale_sweetpotato=1 if ag_c_2==1 & crop_roster_sale__id==12
gen sale_tomato=0
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

collapse (sum) sale_maize sale_tobacco sale_groundnut sale_cowpeas sale_commonbean sale_soyabean sale_sorghum sale_sweetpotato sale_tomato , by( interview__key )
foreach var of varlist sale_maize sale_tobacco sale_groundnut sale_cowpeas sale_commonbean sale_soyabean sale_sorghum sale_sweetpotato sale_tomato {
  replace `var' = 1 if `var' > 1
}
 
save "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\crops sold.dta"

***generating total cropped area for each crop (in Hectares)*
use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\plots_current year.dta" 
tab ag_b_04b
gen CropArea=0
replace CropArea = ag_b_04a if ag_b_04b ==2
replace CropArea = ag_b_04a/ 2.471 if ag_b_04b ==1 
replace CropArea = ag_b_04a/10000 if ag_b_04b ==3
label variable CropArea "Area cropped in Hectares"
gen maize_ha = CropArea if crop_roster_sale__id==1
gen tobacco_ha = CropArea if crop_roster_sale__id==2
gen groundnuts_ha = CropArea if crop_roster_sale__id==3
gen cowpeas_ha = CropArea if crop_roster_sale__id==6
gen commonbean_ha = CropArea if crop_roster_sale__id==7
gen soyabean_ha = CropArea if crop_roster_sale__id==8
gen sorghum_ha = CropArea if crop_roster_sale__id==9
gen sweetpotato_ha = CropArea if crop_roster_sale__id==12
gen tomato_ha = CropArea if crop_roster_sale__id==15
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
save "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\Crops Area.dta" 

***exploring total harvest for each crop***
use "C:\Users\Dr Mutyasira\Dropbox\Vine & Amrita APRA\Data\HCI plot crop.dta"
sum ag_c_1a_units if crop_roster_sale__id==1
sum ag_c_1a_units if crop_roster_sale__id==2
sum ag_c_1a_units if crop_roster_sale__id==3
sum ag_c_1a_units if crop_roster_sale__id==6
sum ag_c_1a_units if crop_roster_sale__id==7
sum ag_c_1a_units if crop_roster_sale__id==8
sum ag_c_1a_units if crop_roster_sale__id==9
sum ag_c_1a_units if crop_roster_sale__id==12
sum ag_c_1a_units if crop_roster_sale__id==15


****livestock information***
***% hh owning livestock types***
use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\APRA Survey Instrument April 2018 Zimbabwe WS1 Round 1.dta"
tab ag_d_1a__1
tab ag_d_1a__2
tab ag_d_1a__3
tab ag_d_1a__4
tab ag_d_1a__5
tab ag_d_1a__6
tab ag_d_1a__7

****total livestock raised, owned, value, slaughter, purchases, quantity sold***
use "C:\Users\Dr Mutyasira\OneDrive\APRA\STATA Data\livestockroster.dta"
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

***livestock ownership (numbers) by type***
gen cattle_owned= ag_d_3 if livestockroster__id==1
gen goats_owned= ag_d_3 if livestockroster__id==2
gen sheep_owned= ag_d_3 if livestockroster__id==3
gen pigs_owned= ag_d_3 if livestockroster__id==4
gen poultry_owned= ag_d_3 if livestockroster__id==5
gen donkey_owned= ag_d_3 if livestockroster__id==6

***generating Tropical Livestock Units (TLU)***
gen cattleind= 0.7* cattle_owned
gen goatsind= 0.1* goats_owned
gen sheepind= 0.1* sheep_owned
gen pigind= 0.2* pigs_owned
gen poultryind= 0.01* poultry_owned
gen donkeyind= 0.5* donkey_owned
egen TLU= rowtotal (cattleind goatsind sheepind donkeyind pigind poultryind)
label variable TLU "Tropical Livestock Units"
