capture log close
log using EdwardSen_StevenChung_Log.log, replace

// i. Data cleaning
clear
ssc install xtoverid
ssc install ivreg2
ssc install estout
net install gr0002.pkg, from(http://www.stata-journal.com/software/sj3-3/)
eststo clear
cd "C:\Users\admin\Desktop\ECO375\Project"

tempfile building
save building, emptyok replace

local flist : dir "C:\Users\admin\Desktop\ECO375\Project" files "*.xlsx"	

quietly foreach filename of local flist{
	import excel `"`filename'"', clear 
	
	if strpos(`"`filename'"', "22") > 0 {
		keep A B D E F H I Y Z AA AB AC AS AU AV
		rename (A B D E F H I Y Z AA AB AC AS AU AV) (bnum bname schnum schname schtype schlvl schlang eslpct fslpct eslcpct fslcpct spedpct ossltftpr lowincpct parnopse)
}	
	else {
		keep A B D E F H I Y Z AA AB AC AU AW AX
		rename (A B D E F H I Y Z AA AB AC AU AW AX) (bnum bname schnum schname schtype schlvl schlang eslpct fslpct eslcpct fslcpct spedpct ossltftpr lowincpct parnopse)
}	

	label variable bnum "School board number"
	label variable bname "School board name"
	label variable schnum "School number"
	label variable schname "School name"
	label variable schtype "School type"
	label variable schlvl "School level"
	label variable schlang "Instruction lang."
	label variable eslpct "Second-language Eng. speaker %"
	label variable fslpct "Second-language Fr. speaker %"
	label variable spedpct "Special ed. %"
	label variable ossltftpr "OSSLT ft. pass %"
	label variable lowincpct "Low-income student %"
	label variable parnopse "Parents forgone PSE %"
	
	drop in 1
	
	drop if schlvl!="Secondary"
	drop if eslpct=="NA" | eslpct=="SP"
	drop if fslpct=="NA" | fslpct=="SP"
	drop if eslcpct=="NA" | eslcpct=="SP"
	drop if fslcpct=="NA" | fslcpct=="SP"
	drop if spedpct=="NA" | spedpct=="SP"
	drop if ossltftpr=="N/D" | ossltftpr=="N/R" | ossltftpr=="NA" 
	drop if lowincpct=="NA" | lowincpct=="SP"
	drop if parnopse=="NA" | parnopse=="SP"
	
	replace bnum=strtrim(subinstr(bnum, "B", "", .)) if strpos(bnum, "B") > 0 
	replace ossltftpr=strtrim(subinstr(ossltftpr, "%", "", .)) if strpos(ossltftpr, "%") > 0 
	replace ossltftpr=string(real(ossltftpr) * 100) if strpos(ossltftpr, ".") > 0 
	replace ossltftpr=string(real(ossltftpr) * 100) if ossltftpr=="1" 
	
	destring bnum schnum eslpct fslpct eslcpct fslcpct spedpct ossltftpr lowincpct parnopse, percent replace
		
	replace eslpct=eslpct/100
	replace fslpct=fslpct/100
	replace eslcpct=eslcpct/100
	replace fslcpct=fslcpct/100
	replace spedpct=spedpct/100
	replace ossltftpr=ossltftpr/100 
	replace lowincpct=lowincpct/100 
	replace parnopse=parnopse/100
	
	gen eng=1 if schlang=="English"
	replace eng=0 if schlang=="French"
	label variable eng "Indicator for English school"

	gen slpct=eslpct if schlang=="English" 
	replace slpct=fslpct if schlang=="French"
	label variable slpct "Instruction lang. is second lang. %"

	gen slcpct=eslcpct if schlang=="English"
	replace slcpct=fslcpct if schlang=="French"
	label variable slcpct "New to CAN from non-Eng/non-Fr country %"

	gen pub=1 if schtype=="Public"
	replace pub=0 if schtype!="Public"
	label variable pub "Indicator for Public school"
	
	gen ln_slpct = ln(slpct)
	gen ln_slcpct = ln(slcpct)
	gen ln_spedpct = ln(spedpct)
	gen ln_ossltftpr = ln(ossltftpr)
	gen ln_lowincpct = ln(lowincpct)
	gen ln_parnopse = ln(parnopse)
	
	label variable ln_slpct "ln(Instruction lang. is second lang. %)"
	label variable ln_slcpct "ln(New to CAN from non-Eng/non-Fr country %)"
	label variable ln_spedpct "ln(Special. ed %)"
	label variable ln_ossltftpr "ln(OSSLT ft. pass %)"
	label variable ln_lowincpct "ln(Low-income student %)"
	label variable ln_parnopse "ln(Parents forgone PSE %)"
	
	gen slpct2 = slpct*slpct
	gen slcpct2 = slcpct*slcpct
	gen spedpct2 = spedpct*spedpct
	gen ossltftpr2 = ossltftpr*ossltftpr
	gen lowincpct2 = lowincpct*lowincpct
	gen parnopse2 = parnopse*parnopse
	
	label variable slpct2 "(Instruction lang. is second lang. %)^2"
	label variable slcpct2 "(New to CAN from non-Eng/non-Fr country %)^2"
	label variable spedpct2 "(Special ed. %)^2"
	label variable ossltftpr2 "(OSSLT ft. pass %)^2"
	label variable lowincpct2 "(Low-income student %)^2"
	label variable parnopse2 "(Parents forgone PSE %)^2"
	
	gen slpct3 = slpct2*slpct
	gen slcpct3 = slcpct2*slcpct
	gen spedpct3 = spedpct2*spedpct
	gen ossltftpr3 = ossltftpr2*ossltftpr
	gen lowincpct3 = lowincpct2*lowincpct
	gen parnopse3 = parnopse2*parnopse
	
	label variable slpct3 "(Instruction lang. is second lang. %)^3"
	label variable slcpct3 "(New to CAN from non-Eng/non-Fr country %)^3"
	label variable spedpct3 "(Special ed. %)^3"
	label variable ossltftpr3 "(OSSLT ft. pass %)^3"
	label variable lowincpct3 "(Low-income student %)^3"
	label variable parnopse3 "(Parents forgone PSE %)^3"

	drop schtype schlvl schlang eslpct fslpct eslcpct fslcpct
	
	gen year = substr(`"`filename'"', -17, 4)
	display year
	
	order bnum bname schnum schname year pub eng slpct slcpct

	format slpct slcpct spedpct ossltftpr lowincpct parnopse %8.2g
	
	append using building
	save building, replace
}

quietly replace year="2021" if year=="_oct"
quietly destring year, replace
quietly sort schnum year

save EdwardSen_StevenChung_data.dta, replace
use EdwardSen_StevenChung_data.dta, clear

quietly xtset schnum year

// Drop nonconsecutive years
quietly gen run = .
quietly by schnum: replace run = cond(L.run == ., 1, L.run + 1)
quietly by schnum: egen maxrun = max(run)
quietly drop if maxrun!=5

xtset schnum year

// ii. Summary statistics

summarize ossltftpr lowincpct slpct slcpct spedpct parnopse

// iii. Preliminary Checks for multicollinearity

pwcorr ossltftpr lowincpct slpct slcpct spedpct parnopse eng pub, sig
// set scheme lean2
set scheme s2color
graph matrix ossltftpr lowincpct slpct slcpct spedpct parnopse, half maxis(ylabel(none) xlabel(none)) title("Pairwise Scatter Plots") note("matrixplot.png", size(vsmall)) msymbol(o) msize(vtiny)
graph save pooled_pairwise, replace

// iv. Limited model

reg ossltftpr lowincpct, robust
graph twoway (scatter ossltftpr lowincpct, msymbol(o) msize(tiny)) (lfit ossltftpr lowincpct), title("Simple linear model") subtitle("OSSLT first-time pass% v Low-income student%") xtitle("Low-income student%") ytitle("OSSLT first-time pass%")
graph save ossltftpr_lowincpct_lfit, replace

predict yhat_simple
graph twoway (scatter yhat_simple ossltftpr, msize(tiny) msymbol(o)) (lfit yhat_simple ossltftpr) (lfitci yhat_simple ossltftpr), title("Model Check") subtitle("Plot of Observed v Predicted") 
graph save Observed_Predicted_Simple, replace
linktest
ovtest

// v. Multivariate model specification

// Analysis on relationship between ossltftpr and lowincpct
eststo: quietly reg ossltftpr lowincpct, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2, robust // best: lowest AIC BIC w/ statistically significant higher order term
eststo: quietly reg ossltftpr lowincpct lowincpct2 lowincpct3, robust
eststo: quietly reg ln_ossltftpr lowincpct, robust
eststo: quietly reg ossltftpr ln_lowincpct, robust
eststo: quietly reg ln_ossltftpr ln_lowincpct, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

graph twoway (function y=0.820-0.256*x) (function y=0.771+0.401*x-1.783*x*x) (function y=0.712-0.0354*ln(x)) (scatter ossltftpr lowincpct, msymbol(o) msize(tiny)), title("Model comparison") subtitle("OSSLT first-time pass% v Low-income student%") xtitle("Low-income student%") ytitle("OSSLT first-time pass%") legend(label(1 "Linear") label(2 "Quadratic") label(3 "Lin-log"))
graph save ossltftpr_lowincpct_fits, replace

// Analysis on relationship between ossltftpr and slpct
eststo: quietly reg ossltftpr slpct, robust
eststo: quietly reg ossltftpr slpct slpct2, robust
eststo: quietly reg ossltftpr slpct slpct2 slpct3, robust
eststo: quietly reg ln_ossltftpr slpct, robust
eststo: quietly reg ossltftpr ln_slpct, robust // best: lowest RMSE, low AIC BIC despite inflated IC due to smaller num of observations
eststo: quietly reg ln_ossltftpr ln_slpct, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

graph twoway (function y=0.852+0.0297*ln(x)) (function y=0.712+0.540*x-0.540*x*x) (function y=0.699+0.882*x-1.738*x*x+1.017*x*x*x) (scatter ossltftpr slpct, msymbol(o) msize(tiny)), title("Model comparison") subtitle("OSSLT first-time pass% v Non-Eng/non-French first lang. %") xtitle("Non-Eng/non-French first lang. %") ytitle("OSSLT first-time pass%") legend(label(1 "Lin-log") label(2 "Quadratic") label(3 "Cubic"))
graph save ossltftpr_slpct_fits, replace

// Analysis on relationship between ossltftpr and slcpct
eststo: quietly reg ossltftpr slcpct, robust
eststo: quietly reg ossltftpr slcpct slcpct2, robust // best: low AIC, BIC, cubic model ruled out as it predicts pass rate greater than 100%
eststo: quietly reg ossltftpr slcpct slcpct2 slcpct3, robust
eststo: quietly reg ln_ossltftpr slcpct, robust
eststo: quietly reg ossltftpr ln_slcpct, robust
eststo: quietly reg ln_ossltftpr ln_slcpct, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

graph twoway (function y=0.762-0.936*x*x-3.445*x*x) (function y=0.746+2.244*x-14.93*x*x+20.29*x*x*x) (scatter ossltftpr slcpct, msymbol(o) msize(tiny)), title("Model comparison") subtitle("OSSLT first-time pass% v New to Canada from non-Eng/non-French country%") xtitle("New to Canada from non-Eng/non-French country%") ytitle("OSSLT first-time pass%") legend(label(1 "Quadratic") label(2 "Cubic"))
graph save ossltftpr_slcpct_fits, replace

// Analysis on relationship between ossltftpr and spedpct
eststo: quietly reg ossltftpr spedpct, robust
eststo: quietly reg ossltftpr spedpct spedpct2, robust // best: lowest AIC, BIC
eststo: quietly reg ossltftpr spedpct spedpct2 spedpct3, robust
eststo: quietly reg ln_ossltftpr spedpct, robust
eststo: quietly reg ossltftpr ln_spedpct, robust
eststo: quietly reg ln_ossltftpr ln_spedpct, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

graph twoway (function y=0.970-0.807*x) (function y=0.950-0.674*x-0.169*x*x) (scatter ossltftpr spedpct, msymbol(o) msize(tiny)), title("Model comparison") subtitle("OSSLT first-time pass% v Special ed.%") xtitle("Special ed.%") ytitle("OSSLT first-time pass%") legend(label(1 "Linear") label(2 "Quadratic"))
graph save ossltftpr_spedpct_fits, replace

// Analysis on relationship between ossltftpr and parnopse
eststo: quietly reg ossltftpr parnopse, robust // best: lowest AIC, BIC
eststo: quietly reg ossltftpr parnopse parnopse2, robust
eststo: quietly reg ossltftpr parnopse parnopse2 parnopse3, robust
eststo: quietly reg ln_ossltftpr parnopse, robust
eststo: quietly reg ossltftpr ln_parnopse, robust
eststo: quietly reg ln_ossltftpr ln_parnopse, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

graph twoway (function y=0.829-0.694*x) (function y=0.823-0.390*x-3.082*x*x+7.298*x*x*x) (function y=0.609-0.0609*ln(x)) (scatter ossltftpr parnopse, msymbol(o) msize(tiny)), title("Model Comparison") subtitle("OSSLT first-time pass% v Parents with no postsecondary education%") xtitle("Parents with no postsecondary education%") ytitle("OSSLT first-time pass%") legend(label(1 "Linear") label(2 "Cubic") label(3 "Lin-log"))
graph save ossltftpr_parnopse_fits, replace

// Linear fits for ossltftpr with eng and pub
graph twoway (scatter ossltftpr eng, msymbol(o) msize(tiny)) (lfit ossltftpr eng), title("Linear fit") subtitle("OSSLT first-time pass% v Indicator for English school") xtitle("Indicator for English school") ytitle("OSSLT first-time pass%")
graph save ossltftpr_eng_lfit, replace

graph twoway (scatter ossltftpr pub, msymbol(o) msize(tiny)) (lfit ossltftpr pub), title("Linear fit") subtitle("OSSLT first-time pass% v Indicator for public school") xtitle("Indicator for public school") ytitle("OSSLT first-time pass%")
graph save ossltftpr_pub_lfit, replace

// Backwards stepwise selection: Maximal model
reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse eng pub i.year, robust

// Backwards stepwise selection: Step 1
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse eng pub, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse eng i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct slcpct2 spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng pub i.year, robust // best - highest R^2
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct2 spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 slcpct slcpct2 spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct slcpct2 spedpct spedpct2 parnopse eng pub i.year, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 2
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng pub, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct spedpct2 eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct slcpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 ln_slpct spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct lowincpct2 slcpct spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct ln_slpct slcpct spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng pub i.year, robust // best - highest R^2

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 3
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng pub, robust // best - highest R^2, lowest AIC BIC
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr lowincpct2 slcpct spedpct spedpct2 parnopse eng pub i.year, robust
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 parnopse eng pub i.year, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 4
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse pub, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 eng pub, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct parnopse eng pub, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct slcpct spedpct2 parnopse eng pub, robust
eststo: quietly reg ossltftpr lowincpct2 ln_slpct spedpct spedpct2 parnopse eng pub, robust
eststo: quietly reg ossltftpr lowincpct2 slcpct spedpct spedpct2 parnopse eng pub, robust
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 parnopse eng pub, robust // best - highest R^2

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 5
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 parnopse eng, robust // best - highest R^2
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 parnopse pub, robust 
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 eng pub, robust 
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct parnopse eng pub, robust 
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct2 parnopse eng pub, robust 
eststo: quietly reg ossltftpr ln_slpct spedpct spedpct2 parnopse eng pub, robust 
eststo: quietly reg ossltftpr slcpct spedpct spedpct2 parnopse eng pub, robust 

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 6
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 parnopse, robust // best - highest R^2
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2 eng, robust
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct parnopse eng, robust
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct2 parnopse eng, robust
eststo: quietly reg ossltftpr ln_slpct spedpct spedpct2 parnopse eng, robust
eststo: quietly reg ossltftpr slcpct spedpct spedpct2 parnopse eng, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 7
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct spedpct2, robust
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct parnopse, robust 
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct2 parnopse, robust // best - highest R^2
eststo: quietly reg ossltftpr ln_slpct spedpct spedpct2 parnopse, robust
eststo: quietly reg ossltftpr slcpct spedpct spedpct2 parnopse, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 8
eststo: quietly reg ossltftpr ln_slpct slcpct spedpct2, robust
eststo: quietly reg ossltftpr ln_slpct slcpct parnopse, robust
eststo: quietly reg ossltftpr ln_slpct spedpct2 parnopse, robust // best - highest R^2
eststo: quietly reg ossltftpr slcpct spedpct2 parnopse, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 9
eststo: quietly reg ossltftpr ln_slpct spedpct2, robust
eststo: quietly reg ossltftpr ln_slpct parnopse, robust 
eststo: quietly reg ossltftpr spedpct2 parnopse, robust // best - highest R^2

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: Step 10
eststo: quietly reg ossltftpr spedpct2, robust // best - highest R^2
eststo: quietly reg ossltftpr parnopse, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Backwards stepwise selection: best models
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng pub lowincpct2 i.year lowincpct slcpct2, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng pub lowincpct2 i.year lowincpct, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng pub lowincpct2 i.year, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng pub lowincpct2, robust // best - lowest BIC, less parameters thus satisfies parsimony principle
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng pub, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct eng, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct spedpct, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct slcpct, robust
eststo: quietly reg ossltftpr spedpct2 parnopse ln_slpct, robust
eststo: quietly reg ossltftpr spedpct2 parnopse, robust
eststo: quietly reg ossltftpr spedpct2, robust
eststo: quietly reg ossltftpr, robust

esttab, r2 scalar(rmse) aic bic
eststo clear

// Selected models
eststo: quietly reg ossltftpr lowincpct2, robust
eststo: quietly reg ossltftpr lowincpct2 spedpct spedpct2, robust
eststo: quietly reg ossltftpr lowincpct2 spedpct spedpct2 parnopse, robust
eststo: quietly reg ossltftpr lowincpct2 spedpct spedpct2 parnopse ln_slpct slcpct
eststo: quietly reg ossltftpr lowincpct2 spedpct spedpct2 parnopse ln_slpct slcpct eng pub
eststo: quietly reg ossltftpr lowincpct2 spedpct spedpct2 parnopse ln_slpct slcpct eng pub i.year

esttab using selected_models.rtf, indicate("Time effects = *.year") r2 scalar(rmse) aic bic label replace noabbrev 
eststo clear

// vi. Checking multivariate model assumptions and fit
reg ossltftpr lowincpct2 ln_slpct slcpct spedpct spedpct2 parnopse eng pub, robust
predict yhat
graph twoway (scatter yhat ossltftpr, msize(tiny) msymbol(o)) (lfit yhat ossltftpr) (lfitci yhat ossltftpr), title("Model Check") subtitle("Plot of Observed v Predicted") 
graph save Observed_Predicted, replace
linktest
ovtest

// vii. Extension - School board panels

// Panel generation
quietly bysort bnum year: egen m_ossltftpr = mean(ossltftpr)
quietly bysort bnum year: egen m_lowincpct = mean(lowincpct)
quietly bysort bnum year: egen m_slpct = mean(slpct)
quietly bysort bnum year: egen m_slcpct = mean(slcpct)
quietly bysort bnum year: egen m_spedpct = mean(spedpct)
quietly bysort bnum year: egen m_parnopse = mean(parnopse)

quietly bysort bnum year: generate d=_n
quietly keep if d==1
quietly keep bnum year m_*

xtset bnum year

quietly gen sq_lowincpct = m_lowincpct * m_lowincpct
quietly gen log_slpct = ln(m_slpct)
quietly gen sq_spedpct = m_spedpct * m_spedpct

// Multiple linear regression
xtreg m_ossltftpr m_lowincpct m_slpct m_slcpct m_spedpct m_parnopse i.year, fe cluster(bnum)

// Check for multicollinearity
estat vce, corr

log close