********************************************************************************
/*
Date: 		07/06/2024
Author: 	Nishant Yonzan
Email:  	nyonzan@worldbank.org
Purpose: 	Inequality measures: Applied session I
			Estimation of common inequality measures.
*/
********************************************************************************

******************
*** INPUT DATA ***
******************

use "${workshop}Workshop_Example_Data.dta", clear

******************************
*** 0. INITIAL DATA CHECKS ***
******************************

describe

sort year
by year: count if missing(gross_totinc_hh)

by year: count if gross_totinc_hh < 0

by year: count if gross_totinc_hh == 0

by year: count if gross_totinc_hh > 0 & gross_totinc_hh < 1


// summary statistics 

summarize net_totinc_hh [aw=weight] if year == 1, detail

summarize net_totinc_hh [aw=weight] if year == 2, detail

bys year: summarize net_totinc_hh [aw=weight], detail

bys year: summarize wages_hh [aw=weight], detail


// some basic summary statistics (CV = SD/mean; p90/p10)

qui summarize gross_totinc_hh if year == 1, detail
local cv_1 = r(sd)/r(mean)
local r9010_1 = r(p90)/r(p10)

qui summarize gross_totinc_hh if year == 2, detail
local cv_2 = r(sd)/r(mean)
local r9010_2 = r(p90)/r(p10)

di `cv_1'
di `cv_2'

di `r9010_1'
di `r9010_2'


********************************
*** 1. INEQUALITY STATISTICS ***
********************************

// Income shares using sum dist

use "${workshop}Workshop_Example_Data.dta", clear

sumdist net_totinc_hh [aw = weight] if year == 1

sumdist net_totinc_hh [aw = weight] if year == 1, ng(5)

sumdist net_totinc_hh [aw = weight] if year == 2, ng(5)


// Lorenz curve 

use "${workshop}Workshop_Example_Data.dta", clear

sumdist net_totinc_hh [aw = weight] if year == 1, ng(5) lvar(l) 
keep if !missing(l)
keep l
sort l
gen q = _n -1
gen pop_share = 0.2 if q>0
replace pop_share = 0 in 1
replace pop_s = pop_share + pop_share[_n-1] if _n>1

twoway line l pop_s 

twoway line l pop_s || line l l, ///
	legend(pos(6) order(1 "Lorenz curve" 2 "Line of perfect equality"))


// Charts can be easy to understand and very informative

use "${workshop}Workshop_Example_Data.dta", clear

kdensity net_totinc_hh [aw=weight] if year == 1, generate(x1 fx1) nograph
kdensity net_totinc_hh [aw=weight] if year == 2, generate(x2 fx2) nograph
label var x1 "Year 1"
label var x2 "Year 2"
graph twoway (line fx1 x1, sort) (line fx2 x2, sort), /// 
	ytitle("Density") xtitle("Net Income") legend(ring(0) pos(2) row(2) order(1 "Year 1" 2 "Year 2"))
	
	
gen ln_inc = ln(net_totinc_hh)													// using log helps with visualization
kdensity ln_inc [aw=weight] if year == 1, generate(lx1 flx1) nograph
kdensity ln_inc [aw=weight] if year == 2, generate(lx2 flx2) nograph
label var lx1 "Year 1"
label var lx2 "Year 2"
graph twoway (line flx1 lx1, sort) (line flx2 lx2, sort), /// 
	ytitle("Density") xtitle("Log net Income") legend(ring(0) pos(2) row(2) order(1 "Year 1" 2 "Year 2"))	
	

******************************************
*** 2. USEFUL STATA ADO FOR INEQUALITY ***
******************************************

// ineqdeco / ineqdec0 	

use "${workshop}Workshop_Example_Data.dta", clear

ineqdeco net_totinc_hh [w = weight] if year == 1								// simple syntax; check ereturn and return stored lists				

encode ethnic, gen(ethnic_id)													// inequality estimates by group and overall 

ineqdeco net_totinc_hh [w = weight] if year == 2, by(ethnic_id)


*** Exercise 1 ***
/*
a. Estimate the Gini index for net total income using per capita household income.

b. Estimate the Gini index for wages with and without using zeros. (Hint: ineqdeco does not add zero.)
*/


// Gini index, add standard errors

fastgini net_totinc_hh [w = weight] if year == 2, jk


// lorenz curve

lorenz net_totinc_hh [w = weight] if year == 2
lorenz graph

lorenz net_totinc_hh [w = weight] if year == 2, gini							// to report the gini


*** Excercise 2 *** 
/*
a. What is the share of income held by the top 10% each year? Did it increase or decrease? What is the percent increase/decrease?

b. What are the p90/p50 ratios in the two years?

c. What are the mean log deviations in the two years

d. Estimate the Gini coefficient including zeros for the net and gross income variables.

e. Generate and plot a Lorenz curve for gross income variable and the net income variable.		
*/

************************************************
*** 3. QUANTILES OF THE DISTRIBUTION AND GIC ***
************************************************

use "${workshop}Workshop_Example_Data.dta", clear

xtile decile_yr1 = net_totinc_hh [w=weight] if year == 1

xtile decile_yr2 = net_totinc_hh [w=weight] if year == 2, nquantile(10) 		// nquantile specifies the number of quantiles

egen decile = xtile(net_totinc_hh), weight(weight) by(year)						// by allows one to bin the data by groups

egen decile_ethnic = xtile(net_totinc_hh), weight(weight) by(year ethnic)		// grouping by ethnic group each year


tabstat net_totinc_hh [w=weight], by(decile_yr1) stat(mean p50)					// check to see both approaches xtile and xtile with egen give same result

tabstat net_totinc_hh [w=weight] if year==1, by(decile) stat(mean p50)

tabstat net_totinc_hh [w=weight] if year==2, by(decile_yr2) stat(mean p50)		// decile with 10 quantiles

bys ethnic: tabstat net_totinc_hh [w=weight] if year==2, by(decile) stat(mean p50)	// by ethnic groups


// percentile for GIC 

egen percentile = xtile(net_totinc_hh), weight(weight) by(year ethnic) nq(100)

collapse net_totinc_hh [w=weight], by(year ethnic percentile)

bys year: tab ethnic															// check to see if there are 100 percentiles by each ethnic group

reshape wide net_totinc_hh, i(ethnic percentile) j(year)						// reshape data to easily calculate growth statistics

gen annualgrowth = ((net_totinc_hh2/net_totinc_hh1)^(1/(2-1)) - 1 ) * 100		// annualized growth rate

twoway 	connected annualgrowth percentile if ethnic=="group 1" || ///
		connected annualgrowth percentile if ethnic=="group 2" || ///
		connected annualgrowth percentile if ethnic=="group 3" , ///
		legend(ring(0) pos(2) row(3) order(1 "Ethnic grop A" 2 "Ethnic group B" 3 "Ethnic group C"))
		
		
// Data might be noisy or have many zero values so growth rates might not be reasonable		

use "${workshop}Workshop_Example_Data.dta", clear

egen percentile = xtile(wages_hh), weight(weight) by(year ethnic) nq(100)

collapse wages_hh [w=weight], by(year ethnic percentile)

bys year: tab ethnic															// check to see if there are 100 percentiles by each ethnic group

reshape wide wages_hh, i(ethnic percentile) j(year)						// reshape data to easily calculate growth statistics

gen annualgrowth = ((wages_hh2/wages_hh1)^(1/(2-1)) - 1 ) * 100

twoway 	connected annualgrowth percentile if ethnic=="group 1" || ///
		connected annualgrowth percentile if ethnic=="group 2" || ///
		connected annualgrowth percentile if ethnic=="group 3" , ///
		ylabel() legend(ring(0) pos(2) row(3) order(1 "Ethnic A" 2 "Ethnic B" 3 "Ethnic C")) ///
		name(wages_all, replace)


// look at the population with positive wages only	
	
use "${workshop}Workshop_Example_Data.dta", clear

keep if wages_hh > 0															// keep only positive wages

egen percentile = xtile(wages_hh), weight(weight) by(year ethnic) nq(100)

collapse wages_hh [w=weight], by(year ethnic percentile)

bys year: tab ethnic															// check to see if there are 100 percentiles by each ethnic group

reshape wide wages_hh, i(ethnic percentile) j(year)								// reshape data to easily calculate growth statistics

gen annualgrowth = ((wages_hh2/wages_hh1)^(1/(2-1)) - 1 ) * 100

twoway 	connected annualgrowth percentile if ethnic=="group 1" || ///
		connected annualgrowth percentile if ethnic=="group 2" || ///
		connected annualgrowth percentile if ethnic=="group 3" , ///
		ylabel() legend(ring(0) pos(2) row(3) order(1 "Ethnic A" 2 "Ethnic B" 3 "Ethnic C")) ///
		name(wages_positive, replace)
		

*** Excercise 3 *** 
/*
a. Generate and plot a GIC for gross income variable and compare it with the net income variable.		
*/		
********************************************************************************
exit