/// china_devprojects_poverty

* 2SLS strategy for determining effect of Chinese development projects on poverty
* Repository: https://github.com/frankstevens1/china_devprojects_poverty
* June 2020, Frank Stevens: fstevens92@gmail.com

/// Prepare dataset (Regional Level):
* import dataset
clear
est clear
cd C:\Users\fstev\mthesis
use data.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index

* drop unused variables
drop iwi agri bank budget business civil commod debt emergency environment ///
 food_aid industry multisector ngo_support pop_policy social_infra ///
 trade_tourism unspecified vague water women agri_d bank_d budget_d ///
 business_d civil_d commod_d debt_d emergency_d environment_d food_aid_d ///
 industry_d multisector_d ngo_support_d pop_policy_d social_infra_d ///
 trade_tourism_d unspecified_d vague_d water_d women_d bank_p budget_p ///
 business_p civil_p commod_p debt_p emergency_p environment_p food_aid_p ///
 industry_p multisector_p ngo_support_p pop_policy_p social_infra_p ///
 agri_p trade_tourism_p unspecified_p vague_p water_p women_p iwipov35 iwipov70 ///
 hhpov35 hhpov70 ln_hhpov35 ln_hhpov70 poppov35 poppov70 ln_poppov35 ln_poppov70
 

*****
 
 
/// Summary Statistics:
estpost summarize ///
 iwipov50 regpopm poppov50 hhpov50 hhsize steel ///
 ln_pop ln_hhpov50 ln_steel /// 
 total oda oof transport health educ energy comms ///
 total_d oda_d oof_d transport_d health_d educ_d energy_d comms_d ///
 total_p oda_p oof_p transport_p health_p educ_p energy_p comms_p ///
 amount_total amount_oda amount_oof amount_transport
est store summarytable
esttab summarytable using summary-stats.rtf, replace cells("count mean sd min max") noobs nonum


*****


/// A. Main Regressions: OLS, Reduced Form, 2SLS & 1st Stage (Regional Level)
** Independent variable: Project Presence or Absence (Dummy)

** 2SLS Stages:
** Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡

* A1. OLS
reghdfe ln_hhpov50 L2.total_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model1
reghdfe ln_hhpov50 L2.oda_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model2
reghdfe ln_hhpov50 L2.oof_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model3
reghdfe ln_hhpov50 L2.transport_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model4

* A2. reduced form
reghdfe ln_hhpov50 c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model5
reghdfe ln_hhpov50 c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model6
reghdfe ln_hhpov50 c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model7
reghdfe ln_hhpov50 c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model8

* A3. 2SLS
ivreghdfe ln_hhpov50 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year, resid(r1)) cluster(country) first
estimates store model9
predict yhat1
ivreghdfe ln_hhpov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model10
ivreghdfe ln_hhpov50 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model11
ivreghdfe ln_hhpov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model12

* A4. 1st stage regression
reghdfe L2.total_d c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country) resid
estimates store model13
predict yhat2
predict r2, resid
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model14
reghdfe L2.oof_d c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model15
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model16

* A. Output Tables and Plots:

* Table 1: OLS & Reduced Form (Main Regressions)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 using table-1.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(ln_pop)
 
* Table 2: 2SLS & 1st Stage (Main Regressions)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model9 model10 model11 model12 model13 model14 model15 model16 using table-2.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast depvars se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)
 
* Plot 1 & 2: Residuals vs Predicted Values Plots:
*** 1st stage:
scatter r2 yhat2, xline(0) yline(0)
*** 2nd stage:
scatter r1 yhat1, xline(0) yline(0)


*****


/// C. Secondary Regression 1: 2SLS & 1st Stage
** Independent variable: Project Counts

* 2SLS (counts)
ivreghdfe ln_hhpov50 (L2.total = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model17
ivreghdfe ln_hhpov50 (L2.oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model18
ivreghdfe ln_hhpov50 (L2.oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model19
ivreghdfe ln_hhpov50 (L2.transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model20

* 1st stage regression (counts)
reghdfe L2.total c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model21
reghdfe L2.oda c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model22
reghdfe L2.oof c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model23
reghdfe L2.transport c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model24

* Table 5: project counts
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model17 model18 model19 model20 model21 model22 model23 model24 using table-5.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

 
*****


/// D. Secondary Regression 2: Top4 sectors after transport - 2SLS & 1st Stage 
** Independent variable: Project Dummies

* 2SLS (next 4 sectors)
ivreghdfe ln_hhpov50 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model25
ivreghdfe ln_hhpov50 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model26
ivreghdfe ln_hhpov50 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model27
ivreghdfe ln_hhpov50 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model28

* 1st stage regresssions (next 4 sectors)
reghdfe L2.health_d c.L3.ln_steel#c.health_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model29
reghdfe L2.educ_d c.L3.ln_steel#c.educ_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model30
reghdfe L2.energy_d c.L3.ln_steel#c.energy_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model31
reghdfe L2.comms_d c.L3.ln_steel#c.comms_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model32

* Table 6: 2SLS & 1st Stage (health, educ, energy & comms)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model25 model26 model27 model28 model29 model30 model31 model32 using table-6.rtf, /// 
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)


*****


/// Prepare dataset (Country Level):
* import dataset
clear
est clear
cd C:\Users\fstev\mthesis
use data_iso.dta
encode iso_code, g(country)
xtset country year
drop index

* drop unused variables
drop iwi iwipov70 iwipov35 hhpov35 hhpov70 ln_hhpov35 ln_hhpov70 poppov35 poppov70 ln_poppov35 ln_poppov70 ///
 agri bank budget business civil commod debt emergency food_aid health industry multisector ngo_support /// 
 pop_policy social_infra trade_tourism civil_d commod_d debt_d emergency_d environment_d food_aid_d /// 
 health_d industry_d multisector_d ngo_support_d pop_policy_d social_infra_d trade_tourism_d unspecified_d /// 
 vague_d water_d women_d unspecified vague water women agri_d bank_d budget_d business_d civil_d /// 
 commod_d debt_d emergency_d environment_d food_aid_d industry_d multisector_d ngo_support_d pop_policy_d /// 
 social_infra_d trade_tourism_d unspecified_d vague_d water_d women_d bank_p budget_p business_p civil_p /// 
 commod_p debt_p emergency_p environment_p food_aid_p industry_p multisector_p ngo_support_p pop_policy_p /// 
 social_infra_p agri_p trade_tourism_p unspecified_p vague_p water_p women_p
 

*****
 
 
/// Summary Statistics:
estpost summarize ///
 iwipov50 regpopm hhsize ln_pop hhpov50 ln_hhpov50 /// 
 steel exports ln_steel oda oof total transport /// 
 oda_d oof_d total_d transport_d oda_p oof_p transport_p
est store summarytable
esttab summarytable, replace cells("count mean sd min max") noobs nonum


*****


/// B. Main Regressions: OLS, Reduced Form, 2SLS & 1st Stage (Country Level)
** Independent variable: Project Presence or Absence (Dummy)

* B1. OLS
reghdfe ln_hhpov50 L2.total_d ln_pop, absorb(i.country i.year) vce(robust)
estimates store model1
reghdfe ln_hhpov50 L2.oda_d ln_pop, absorb(i.country i.year) vce(robust)
estimates store model2
reghdfe ln_hhpov50 L2.oof_d ln_pop, absorb(i.country i.year) vce(robust)
estimates store model3
reghdfe ln_hhpov50 L2.transport_d ln_pop, absorb(i.country i.year) vce(robust)
estimates store model4

* B2. reduced form
reghdfe ln_hhpov50 c.L3.ln_steel#c.total_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model5
reghdfe ln_hhpov50 c.L3.ln_steel#c.oda_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model6
reghdfe ln_hhpov50 c.L3.ln_steel#c.oof_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model7
reghdfe ln_hhpov50 c.L3.ln_steel#c.transport_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model8

* B3. 2SLS
ivreghdfe ln_hhpov50 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(country year) cluster(country) first
estimates store model9
ivreghdfe ln_hhpov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(country year) cluster(country) first
estimates store model10
ivreghdfe ln_hhpov50 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(country year) cluster(country) first
estimates store model11
ivreghdfe ln_hhpov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(country year) cluster(country) first
estimates store model12

* B4. 1st stage regression
reghdfe L2.total_d c.L3.ln_steel#c.total_p ln_pop, absorb(country year) cluster(country)
estimates store model13
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p ln_pop, absorb(country year) cluster(country)
estimates store model14
reghdfe L2.oof_d c.L3.ln_steel#c.oof_p ln_pop, absorb(country year) cluster(country)
estimates store model15
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p ln_pop, absorb(country year) cluster(country)
estimates store model16

* B. Output Tables and Plots:

* Table 3: OLS & Reduced Form (Main Regressions, National Level)
estfe model*, labels(country "Country FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(ln_pop)
 
* Table 4: 2SLS & 1st Stage (Main Regressions, National Level)
estfe model*, labels(country "Country FE" year "Year FE")
esttab model9 model10 model11 model12 model13 model14 model15 model16, ///
 replace indicate(`r(indicate_fe)') nocons obslast depvars se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)


