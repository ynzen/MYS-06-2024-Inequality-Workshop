********************************************************************************
/*
Date: 		07/06/2024
Author: 	Nishant Yonzan
Email:  	nyonzan@worldbank.org
Purpose: 	Applied session III: Measurement of prosperity gap
			Prosperity standard and bottom coding the distribution.
			Estimation, sub-group decomposition, growth decomposition.
*/
********************************************************************************

******************
*** INPUT DATA ***
******************

use "${workshop}Workshop_Example_Data.dta", clear


********************************************
*** Prosperity threshold and bottom code ***
********************************************

gen 	welfare = net_totinc_hh
replace welfare = 30 if welfare<=0 												// BOTTOM CENSOR DATA

local threshold = 2000															// Prosperity standard for MYS


*********************************************************
*** Estimation of prosperity gap and related measures ***
*********************************************************

gen pg = `threshold'/welfare 


// Share of poeple below the threshold
gen hc = welfare < `threshold'		

// MEAN INCOME 
gen ybar = welfare

collapse pg hc ybar (rawsum) weight [w=weight], by(year)

// inequality measure 

gen i = ybar/25 * pg

*******************************
*** Sub-group decomposition ***
*******************************

use "${workshop}Workshop_Example_Data.dta", clear

gen 	welfare = net_totinc_hh

replace welfare = 30 if welfare<=0 												// BOTTOM CENSOR DATA

local threshold = 2000	

gen pg = `threshold'/welfare 	

// MEAN INCOME 
gen ybar = welfare

collapse pg ybar (rawsum) weight [w=weight], by(year ethnic)

** Excel example

***************************************************************
*** Growth decomposition into growth of mean and inequality ***
***************************************************************
** Excel example


********************************************************************************
exit