																																																																																																																																																																					*** summary statistics/demographics

cd /Users/ranciere/Dropbox/capitalism_aversion/data_survey

use numeric, clear

gen cohort = "18-23" if age >= 18 & age <= 23
replace cohort = "24-29" if age >= 24 & age <= 29
replace cohort = "30-39" if age >= 30 & age <= 39
replace cohort = "40-49" if age >= 40 & age <= 49
replace cohort = "50-59" if age >= 50 & age <= 59
replace cohort = "60-69" if age >= 60 & age <= 69
replace cohort = "70+" if age >= 70

gen generation = "gen z" if age < 29
replace generation = "millenial" if age >= 29 & age <= 44
replace generation = "gen x" if age >= 45 & age <= 60
replace generation = "baby boomer" if age >= 61 & age <= 79
replace generation = "silent" if age >= 80

display _N // 2415 total responses
tab flag // 7% flagged by bot checks (but a large majority responded to a follow-up message)
tab cohort // 21% 18-23, 30% 24-29, 11% 30-39, 10% 40-49, 10% 50-59, 10% 60-69, 8% 70+
tab generation // 45% gen z, 22% millenial, 16% gen x, 15% boomer 
summarize vote2024* if age < 30 // 49% voted harris, 26% voted trump
summarize vote2024* if age >= 30  // 43% voted harris, 50% voted trump
tab liberalsocial if age < 30 // socially, 52% liberal 20% conservative
tab liberalecon if age < 30 // economically, 47% liberal 23% conservative
tab liberalsocial if age >= 30 // socially, 40% liberal 37% conservative
tab liberalecon if age >= 30 // economically, 33% liberal 40% conservative
tab progressivity if age < 30 // 83% believe taxes should be more progressive
tab progressivity if age >= 30 // 72% believe taxes should be more progressive
tab proposal if age < 30 // 79% support proposal
tab proposal if age >= 30 // 72% support proposal
tab density // 16% rural 56% suburban 31% urban
tab student if student == 0 & age < 30 // 59% students
tab usborn // 28% immigrant parent
summ job* // 10% unemployed (unemp/(full+part+self))
tab edu // 17% have not attended college, 68% have attended only 2/4-year college, 12% have masters, 3% have research/professional doctorates
tab eduplan // 11% plan no college, 53% plan 2/4-year college, 23% plan masters, 13% plan research/professional doctorates
summ race* // 69% white, 15% black, 13% latino, 8% asian, 2% american indian, 1% middle east, <1% islander, 1% other
summ male female // 49% male 49% female
summ married if age < 30 // 17% young married
summ married if age >= 30 // 44% old married

***transform in indicator function

foreach var of varlist view*  male female nonbinary race* job*  {
	replace `var'=0 if `var'==.
}



 g riskhome2=riskhome if riskhome!=1
 g high_risk=1 if riskhome2==5
 replace high_risk=0 if riskhome2<5

 
 sort cohort
 egen cohortgroup=group(cohort)
 sort cohortgroup
 
  gen young=1 if cohortgroup<3
 replace young=0 if  cohortgroup>2
 sort young
 
 
 
 **REDUX
 
 ologit shouldconcern  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow stranger100  worriedjob riskclimate safetynet  eduwillpay  density male if flag!=1 , or 

 ologit progressivity  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow riskclimate fiveyr1500 density satisfiedbasics if flag!=1 , or 

 ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 , or 

 **BASELINE REGRESSION
* Estimate models
* Model 1: All
ologit shouldconcern  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow stranger100  worriedjob riskclimate safetynet  eduwillpay  density male if flag!=1 , or 
eststo m1
estadd scalar pr2 = e(r2_p)

reg shouldconcern  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow stranger100  worriedjob riskclimate safetynet  eduwillpay  density male if flag!=1 , 
predict shouldconcernpred

* Model 2: Young
ologit shouldconcern  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow stranger100  worriedjob riskclimate safetynet  eduwillpay  density male if flag!=1 & young==1, or 
 
eststo m2
estadd scalar pr2 = e(r2_p)

* Model 3: Old
ologit shouldconcern  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow stranger100  worriedjob riskclimate safetynet  eduwillpay  density male if flag!=1 & young==0, or 

eststo m3
estadd scalar pr2 = e(r2_p)

* Export results to LaTeX
esttab m1 m2 m3 using "tables/shouldconcern.tex", ///
    title("Should Concern (ologit regression)- Odds Ratios") ///
    mtitles("All" "Young" "Old") ///
    stats(N pr2, labels("Observations" "Pseudo R²")) ///
    drop(cut*) ///
	   eform ///
    booktabs replace se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)

	
	
eststo clear

reg progressivity  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow riskclimate fiveyr1500 density satisfiedbasics if flag!=1 
predict progressivitypred

	
ologit progressivity  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow riskclimate fiveyr1500 density satisfiedbasics if flag!=1 , or 
eststo m1
estadd scalar pr2 = e(r2_p)
 
ologit progressivity  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow riskclimate fiveyr1500 density satisfiedbasics if flag!=1 & young==1, or 
eststo m2
estadd scalar pr2 = e(r2_p)
 
 
ologit progressivity  zerosumrich zerosumceo zerosumdei  taxdemotivates gapmotivates workhaspaid moveupnow riskclimate fiveyr1500 density satisfiedbasics if flag!=1 & young==0, or 
eststo m3
estadd scalar pr2 = e(r2_p)

esttab m1 m2 m3 using "tables/progressivity.tex", ///
    title("Progressivity (ologit regression)- Odds Ratios") ///
    mtitles("All" "Young" "Old") ///
    stats(N pr2, labels("Observations" "Pseudo R²")) ///
    drop(cut*) ///
	   eform ///
    booktabs replace se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)
	
	
/*
	
eststo clear
ologit viewchange taxdemotivates gapmotivates zerosumrich zerosumceo zerosumdei eduplan compmoth stranger* current* fiveyr1500 male satisf* liberalecon	
eststo m1
estadd scalar pr2 = e(r2_p)		Ω

ologit viewchange taxdemotivates gapmotivates zerosumrich zerosumceo zerosumdei eduplan compmoth stranger* current* fiveyr1500 male satisf* liberalecon	if young==1
eststo m2
estadd scalar pr2 = e(r2_p)

ologit viewchange taxdemotivates gapmotivates zerosumrich zerosumceo zerosumdei eduplan compmoth stranger* current* fiveyr1500 male satisf* liberalecon	if young==0
eststo m3
estadd scalar pr2 = e(r2_p)	


esttab m1 m2 m3 using "viewchange.tex", ///
    title("View Change (ologit regression)") ///
    mtitles("All" "Young" "Old") ///
    stats(N pr2, labels("Observations" "Pseudo R²")) ///
    drop(cut*) ///
    booktabs replace se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)
	
		
*/

reg proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1
predict proposalpred

eststo clear
 
ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 , or 
 eststo m1
  estadd scalar pr2 = e(r2_p)

ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 & young==1, or 
 eststo m2
estadd scalar pr2 = e(r2_p)

ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 & young==0 , or 
 eststo m3
estadd scalar pr2 = e(r2_p)



esttab m1 m2 m3 using "tables/proposal1.tex", ///
    title("Proposal (ologit regression)-- Odds Ratios") ///
    mtitles("All" "Young" "Old") ///
    stats(N pr2, labels("Observations" "Pseudo R²")) ///
    drop(cut*) ///
	   eform ///
    booktabs replace se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)
	


eststo clear
 
 ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 , or 
 eststo m1
  estadd scalar pr2 = e(r2_p)

ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 & poor==1, or 
 eststo m2
estadd scalar pr2 = e(r2_p)

ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 & middle==1 , or 
 eststo m3
estadd scalar pr2 = e(r2_p)

ologit proposal zerosumrich zerosumceo zerosumdei  taxdemotivates stranger100 riskclimate eduwillpay density male if flag!=1 & both==1 , or 
 eststo m4
estadd scalar pr2 = e(r2_p)
esttab m1 m2 m3 m4 using "tables/proposal2.tex", ///
    title("Proposal (Ordered Logit, Odds Ratios)") ///
    mtitles("All" "Poor" "Middle" "Both") ///
    stats(N pr2, labels("Observations" "Pseudo R²")) ///
    drop(cut*) ///
    eform ///
    booktabs replace se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)
  
 */ 
 
 /*
 
 ****************************************************
* Run t-tests for many variables and export results
****************************************************

* Define a temporary file to collect results
tempfile results

* Open a postfile handle (named myhandle here)
postfile myhandle str32 varname double(tstat pvalue mean0 mean1) using `results', replace

* Loop over your variables
foreach var of varlist shouldconcern progressivity proposal taxdemotivates gapmotivates fundedu protecttrade cuttaxes univhealth wealthtax zerosumrich zerosumceo zerosumwomen zerosumdei moveup20 moveup50 moveupnow workhaspaid workwillpay eduwillpay stranger100 friend100 oneyr1100 oneyr1500 oneyr2000 fiveyr1100 fiveyr1500 fiveyr2000 currentdesires satisfiedbasics startbiz stableincome worriedjob similarjob safetynet riskai riskclimate riskhealth riskhome* {
    
    quietly ttest `var', by(young)

    * Grab results
    local tstat  = r(t)
    local pvalue = r(p)
    local mean0  = r(mu_1)
    local mean1  = r(mu_2)

    * Write results into postfile
    post myhandle ("`var'") (`tstat') (`pvalue') (`mean0') (`mean1')
}

* Close the postfile
postclose myhandle

* Bring results into memory
use `results', clear

* Export to CSV
export delimited using "ttest_results.csv", replace

*/


/*
 
 collapse (mean) shouldconcern-usborn homedensity-biasright  riskhome2-high_risk ,  by(young)
 
foreach var of varlist shouldconcern progressivity proposal taxdemotivates gapmotivates fundedu protecttrade cuttaxes univhealth wealthtax zerosumrich zerosumceo zerosumwomen zerosumdei moveup20 moveup50 moveupnow workhaspaid workwillpay eduwillpay stranger100 friend100 oneyr1100 oneyr1500 oneyr2000 fiveyr1100 fiveyr1500 fiveyr2000 currentdesires satisfiedbasics startbiz stableincome worriedjob similarjob safetynet riskai riskclimate riskhealth riskhome*  {
    quietly graph bar `var', over(young) blabel(bar, format(%9.0g)) title("`var' by young/old")
    graph export "`var'.png", replace
}

*/



****create new variables

g proposal_poor= proposal if poor==1
g proposal_middle=proposal if middle==1
g proposal_both=proposal if both==1



* First, preserve original data in case we collapse it
preserve



* Loop through all variables
foreach var of varlist shouldconcern* progressivity* proposal* viewchange taxdemotivates gapmotivates fundedu protecttrade cuttaxes univhealth wealthtax zerosumrich zerosumceo zerosumwomen zerosumdei moveup20 moveup50 moveupnow workhaspaid workwillpay eduwillpay stranger100 friend100 oneyr1100 oneyr1500 oneyr2000 fiveyr1100 fiveyr1500 fiveyr2000 currentdesires satisfiedbasics startbiz stableincome worriedjob similarjob safetynet riskai riskclimate riskhealth riskhome* {

    * Collapse to mean and SE by group
    collapse (mean) mean_`var'=`var' (semean) se_`var'=`var', by(cohortgroup)

    * Compute upper and lower bounds (mean ± 1 SE)
    gen upper_`var' = mean_`var' +2* se_`var'
    gen lower_`var' = mean_`var' -2* se_`var'

    * Bar plot with error bars
    twoway (bar mean_`var' cohortgroup, barwidth(0.6) color(navy)) ///
           (rcap upper_`var' lower_`var' cohortgroup, lwidth(medthick)), ///
           title("`var' by cohortgroup (±2 SE)") ///
           ytitle("Mean ±2 SE") ///
           legend(off)

    graph export "`var'_sebar.png", replace

    * Restore original data for next loop
    restore
    preserve
}

restore


***income analysis

*on obs with absurd hign income
drop if pinc>=10000000
drop if pinc10est>=10000000
drop if pinc10high>=10000000
drop if pinc10low>=10000000
g pinc10HL=pinc10high-pinc10low
drop if pinc10HL<0

foreach var of varlist pinc pinc10est pinc10high pinc10low{
	g ln_`var'=ln(`var')
}
g ln_pinc10HL=ln(pinc10HL) if pinc10HL>0
