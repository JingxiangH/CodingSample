cd "C:\Users\jason\Dropbox\LZK\新能源汽车\报道\Peterson\Bown-EV-May-2023"

// CAR IMPORT 2017-2023

use "Raw-China\Car imports_2017-2023.dta", clear

preserve

collapse (sum) quantity value, by (year)

describe

list year quantity value, sepby (year)

gen num_year = real(year)

sort year

twoway (line quantity num_year,yaxis(1) lcolor(blue))(line value num_year,yaxis(2) lcolor(red)), title("Annual Sum of Import"), if num_year < 2023

//graph export Raw-China\Output\import.png, as(png) replace

save Raw-China\Output\China_import_sum_year_2017-2023.dta, replace

restore

//CAR EXPORT 2017-2023

use "Raw-China\Car exports_2017-2023.dta", clear

preserve

collapse (sum) quantity value, by (year)

describe

list year quantity value, sepby (year)

gen num_year = real(year)

sort year

twoway (line quantity num_year,yaxis(1) lcolor(blue))(line value num_year,yaxis(2) lcolor(red)), title("Annual Sum of Export"), if num_year < 2023

//graph export Raw-China\Output\export.png, as(png) replace

save Raw-China\Output\China_export_sum_year_2017-2023.dta, replace

restore