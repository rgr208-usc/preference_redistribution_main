
**** cleaning raw data from Qualtrics
**** creator: Niclas Carlson, niclasccarlson@gmail.com
**** creates a dataset with responses as text and a dataset with responses coded numerically,
**** then looks at some summary statistics of the dataset



*** first, make text dataset

cd /Users/niclascarlson/Desktop/youth-views/survey/analysis

import delimited data/raw.csv, clear

save data/raw, replace


** merge with flagged responses (low recaptcha, failed signature box test, or returned on prolific)

import excel data/flagged.xlsx, sheet("main") firstrow case(lower) clear

keep prolificid flagstatus badsig 

gen flag = 1

* drop rejected or returned submissions
drop if flag == 1 & inlist(flagstatus, "", "rejected")
drop flagstatus

// replace returned = "1" if returned == "y"
replace badsig = "1" if badsig == "y"
destring badsig, replace

joinby prolificid using data/raw, unmatched(both)


** trim sample

* drop unfinished responses
drop if progress < 100

* drop previews (test responses)
drop if responsetype == "Survey Preview"

* drop opt-outs
drop if optin == "No, I do not wish to participate or do not meet the eligibility criteria."

* variables not used in analysis
drop _merge timeend timerecorded responsetype ipaddress progress finished responseid lastname firstname email externaldata latitude longitude distribution language optin signature* prolificid_resp 

order prolificid timestart duration flag badsig recaptcha

sort timestart


** merge tax proposal variables

* indicator for randomly assigned group
gen proposal_group = "poor" if poorbenefit != ""
replace proposal_group = "middle" if middlebenefit != ""
replace proposal_group = "both" if bothbenefit != ""

* merge responses into one vairable
replace poorbenefit = middlebenefit if poorbenefit == ""
replace poorbenefit = bothbenefit if poorbenefit == ""
rename poorbenefit proposal
drop middlebenefit bothbenefit

order proposal proposal_group, after(viewworse_oth)


** merge progressivity of taxation variable

replace progressivity_early = progressivity_late if progressivity_early == ""
drop progressivity_late
rename progressivity_early progressivity

order progressivity_timing, after(progressivity)


** final dataset with responses as text

order progressivity_timing, after(progressivity)

save data/text, replace
export delimited data/text, replace



**** second, make numeric dataset

** indicator variables

use data/text, clear

* change in views about redistribution
gen viewbetter_tax = 1 if strpos(viewbetter, "Taxes affect me less now")
gen viewbetter_econ = 1 if strpos(viewbetter, "I think the policy is better for the economy now")
gen viewbetter_fair = 1 if strpos(viewbetter, "I think the policy is more fair now")
drop viewbetter_oth
gen viewbetter_oth = 1 if strpos(viewbetter, "Other")
drop viewbetter
order viewbetter_tax viewbetter_econ viewbetter_fair viewbetter_oth, after(viewchange_oth)

gen viewworse_tax = 1 if strpos(viewworse, "Taxes affect me more now")
gen viewworse_econ = 1 if strpos(viewworse, "I think the policy is worse for the economy now")
gen viewworse_fair = 1 if strpos(viewworse, "I think the policy is less fair now")
drop viewworse_oth
gen viewworse_oth = 1 if strpos(viewworse, "Other")
drop viewworse
order viewworse_tax viewworse_econ viewworse_fair viewworse_oth, after(viewbetter_oth)

* race
gen race_indian = 1 if strpos(race, "American Indian or Alaska Native")
gen race_asian = 1 if strpos(race, "Asian or Asian American")
gen race_black = 1 if strpos(race, "Black or African American")
gen race_latino = 1 if strpos(race, "Hispanic or Latino")
gen race_mideast = 1 if strpos(race, "Middle Eastern or North African")
gen race_island = 1 if strpos(race, "Native Hawaiian or Pacific Islander")
gen race_white = 1 if strpos(race, "White or European American")
drop race_oth
gen race_oth = 1 if strpos(race, "Other")
drop race
order race*, after(childrenplan)

* voting
gen vote2024_harris = 1 if strpos(vote2024, "Kamala Harris")
gen vote2024_trump = 1 if strpos(vote2024, "Donald Trump")
gen vote2024_oth = 1 if strpos(vote2024, "Other")
drop vote2024
order vote2024_harris vote2024_trump vote2024_oth, after(ideolsocial)

gen vote2020_biden = 1 if strpos(vote2020, "Joe Biden")
gen vote2020_trump = 1 if strpos(vote2020, "Donald Trump")
gen vote2020_oth = 1 if strpos(vote2020, "Other")
drop vote2020
order vote2020_biden vote2020_trump vote2020_oth, after(vote2024_oth)

* gender
gen male = 1 if gender == "Male"
gen female = 1 if gender == "Female"
gen nonbinary = 1 if gender == "Non-binary / third gender"
drop gender
order male female nonbinary, after(riskhome)

* marital status
gen married = 1 if marital == "Married"
gen cohab = 1 if marital == "Cohabitating" 
gen single = 1 if marital == "Single"
drop marital marital_oth
order married cohab single, after(nonbinary)

* progressivity timing
gen early = 1 if progressivity_timing == "early"
gen late = 1 if progressivity_timing == "late"
drop progressivity_timing
order early late, after(progressivity)

* tax proposal group
gen poor = 1 if proposal_group == "poor"
gen middle = 1 if proposal_group == "middle"
gen both = 1 if proposal_group == "both"
drop proposal_group
order poor middle both, after(proposal)

* survey bias
gen biasleft = 1 if surveybias == "Left-wing biased"
gen biasright = 1 if surveybias == "Right-wing biased"
drop surveybias
order biasleft biasright, after(vote2020_oth)

* employment
gen jobfull = 1 if employment == "Full-time employee"
gen jobpart = 1 if employment == "Part-time employee"
gen jobself = 1 if employment == "Self-employed or small business owner"
gen jobstud = 1 if employment == "Student"
gen jobnilf = 1 if employment == "Not in the labor force (for example: retired, or full-time parent)"
gen jobunemp = 1 if employment == "Unemployed and looking for work"
drop employment
order job*, after(edufath)

* NOTE: could code "Other" responses into categories (views change/better/worse, race, marital)

save data/temp/indicators, replace


** text formatting

use data/temp/indicators, clear

replace safetynet = "3-6 months" if safetynet == "3‚Äì6 months"
replace safetynet = "1-3 months" if safetynet == "1‚Äì3 months"


** scaling/numerically coding variables

replace shouldconcern = "1" if shouldconcern == "The government should concern itself with this."
replace shouldconcern = "0" if shouldconcern == "The government should not concern itself with this."

replace progressivity = "5" if progressivity == "Much more progressive (lower earners should pay a lot less than they do now and higher earners should pay a lot more than they do now)"
replace progressivity = "4" if progressivity == "Somewhat more progressive"
replace progressivity = "3" if progressivity == "No change"
replace progressivity = "2" if progressivity == "Somewhat less progressive"
replace progressivity = "1" if progressivity == "Much less progressive (everyone should be taxed at about the same rate)"

replace viewchange = "5" if viewchange == "I now support redistribution much more than in the past"
replace viewchange = "4" if viewchange == "I now support redistribution slightly more than in the past"
replace viewchange = "3" if viewchange == "No change"
replace viewchange = "2" if viewchange == "I now support redistribution slightly less than in the past"
replace viewchange = "1" if viewchange == "I now support redistribution much less than in the past"
replace viewchange = "0" if viewchange == "Other:"
* THE OTHER here could be -1

replace proposal = "7" if proposal == "Support strongly"
replace proposal = "6" if proposal == "Support moderately"
replace proposal = "5" if proposal == "Support slightly"
replace proposal = "4" if proposal == "Indifferent"
replace proposal = "3" if proposal == "Reject slightly"
replace proposal = "2" if proposal == "Reject moderately"
replace proposal = "1" if proposal == "Reject strongly"

replace taxdemotivates = "5" if taxdemotivates == "Agree strongly"
replace taxdemotivates = "4" if taxdemotivates == "Agree somewhat"
replace taxdemotivates = "3" if taxdemotivates == "Neutral"
replace taxdemotivates = "2" if taxdemotivates == "Disagree somewhat"
replace taxdemotivates = "1" if taxdemotivates == "Disagree strongly"
replace taxdemotivates = "-1" if taxdemotivates == "Unsure"

replace gapmotivates = "5" if gapmotivates == "Agree strongly"
replace gapmotivates = "4" if gapmotivates == "Agree somewhat"
replace gapmotivates = "3" if gapmotivates == "Neutral"
replace gapmotivates = "2" if gapmotivates == "Disagree somewhat"
replace gapmotivates = "1" if gapmotivates == "Disagree strongly"
replace gapmotivates = "-1" if gapmotivates == "Unsure"

replace fundedu = "5" if fundedu == "Agree strongly"
replace fundedu = "4" if fundedu == "Agree somewhat"
replace fundedu = "3" if fundedu == "Indifferent"
replace fundedu = "2" if fundedu == "Disagree somewhat"
replace fundedu = "1" if fundedu == "Disagree strongly"
replace fundedu = "-1" if fundedu == "Unsure"

replace protecttrade = "5" if protecttrade == "Agree strongly"
replace protecttrade = "4" if protecttrade == "Agree somewhat"
replace protecttrade = "3" if protecttrade == "Indifferent"
replace protecttrade = "2" if protecttrade == "Disagree somewhat"
replace protecttrade = "1" if protecttrade == "Disagree strongly"
replace protecttrade = "-1" if protecttrade == "Unsure"

replace cuttaxes = "5" if cuttaxes == "Agree strongly"
replace cuttaxes = "4" if cuttaxes == "Agree somewhat"
replace cuttaxes = "3" if cuttaxes == "Indifferent"
replace cuttaxes = "2" if cuttaxes == "Disagree somewhat"
replace cuttaxes = "1" if cuttaxes == "Disagree strongly"
replace cuttaxes = "-1" if cuttaxes == "Unsure"

replace univhealth = "5" if univhealth == "Agree strongly"
replace univhealth = "4" if univhealth == "Agree somewhat"
replace univhealth = "3" if univhealth == "Indifferent"
replace univhealth = "2" if univhealth == "Disagree somewhat"
replace univhealth = "1" if univhealth == "Disagree strongly"
replace univhealth = "-1" if univhealth == "Unsure"

replace wealthtax = "5" if wealthtax == "Agree strongly"
replace wealthtax = "4" if wealthtax == "Agree somewhat"
replace wealthtax = "3" if wealthtax == "Indifferent"
replace wealthtax = "2" if wealthtax == "Disagree somewhat"
replace wealthtax = "1" if wealthtax == "Disagree strongly"
replace wealthtax = "-1" if wealthtax == "Unsure"

replace zerosumrich = "5" if zerosumrich == "Agree strongly"
replace zerosumrich = "4" if zerosumrich == "Agree somewhat"
replace zerosumrich = "3" if zerosumrich == "Neutral"
replace zerosumrich = "2" if zerosumrich == "Disagree somewhat"
replace zerosumrich = "1" if zerosumrich == "Disagree strongly"
replace zerosumrich = "-1" if zerosumrich == "Unsure"

replace zerosumceo = "5" if zerosumceo == "Agree strongly"
replace zerosumceo = "4" if zerosumceo == "Agree somewhat"
replace zerosumceo = "3" if zerosumceo == "Neutral"
replace zerosumceo = "2" if zerosumceo == "Disagree somewhat"
replace zerosumceo = "1" if zerosumceo == "Disagree strongly"
replace zerosumceo = "-1" if zerosumceo == "Unsure"

replace zerosumwomen = "5" if zerosumwomen == "Agree strongly"
replace zerosumwomen = "4" if zerosumwomen == "Agree somewhat"
replace zerosumwomen = "3" if zerosumwomen == "Neutral"
replace zerosumwomen = "2" if zerosumwomen == "Disagree somewhat"
replace zerosumwomen = "1" if zerosumwomen == "Disagree strongly"
replace zerosumwomen = "-1" if zerosumwomen == "Unsure"

replace zerosumdei = "5" if zerosumdei == "Agree strongly"
replace zerosumdei = "4" if zerosumdei == "Agree somewhat"
replace zerosumdei = "3" if zerosumdei == "Neutral"
replace zerosumdei = "2" if zerosumdei == "Disagree somewhat"
replace zerosumdei = "1" if zerosumdei == "Disagree strongly"
replace zerosumdei = "-1" if zerosumdei == "Unsure"

replace moveup20 = "5" if moveup20 == "Almost guaranteed (80-100%)"
replace moveup20 = "4" if moveup20 == "Likely (60-80%)"
replace moveup20 = "3" if moveup20 == "Even chance (40-60%)"
replace moveup20 = "2" if moveup20 == "Unlikely (20-40%)"
replace moveup20 = "1" if moveup20 == "Almost no chance (0-20%)"
replace moveup20 = "-1" if moveup20 == "Unsure"

replace moveup50 = "5" if moveup50 == "Almost guaranteed (80-100%)"
replace moveup50 = "4" if moveup50 == "Likely (60-80%)"
replace moveup50 = "3" if moveup50 == "Even chance (40-60%)"
replace moveup50 = "2" if moveup50 == "Unlikely (20-40%)"
replace moveup50 = "1" if moveup50 == "Almost no chance (0-20%)"
replace moveup50 = "-1" if moveup50 == "Unsure"

replace moveupnow = "5" if moveupnow == "Much easier now"
replace moveupnow = "4" if moveupnow == "Somewhat easier now"
replace moveupnow = "3" if moveupnow == "No change"
replace moveupnow = "2" if moveupnow == "Somewhat harder now"
replace moveupnow = "1" if moveupnow == "Much harder now"
replace moveupnow = "-1" if moveupnow == "Unsure"

replace workhaspaid = "3" if workhaspaid == "It has paid off a lot"
replace workhaspaid = "2" if workhaspaid == "It has paid off somewhat"
replace workhaspaid = "1" if workhaspaid == "It has not paid off much"
replace workhaspaid = "-1" if workhaspaid == "Unsure"

replace workwillpay = "3" if workwillpay == "It will pay off a lot"
replace workwillpay = "2" if workwillpay == "It will pay off somewhat"
replace workwillpay = "1" if workwillpay == "It will not pay off much"
replace workwillpay = "-1" if workwillpay == "Unsure"

replace eduwillpay = "3" if eduwillpay == "It will pay off a lot"
replace eduwillpay = "2" if eduwillpay == "It will pay off somewhat"
replace eduwillpay = "1" if eduwillpay == "It will not pay off much"
replace eduwillpay = "-1" if eduwillpay == "Unsure"

replace compmoth = "5" if compmoth == "Far above average"
replace compmoth = "4" if compmoth == "Above average"
replace compmoth = "3" if compmoth == "Average"
replace compmoth = "2" if compmoth == "Below average"
replace compmoth = "1" if compmoth == "Far below average"
replace compmoth = "-1" if compmoth == "Unsure / Not applicable"

replace compfath = "5" if compfath == "Far above average"
replace compfath = "4" if compfath == "Above average"
replace compfath = "3" if compfath == "Average"
replace compfath = "2" if compfath == "Below average"
replace compfath = "1" if compfath == "Far below average"
replace compfath = "-1" if compfath == "Unsure / Not applicable"

replace compfam = "5" if compfam == "Far above average"
replace compfam = "4" if compfam == "Above average"
replace compfam = "3" if compfam == "Average"
replace compfam = "2" if compfam == "Below average"
replace compfam = "1" if compfam == "Far below average"
replace compfam = "-1" if compfam == "Unsure"

replace compper = "5" if compper == "Far above average"
replace compper = "4" if compper == "Above average"
replace compper = "3" if compper == "Average"
replace compper = "2" if compper == "Below average"
replace compper = "1" if compper == "Far below average"
replace compper = "-1" if compper == "Unsure"

replace nohh = "1" if nohh == "Yes"
replace nohh = "0" if nohh == "No, someone else also earns income"

replace hhin10 = "1" if hhin10 == "Yes, more than one person"
replace hhin10 = "0" if hhin10 == "No, just myself"

replace pinc10cert = "3" if pinc10cert == "Very certain"
replace pinc10cert = "2" if pinc10cert == "Somewhat certain"
replace pinc10cert = "1" if pinc10cert == "Not very certain"

replace hhinc10cert = "3" if hhinc10cert == "Very certain"
replace hhinc10cert = "2" if hhinc10cert == "Somewhat certain"
replace hhinc10cert = "1" if hhinc10cert == "Not very certain"

replace child30s = "1" if child30s == "Will have children"
replace child30s = "0" if child30s == "Will not have children"

replace child40s = "1" if child40s == "Will have children"
replace child40s = "0" if child40s == "Will not have children"

replace stranger100 = "10" if stranger100 == "$91-$100"
replace stranger100 = "9" if stranger100 == "$81-$90"
replace stranger100 = "8" if stranger100 == "$71-$80"
replace stranger100 = "7" if stranger100 == "$61-$70"
replace stranger100 = "6" if stranger100 == "$51-$60"
replace stranger100 = "5" if stranger100 == "$41-$50"
replace stranger100 = "4" if stranger100 == "$31-$40"
replace stranger100 = "3" if stranger100 == "$21-$30"
replace stranger100 = "2" if stranger100 == "$11-$20"
replace stranger100 = "1" if stranger100 == "$0-$10"

replace friend100 = "10" if friend100 == "$91-$100"
replace friend100 = "9" if friend100 == "$81-$90"
replace friend100 = "8" if friend100 == "$71-$80"
replace friend100 = "7" if friend100 == "$61-$70"
replace friend100 = "6" if friend100 == "$51-$60"
replace friend100 = "5" if friend100 == "$41-$50"
replace friend100 = "4" if friend100 == "$31-$40"
replace friend100 = "3" if friend100 == "$21-$30"
replace friend100 = "2" if friend100 == "$11-$20"
replace friend100 = "1" if friend100 == "$0-$10"

replace oneyr1100 = "2" if oneyr1100 == "$1,100 in 1 year"
replace oneyr1100 = "1" if oneyr1100 == "Indifferent"
replace oneyr1100 = "0" if oneyr1100 == "$1,000 today"

replace oneyr1500 = "2" if oneyr1500 == "$1,500 in 1 year"
replace oneyr1500 = "1" if oneyr1500 == "Indifferent"
replace oneyr1500 = "0" if oneyr1500 == "$1,000 today"

replace oneyr2000 = "2" if oneyr2000 == "$2,000 in 1 year"
replace oneyr2000 = "1" if oneyr2000 == "Indifferent"
replace oneyr2000 = "0" if oneyr2000 == "$1,000 today"

replace fiveyr1100 = "2" if fiveyr1100 == "$1,100 in 5 years"
replace fiveyr1100 = "1" if fiveyr1100 == "Indifferent"
replace fiveyr1100 = "0" if fiveyr1100 == "$1,000 today"

replace fiveyr1500 = "2" if fiveyr1500 == "$1,500 in 5 years"
replace fiveyr1500 = "1" if fiveyr1500 == "Indifferent"
replace fiveyr1500 = "0" if fiveyr1500 == "$1,000 today"

replace fiveyr2000 = "2" if fiveyr2000 == "$2,000 in 5 years"
replace fiveyr2000 = "1" if fiveyr2000 == "Indifferent"
replace fiveyr2000 = "0" if fiveyr2000 == "$1,000 today"

replace currentdesires = "5" if currentdesires == "Agree strongly"
replace currentdesires = "4" if currentdesires == "Agree somewhat"
replace currentdesires = "3" if currentdesires == "Indifferent"
replace currentdesires = "2" if currentdesires == "Disagree somewhat"
replace currentdesires = "1" if currentdesires == "Disagree strongly"

replace satisfiedbasics = "5" if satisfiedbasics == "Agree strongly"
replace satisfiedbasics = "4" if satisfiedbasics == "Agree somewhat"
replace satisfiedbasics = "3" if satisfiedbasics == "Neutral"
replace satisfiedbasics = "2" if satisfiedbasics == "Disagree somewhat"
replace satisfiedbasics = "1" if satisfiedbasics == "Disagree strongly"

replace startbiz = "5" if startbiz == "Definitely / I have already started a business"
replace startbiz = "4" if startbiz == "Probably"
replace startbiz = "3" if startbiz == "Maybe"
replace startbiz = "2" if startbiz == "Probably not"
replace startbiz = "1" if startbiz == "Definitely not"

replace stableincome = "5" if stableincome == "Very stable"
replace stableincome = "4" if stableincome == "Somewhat stable"
replace stableincome = "3" if stableincome == "Neutral"
replace stableincome = "2" if stableincome == "Somewhat unstable"
replace stableincome = "1" if stableincome == "Very unstable"

replace worriedjob = "4" if worriedjob == "Very worried"
replace worriedjob = "3" if worriedjob == "Somewhat worried"
replace worriedjob = "2" if worriedjob == "Not very worried"
replace worriedjob = "1" if worriedjob == "Not worried at all"

replace similarjob = "5" if similarjob == "Almost certain (90-100%)"
replace similarjob = "4" if similarjob == "Likely (60-90%)"
replace similarjob = "3" if similarjob == "Even chance (40-60%)"
replace similarjob = "2" if similarjob == "Unlikely (10-40%)"
replace similarjob = "1" if similarjob == "Almost no chance (0-10%)"

replace safetynet = "4" if safetynet == "More than 6 months"
replace safetynet = "3" if safetynet == "3–6 months"
replace safetynet = "2" if safetynet == "1–3 months"
replace safetynet = "1" if safetynet == "Less than 1 month"

replace riskai = "5" if riskai == "I have already lost a job to AI"
replace riskai = "4" if riskai == "The risk is high"
replace riskai = "3" if riskai == "The risk is substantial"
replace riskai = "2" if riskai == "The risk is low"
replace riskai = "1" if riskai == "No risk"

replace riskclimate = "5" if riskclimate == "I have already relocated due to climate events"
replace riskclimate = "4" if riskclimate == "The risk is high"
replace riskclimate = "3" if riskclimate == "The risk is substantial"
replace riskclimate = "2" if riskclimate == "The risk is low"
replace riskclimate = "1" if riskclimate == "No risk"

replace riskhealth = "5" if riskhealth == "I already live without health insurance"
replace riskhealth = "4" if riskhealth == "The risk is high"
replace riskhealth = "3" if riskhealth == "The risk is substantial"
replace riskhealth = "2" if riskhealth == "The risk is low"
replace riskhealth = "1" if riskhealth == "No risk"

replace riskhome = "5" if riskhome == "The risk is high"
replace riskhome = "4" if riskhome == "The risk is substantial"
replace riskhome = "3" if riskhome == "The risk is low"
replace riskhome = "2" if riskhome == "No risk"
replace riskhome = "1" if riskhome == "I have already owned or currently own a home"

replace children = "5" if children == "5 or more"
replace children = "-1" if children == "Unsure"

replace childrenplan = "5" if childrenplan == "5 or more"
replace childrenplan = "-1" if childrenplan == "Unsure"

replace usborn = "1" if usborn == "Yes"
replace usborn = "0" if usborn == "No"

replace usbornparents = "1" if usbornparents == "Yes"
replace usbornparents = "0" if usbornparents == "No"

replace density = "3" if density == "Urban"
replace density = "2" if density == "Suburban"
replace density = "1" if density == "Rural"

replace homedensity = "3" if homedensity == "Urban"
replace homedensity = "2" if homedensity == "Suburban"
replace homedensity = "1" if homedensity == "Rural"

replace student = "6" if student == "Professional doctoral program (e.g., JD, MD)"
replace student = "5" if student == "Research doctoral program (e.g., PhD, DSc)"
replace student = "4" if student == "Master's program (e.g., MA, MS, MBA)"
replace student = "3" if student == "4-year college"
replace student = "2" if student == "2-year college"
replace student = "1" if student == "High school"
replace student = "0" if student == "Not a student"

replace edu = "9" if edu  == "Professional doctorate (e.g., JD, MD)"
replace edu = "8" if edu  == "Research doctorate (e.g., PhD, DSc)"
replace edu = "7" if edu  == "Master's degree (e.g., MA, MS, MBA)"
replace edu = "6" if edu  == "4-year college degree"
replace edu = "5" if edu  == "2-year college degree"
replace edu = "4" if edu  == "Some college"
replace edu = "3" if edu  == "High school degree / GED"
replace edu = "2" if edu  == "Some high school"
replace edu = "1" if edu  == "Eighth grade or less"

replace eduplan = "9" if eduplan  == "Professional doctorate (e.g., JD, MD)"
replace eduplan = "8" if eduplan  == "Research doctorate (e.g., PhD, DSc)"
replace eduplan = "7" if eduplan  == "Master's degree (e.g., MA, MS, MBA)"
replace eduplan = "6" if eduplan  == "4-year college degree"
replace eduplan = "5" if eduplan  == "2-year college degree"
replace eduplan = "4" if eduplan  == "Some college"
replace eduplan = "3" if eduplan  == "High school degree / GED"
replace eduplan = "2" if eduplan  == "Some high school"
replace eduplan = "1" if eduplan  == "Eighth grade or less"

replace edumoth = "9" if edumoth  == "Professional doctorate (e.g., JD, MD)"
replace edumoth = "8" if edumoth  == "Research doctorate (e.g., PhD, DSc)"
replace edumoth = "7" if edumoth  == "Master's degree (e.g., MA, MS, MBA)"
replace edumoth = "6" if edumoth  == "4-year college degree"
replace edumoth = "5" if edumoth  == "2-year college degree"
replace edumoth = "4" if edumoth  == "Some college"
replace edumoth = "3" if edumoth  == "High school degree / GED"
replace edumoth = "2" if edumoth  == "Some high school"
replace edumoth = "1" if edumoth  == "Eighth grade or less"

replace edufath = "9" if edufath  == "Professional doctorate (e.g., JD, MD)"
replace edufath = "8" if edufath  == "Research doctorate (e.g., PhD, DSc)"
replace edufath = "7" if edufath  == "Master's degree (e.g., MA, MS, MBA)"
replace edufath = "6" if edufath  == "4-year college degree"
replace edufath = "5" if edufath  == "2-year college degree"
replace edufath = "4" if edufath  == "Some college"
replace edufath = "3" if edufath  == "High school degree / GED"
replace edufath = "2" if edufath  == "Some high school"
replace edufath = "1" if edufath  == "Eighth grade or less"

gen liberalecon = "3" if ideolecon == "Liberal"
replace liberalecon = "2" if ideolecon == "Moderate"
replace liberalecon = "1" if ideolecon == "Conservative"
drop ideolecon
order liberalecon, after(jobunemp)

gen liberalsocial = "3" if ideolsocial == "Liberal"
replace liberalsocial = "2" if ideolsocial == "Moderate"
replace liberalsocial = "1" if ideolsocial == "Conservative"
drop ideolsocial
order liberalsocial, after(liberalecon)

* convert from string to numeric
destring shouldconcern progressivity viewchange proposal taxdemotivates gapmotivates fundedu protecttrade cuttaxes univhealth wealthtax zerosumrich zerosumceo zerosumwomen zerosumdei moveup20 moveup50 moveupnow workhaspaid workwillpay eduwillpay compmoth compfath compfam compper nohh hhin10 pinc10cert hhinc10cert child30s child40s stranger100 friend100 oneyr1100 oneyr1500 oneyr2000 fiveyr1100 fiveyr1500 fiveyr2000 currentdesires satisfiedbasics startbiz stableincome worriedjob similarjob safetynet riskai riskclimate riskhealth riskhome children childrenplan usborn usbornparents density homedensity student edu eduplan edumoth edufath liberalecon liberalsocial zip, replace

** final numeric dataset

* unnecessary text
drop viewchange_oth 

save data/numeric, replace
export delimited data/numeric, replace



*** summary statistics/demographics

cd /Users/ranciere/Dropbox/capitalism_aversion/survey/data

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

 g riskhome2=riskhome if riskhome!=1
 g high_risk=1 if riskhome2==5
 replace high_risk=0 if riskhome2<5


 
 sort cohort
 egen cohortgroup=group(cohort)
 sort cohortgroup
 
  gen young=1 if cohortgroup<3
 replace young=O if  cohortgroup>2
 sort young
 
 collapse (mean) shouldconcern-usborn homedensity-biasright  riskhome2-high_risk,  by(young)
 
foreach var of varlist shouldconcern progressivity proposal taxdemotivates gapmotivates fundedu protecttrade cuttaxes univhealth wealthtax zerosumrich zerosumceo zerosumwomen zerosumdei moveup20 moveup50 moveupnow workhaspaid workwillpay eduwillpay stranger100 friend100 oneyr1100 oneyr1500 oneyr2000 fiveyr1100 fiveyr1500 fiveyr2000 currentdesires satisfiedbasics startbiz stableincome worriedjob similarjob safetynet riskai riskclimate riskhealth riskhome*  {
    quietly graph bar `var', over(cyoung) blabel(bar, format(%9.0g)) title("`var' by young/old")
    graph export "`var'.png", replace
}
