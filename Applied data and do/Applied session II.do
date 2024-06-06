********************************************************************************
/*
Date: 		07/06/2024
Author: 	Nishant Yonzan
Email:  	nyonzan@worldbank.org
Purpose: 	Inequality measures: Applied session II
			Estimation of common inequality measures.
			Decomosition of inequality; Inequality of Opportunity
*/
********************************************************************************

**********************************************
*** 1. WITHIN AND BETWEEN GROUP INEQUALITY ***
**********************************************

use "${workshop}Workshop_Example_Data.dta", clear

// MEAN LOG DEVIATION - WITHIN AND BETWEEN

encode ethnic, gen(ethnic_id)	
ineqdeco net_totinc_hh [w = weight] if year == 2022, by(ethnic_id)					// inequality estimates by group and overall


*** Excercise 1 *** 
/*
a. Estimate the share of between and within-Strata inequality for the two years.
		
*/		

** 


******************************************
*** 2. GINI DECOMPOSITION INTO FACTORS ***
******************************************

use "${workshop}Workshop_Example_Data.dta", clear

// change contribution: total net income = wages + self employment + property income + transfers

adecomp net_totinc_hh wages_hh selfem_hh propty_hh transt_hh [w=weight], by(year) equation(c1+c2+c3+c4) indicator(gini)


// add household size: total net income / per capita = 1/household size * (wages + self employment + property income + transfers)

adecomp net_totinc_hh hh_size wages_hh selfem_hh propty_hh transt_hh [w=weight], by(year) equation(c1*(c2+c3+c4+c5)) indicator(gini)


*** Excercise 2 *** 
/*
a. Decompose the Gini index for total household income constructed from wages_hh selfem_hh.

b. Decompose poverty at a poverty line of RM 1000. [Hint: check help file]		
*/		


// source contribution using SGINI 

sgini wages_hh selfem_hh propty_hh transt_hh if year==2012, sourcedecomposition


************************************
*** 3. INEQUALITY OF OPPORTUNITY ***
************************************

use "${workshop}Workshop_Example_Data.dta", clear

// create mean income by group 

egen iop_group = group(region ethnic strata sex)

bys year iop_group: egen netinc_hh_mean = wtmean(net_totinc_hh), weight(weight)

qui ineqdeco net_totinc_hh [aw=weight] if year==2012
local all = `r(gini)'

qui ineqdeco netinc_hh_mean [aw=weight] if year==2012, by(iop_group)
local iop = `r(gini)'

di iop_share = iop/all * 100

********************************************************************************
exit