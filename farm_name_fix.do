**Fixing missing farm names
use "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA\rawdata\APRA Zimbabwe Panel\1. R1_R2_Section_A_Interview_Details_zmb.dta", clear
label define hh_a_05b 18 "Forrester J" 19 "Forrester K", add
*Populating the Forrester J and K wards (based on the comments section on variable hh_a_05b, attached excel file and also from extension officer)
replace hh_a_05b=18 if year==2017&interview__id=="661fe814ce334b929c2d57ad2bbc03c8"| interview__id=="06bbb9041529440490f2efb7c21756cf"| interview__id=="0e9a7866a9734f4f962a0da2879e52a1"| ///
interview__id=="1a61034dab974043bf269bfee94c2795"| interview__id=="2831b889b7394b08a55a51e20e1bcb29"| interview__id=="37bd818aca5540348e9e1d1816fa0dad"| ///
interview__id=="3fb6d773092745d58a9d135be9463643" | interview__id=="5984553e92c24393b2cd878625c331cd"| ///
interview__id=="5ec02edb08b74cb3b8583c08e1f93e09"| interview__id=="5f815475b40a4f62bb1b4f5cfcb02592"| interview__id=="753c3132387f424ca9075dcb932ddb98"| ///
interview__id=="a98c09e2be4c4de3bde78a6ace7836d5"| interview__id=="b7a68202aa1644568d1f8bc268cb4029"| interview__id=="bedb890d168f4b2694da814e8af2f79b"| ///
interview__id=="c228dacfd937423789130bc211fe3b2f"| interview__id=="e30c14e5154a44b190c48a904b17d24d"| interview__id=="ebf2829dab75448a93428ef98a34932f"| ///
interview__id=="f14073b61e744f19b2e6f4d61eb9ced5"| interview__id=="fd941fcfb01e4139ba82ab433af7768a"| interview__id=="fed34b49086a4dc98b451001940de159"
replace hh_a_05b=19 if year==2017&interview__id=="03b626217f0d41ed9a17fe279beb31a6"| interview__id=="12ae03d9982d425b8d42c5ae2616bb43"| interview__id=="1a8c3716d5174be5a6a47ef2fff9d264" ///
| interview__id=="25c12f5ede8d4428beb9e78f18d4098f"| interview__id=="2b584020cf074f9faecf3b90e9ba5946"| interview__id=="341ec3884a904dd982288bd062256723"| interview__id=="3707bb5bf51a4c7a9a996f7e26816842" ///
| interview__id=="39377848d8c84a8f9a68b44094654c07"| interview__id=="3fb0e8bc84bc4af5a1e58a03a4a73d48"| interview__id=="46989c3bdd9e43d8b8c4758023b96013"| interview__id=="4b1aee91818649e1b9405235cf5b2071" ///
| interview__id=="568eddf9eb3d460ba43b6d902da852b9"| interview__id=="60623fdc034447bb8173ae40e35e515d"| interview__id=="6828012507e94a2596c2c94b7b1728f7"| interview__id=="69c03caf88fc469cafc89f214df5d3dd" ///
| interview__id=="6fdbf179199f46d3890206a6b00363dc"| interview__id=="7344e04e0e8245d9adbdd7a3fc29139c"| interview__id=="81d8589cec9047feade9988c0fb13074"| interview__id=="92856c3b05e943cd853c9e3fafe21ace" ///
| interview__id=="92899426d29d4e09995e1266919932c2"| interview__id=="97170dd2d90c4bccb40d86fd689e051c"| interview__id=="a2eb39624707486c83b768c8c0c49bd8"| interview__id=="a7e4fbfe4e22408f992172232b2a7217" ///
| interview__id=="b0d1bae022cb4c52b25ad9516d09a109"| interview__id=="cb214b23603044d1bbcdd132d5afda7b"| interview__id=="cd9158190a144e8d8e8753eda82f8c7b"| interview__id=="cdac3f8a613f4cfab842f31a1245b4fb" ///
| interview__id=="da8879d006364548a2fe8c7fe365cef7"| interview__id=="dedf9a4632bf4b0c9bc9a1c0408bc470"| interview__id=="e9ebcbf476914d04881a83e9fdb8ee8b"| interview__id=="f29dc6f1dc5442ae8c9eb4a4b6863481" ///
| interview__id=="f5269ae6fada4599873171fb07cc6dae"| interview__id=="fb93c2b64cb94a6d837237e217f01d26"
replace hh_a_05b=18 if hh_a_05b==6
**
*from interview__id from R1 we get corresponding HH ID which is consistent across the waves not interview__id)
replace hh_a_05b = 18 if year == 2019&hh_id == 270.00 | hh_id == 264.00 | hh_id == 269.00| ///
hh_id == .a |	hh_id == 277.00 | hh_id == 257.00 | hh_id == 267.00 | hh_id == 266.00 | ///
hh_id == 254.00 | hh_id == 282.00 | hh_id == 263.00 | hh_id == 260.00 | ///
hh_id == 268.00 | hh_id == 261.00 | hh_id == 272.00 | hh_id == 256.00 | ///
hh_id == 253.00 | hh_id == 262.00 | hh_id == 265.00 | hh_id == 276.00
replace hh_a_05b = 19 if hh_id == 288.00 | hh_id == 299.00 | hh_id == 284.00 | ///
hh_id == 312.00 | hh_id == 313.00 | hh_id == 297.00 | hh_id == 314.00 | ///
hh_id == 296.00 | hh_id == 291.00 | hh_id == 301.00 | hh_id == 309.00 | ///
hh_id == 306.00 | hh_id == 287.00 | hh_id == 316.00 | hh_id == 294.00 | ///
hh_id == 315.00 | hh_id == 290.00 | hh_id == 295.00 | hh_id == 288.00 | ///
hh_id == 302.00 | hh_id == 317.00 | hh_id == 300.00 | hh_id == 289.00 | ///
hh_id == 304.00 | hh_id == 303.00 | hh_id == 305.00 | hh_id == 310.00 | ///
hh_id == 293.00 | hh_id == 307.00 | hh_id == 286.00 | hh_id == 305.00 | ///
hh_id == 292.00 | hh_id == 285.00
replace hh_a_05b = 12 if hh_id == 537
replace hh_a_05b = 11 if hh_id == 451
replace hh_a_05b = 3 if hh_id == 431 | hh_id == 424
replace hh_a_05b = 4 if hh_id == 508
replace hh_a_05b = 19 if hh_id == 1008 | hh_id == 578
replace hh_a_05b = 13 if hh_id == 597
replace hh_a_05b = 17 if hh_id == 619 | hh_id == 618
replace hh_a_05b = 15 if hh_id == 707 
replace hh_a_05b = 2 if hh_id == 1001
replace hh_a_05b = 1 if hh_id == 121
replace hh_a_05b = 2 if hh_id == 1004
replace hh_a_05b = 17 if hh_id == 683
replace hh_a_05b = 7 if hh_id == 140
replace hh_a_05b = 18 if hh_id == 311
**
*Fixing the inconsistencies in farm names and area
table hh_a_05b hh_a04b1
replace hh_a04b1 = 1 if  hh_a_05b==11| hh_a_05b==10| hh_a_05b==8| hh_a_05b==9| ///
hh_a_05b==7| hh_a_05b==6| hh_a_05b==5| hh_a_05b==18| hh_a_05b==3| hh_a_05b==4| hh_a_05b==19
replace hh_a04b1 = 2 if  hh_a_05b==16| hh_a_05b==17| hh_a_05b==15|  hh_a_05b==14 ///
| hh_a_05b==1| hh_a_05b==2|  hh_a_05b==13
**
*Fixing the missing ward numbers
replace hh_a_04b = 32 if hh_id == 107 
foreach i in 320 321 322 323 324 318 319	325	326	327	328	329	330	331	332	334	335	336 ///
	337	338	339	340	341	342	343	344	348	349	350	351	352	353	354	355	356	357	358	///
	359	360	361	362	363	364	365	366	367	368	369	370	371	373	374	375	376	377	378	///
	380	382	383	384	385	386	387	388	389	390	391	392	393	394	395	397	398	399	400	///
	401	402	403	404	405	406	407	408	409	412	413 1009 1010 {
	replace hh_a_04b = 30 if hh_id == `i'
	}
foreach i in 615	616	617	620	621	622	623	624	625	626	627	628	629	630	631	632	///
633	634	635	636	637	638	639	640	641	642	643	645	647	648	649	650	651	652	653	654	///
655	656	657	658	659	660	661	662	663	664	665	666	667	668	669	670	671	672	673	674	///
675	676	677	678	679	680	681	685	686	687	688	689	690	691	692	693	694	695	696	697	///
698	699	700	701	702	703	704	705	706	709	710	711	712	713	714	715	716	717	719	720	///
721	722	723	725 1035 {
replace hh_a_04b = 31 if hh_id == `i'
}
**



