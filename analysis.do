///
/// Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
/// Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡

/// Load dataset version 2

* World
clear
use C:\Users\fstev\mthesis\data_v2.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
summarize

/// Analysis

* OLS:
reghdfe iwipov50 L2.total_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.oof_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model3
reghdfe iwipov50 L2.transport_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model4

* Reduced form:
reghdfe iwipov50 c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model6
reghdfe iwipov50 c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model7
reghdfe iwipov50 c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model8

* 2SLS:
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model9
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model10
ivreghdfe iwipov50 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model11
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model12

* First stage regressions
reghdfe L2.total_d c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model13
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model14
reghdfe L2.oof_d c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model15
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model16

label variable iwipov50 "IWI < 50 (%)"
label variable total_d "Project"
label variable oda_d "ODA Project"
label variable oof_d "OOF Project"
label variable transport_d "Transport Project"
label variable ln_steel "ln(Steel)"
label variable total_p "p_ir"
label variable oda_p "P_ir"
label variable oof_p "P_ir"
label variable transport_p "P_ir"
label variable ln_pop "ln(Population)"

/// Tables

* OLS & Reduced Form
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 using table1.rtf, indicate(`r(indicate_fe)') nocons obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 † 0.001) scalars(r2_a N_clust) interaction(' x ') order(ln_pop)
* 2SLS & 1st Stage
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model9 model10 model11 model12 model13 model14 model15 model16 using table2.rtf, indicate(`r(indicate_fe)') noconstant obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 	 0.001) scalars(r2_a rkf cdf N_clust) interaction(' x ') order(ln_pop)
