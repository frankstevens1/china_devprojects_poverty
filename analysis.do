///
/// Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
/// Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡

/// Load dataset version 2

* World
clear
est clear
cd C:\Users\fstev\mthesis
use data_v3.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index
drop agri bank budget business civil commod debt emergency environment food_aid industry multisector ngo_support pop_policy social_infra trade_tourism unspecified vague water women agri_d bank_d budget_d business_d civil_d commod_d debt_d emergency_d environment_d food_aid_d industry_d multisector_d ngo_support_d pop_policy_d social_infra_d trade_tourism_d unspecified_d vague_d water_d women_d bank_p budget_p business_p civil_p commod_p debt_p emergency_p environment_p food_aid_p industry_p multisector_p ngo_support_p pop_policy_p social_infra_p agri_p trade_tourism_p unspecified_p vague_p water_p women_p
summarize

estpost summarize iwipov50 regpopm ln_pop steel ln_steel total oda oof transport health educ energy comms total_d oda_d oof_d transport_d health_d educ_d energy_d comms_d total_p oda_p oof_p transport_p health_p educ_p energy_p comms_p amount_total amount_oda amount_oof amount_transport
est store sum
esttab sum using summary.rtf, cells("count mean sd min max") noobs nonum

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

/// Main Analysis (with binary indicator for the presence of 1 or more projects in a region and year):

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

/// Tables

* Table 1: OLS & Reduced Form
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 using table1.rtf, indicate(`r(indicate_fe)') nocons obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) interaction( x ) order(ln_pop)
* Table 2: 2SLS & 1st Stage
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model9 model10 model11 model12 model13 model14 model15 model16 using table2.rtf, indicate(`r(indicate_fe)') noconstant obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) interaction( x ) order(ln_pop)

/// Secondary Analysis I (with counts of projects)

* OLS with counts:
reghdfe iwipov50 L2.total ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model17
reghdfe iwipov50 L2.oda ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model18
reghdfe iwipov50 L2.oof ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model19
reghdfe iwipov50 L2.transport ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model20

* 2SLS with counts:
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model21
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model22
ivreghdfe iwipov50 (L2.oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model23
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model24

* First stage regressions (counts)
reghdfe L2.total c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model25
reghdfe L2.oda c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model26
reghdfe L2.oof c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model27
reghdfe L2.transport c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model28

/// Tables

* Table 3: project counts & amounts as independent variable
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model17 model18 model19 model20 model21 model22 model23 model24 model25 model26 model27 model28 using table3.rtf, indicate(`r(indicate_fe)') noconstant obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) interaction( x ) order(ln_pop)

/// Secondary Analysis II (with project values)

* OLS with amounts:
reghdfe iwipov50 L2.amount_total ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model29
reghdfe iwipov50 L2.amount_oda ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model30
reghdfe iwipov50 L2.amount_oof ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model31
reghdfe iwipov50 L2.amount_transport ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model32

* 2SLS with counts:
ivreghdfe iwipov50 (L2.amount_total = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model33
ivreghdfe iwipov50 (L2.amount_oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model34
ivreghdfe iwipov50 (L2.amount_oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model35
ivreghdfe iwipov50 (L2.amount_transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model36

* First stage regressions (counts)
reghdfe L2.amount_total c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model37
reghdfe L2.amount_oda c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model38
reghdfe L2.amount_oof c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model39
reghdfe L2.amount_transport c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model40

/// Tables

* Table 4: project values
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model29 model30 model31 model32 model33 model34 model35 model36 model37 model38 model39 model40 using table4.rtf, indicate(`r(indicate_fe)') noconstant obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_g N_clust) interaction( x ) order(ln_pop)

// Secondary analysis (next top 4 sectors)

* OLS:
reghdfe iwipov50 L2.health_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model41
reghdfe iwipov50 L2.educ_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model42
reghdfe iwipov50 L2.energy_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model43
reghdfe iwipov50 L2.comms_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model44

* Reduced form:
reghdfe iwipov50 c.L3.ln_steel#c.health_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model45
reghdfe iwipov50 c.L3.ln_steel#c.educ_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model46
reghdfe iwipov50 c.L3.ln_steel#c.energy_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model47
reghdfe iwipov50 c.L3.ln_steel#c.comms_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model48

* 2SLS:
ivreghdfe iwipov50 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model49
ivreghdfe iwipov50 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model50
ivreghdfe iwipov50 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model51
ivreghdfe iwipov50 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model52

* First stage regressions
reghdfe L2.health_d c.L3.ln_steel#c.health_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model53
reghdfe L2.educ_d c.L3.ln_steel#c.educ_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model54
reghdfe L2.energy_d c.L3.ln_steel#c.energy_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model55
reghdfe L2.comms_d c.L3.ln_steel#c.comms_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model56

/// Tables

* Table 5: OLS & Reduced Form (health, educ, energy & comms)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model41 model42 model43 model44 model45 model46 model47 model48 using table5.rtf, indicate(`r(indicate_fe)') nocons obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) interaction( x ) order(ln_pop)
* Table 6: 2SLS & 1st Stage (health, educ, energy & comms)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model49 model50 model51 model52 model53 model54 model55 model56 using table6.rtf, indicate(`r(indicate_fe)') noconstant obslast compress label depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) interaction( x ) order(ln_pop)
