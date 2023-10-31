clear
set more off, perm 
cap log close
global root "C:\Users\Mahofa\OneDrive - University of Cape Town\CurrentWork\APRA"
global tmp "C:\Users\Mahofa"
global code "$root\code"
global output "$root\output"
global data "$root\data"

do "$code\APRA_create_panel2018.do"
do "$code\APRA_create_panel.do"
do "$code\apra_panel_descriptive.do"

exit
