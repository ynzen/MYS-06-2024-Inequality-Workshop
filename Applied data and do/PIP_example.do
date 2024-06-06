********************************************************************************
/*
Author:  		Nishant Yonzan
Email:	 		nyonzan@worldbank.org
Organization: 	Global Poverty and Inequality Data team, DECDG, World Bank
Date:    		06/06/2024
Purpose: 		Introduction to PIP Stata ado.
*/
********************************************************************************
**********************************
*** PIP Stata ado installation ***
**********************************

/*
ssc install pip

// other resources 

help pip

PIP Stata package: 	https://worldbank.github.io/pip/
PIP R package: 		https://worldbank.github.io/pipr/

*/

*****************************
*** PIP country estimates ***
*****************************


// query a country survey, example Bangladesh 2016
pip, country(mys) year(2018) clear

// estimates using 2011 PPPs
pip, country(mys) year(2018) clear ppp_year(2011)

// query a lineup estimate (estimate used for global poverty calculations)
pip, country(mys) year(2018) clear fillgaps
sum headcount

// query all years
pip, country(mys) year(all) clear fillgaps
tabstat headcount, by(year) stat(mean)

// more than 1 country
pip, country(mys bra) year(2018) clear fillgaps 
list country_code reporting_level headcount

// or all countries
pip, country(all) year(2018) clear fillgaps


// other povertylines besides the default international poverty line
pip, country(mys) year(2018) clear fillgaps povline(6.85)
sum headcount

// multiple poverty lines
pip, country(mys) year(2018) clear fillgaps povline(2.15 6.85 10 25)
tabstat headcount, by(poverty_line) stat(mean) 


// query the welfare threshold specifying population
pip, country(mys) year(2018) clear fillgaps popshare(0.5)
sum poverty_line



*** Excercise 1 *** 
/*
Download the poverty data for Malaysia, Brazil, 
*/



*************************************
*** Global and Regional estimates ***
*************************************

// all global and regional estimates 
pip wb, clear 

// choose only one region and one year; below code choose the global option
pip wb, clear region(wld) year(2019)


*****************************
*** other useful commands ***
*****************************

// auxillary files (population, gdp, etc.)
pip tables, clear

// data availability
pip info, clear

// pip versions
pip version, clear



******************************************
*** GIC using PIP percentile file data ***
******************************************

/* 
percentile data for all countries from PIP: 
https://datacatalog.worldbank.org/search/dataset/0063646/Poverty-and-Inequality-Platform--PIP---Percentiles
*/

// GIC as in the earlier session.

use "${workshop}Workshop_Example_Data.dta", clear

egen percentile = xtile(net_totinc_hh), weight(weight) by(year) nq(100)

collapse net_totinc_hh [w=weight], by(year percentile)

bys percentile (year): gen growth =  (net_totinc_hh/net_totinc_hh[_n-1] - 1) * 100

twoway connected growth percentile, ytitle("%") title("Cumulative growth in Malaysia, 2012-2022")


*** Exercise 2 ***
/*
a. Generate a growth incidence curve for Malaysia with annualized growth rates.

b. Download the percentile data from the above link. Generate a annualized growth incidence curve for Malaysia for years 2003 to 2018.
*/


********************************************************************************
exit