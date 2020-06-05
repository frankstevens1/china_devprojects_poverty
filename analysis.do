/// Validity of Instrument
clear
cd C:\Users\fstev\mthesis
use plots2.dta
tset year
drop index

reg reg_iwipov50 L3_steel
reg irreg_iwipov50 L3_steel

reg reg10 L3_steel
reg irreg10 L3_steel


///
/// Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
/// Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡

* Load dataset and prepare analysis
clear
est clear
cd C:\Users\fstev\mthesis
use data_v3.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index
* Sectors excluded from current analysis:
drop agri bank budget business civil commod debt emergency environment food_aid industry multisector ngo_support pop_policy social_infra trade_tourism unspecified vague water women agri_d bank_d budget_d business_d civil_d commod_d debt_d emergency_d environment_d food_aid_d industry_d multisector_d ngo_support_d pop_policy_d social_infra_d trade_tourism_d unspecified_d vague_d water_d women_d bank_p budget_p business_p civil_p commod_p debt_p emergency_p environment_p food_aid_p industry_p multisector_p ngo_support_p pop_policy_p social_infra_p agri_p trade_tourism_p unspecified_p vague_p water_p women_p

/// Summary Table

estpost summarize iwipov50 regpopm ln_pop steel ln_steel total oda oof transport health educ energy comms total_d oda_d oof_d transport_d health_d educ_d energy_d comms_d total_p oda_p oof_p transport_p health_p educ_p energy_p comms_p amount_total amount_oda amount_oof amount_transport
est store summarytable
esttab summarytable, replace cells("count mean sd min max") noobs nonum

/// Table 1 & 2: project dummies (main regressions)

* OLS (dummies)
reghdfe iwipov50 L2.total_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.oof_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model3
reghdfe iwipov50 L2.transport_d ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model4

* Reduced form
reghdfe iwipov50 c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model6
reghdfe iwipov50 c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model7
reghdfe iwipov50 c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode i.country#i.year) vce(cluster country)
estimates store model8

* 2SLS (dummies)
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model9
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model10
ivreghdfe iwipov50 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model11
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model12

* 1st stage regression (dummies)
reghdfe L2.total_d c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model13
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model14
reghdfe L2.oof_d c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model15
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model16

* Table 1: OLS & Reduced Form
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(ln_pop)
* Table 2: 2SLS & 1st Stage
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model9 model10 model11 model12 model13 model14 model15 model16, replace indicate(`r(indicate_fe)') nocons obslast depvars se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 3: project counts

* 2SLS (counts)
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model17
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model18
ivreghdfe iwipov50 (L2.oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model19
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
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

* Table 3: project counts
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model17 model18 model19 model20 model21 model22 model23 model24, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 4: project values

* 2SLS (amounts)
ivreghdfe iwipov50 (L2.amount_total = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model25
ivreghdfe iwipov50 (L2.amount_oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model26
ivreghdfe iwipov50 (L2.amount_oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model27
ivreghdfe iwipov50 (L2.amount_transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model28

* 1st stage regression (amounts)
reghdfe L2.amount_total c.L3.ln_steel#c.total_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model29
reghdfe L2.amount_oda c.L3.ln_steel#c.oda_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model30
reghdfe L2.amount_oof c.L3.ln_steel#c.oof_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model31
reghdfe L2.amount_transport c.L3.ln_steel#c.transport_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model32

* Table 4: project values
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model25 model26 model27 model28 model29 model30 model31 model32, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

// Table 5: Next 4 of the top 5 sectors

* 2SLS (next 4 sectors)
ivreghdfe iwipov50 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model33
ivreghdfe iwipov50 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model34
ivreghdfe iwipov50 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model35
ivreghdfe iwipov50 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model36

* First stage regressions
reghdfe L2.health_d c.L3.ln_steel#c.health_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model37
reghdfe L2.educ_d c.L3.ln_steel#c.educ_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model38
reghdfe L2.energy_d c.L3.ln_steel#c.energy_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model39
reghdfe L2.comms_d c.L3.ln_steel#c.comms_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model40

* Table 5: 2SLS & 1st Stage (health, educ, energy & comms)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model33 model34 model35 model36 model37 model38 model39 model40, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(ln_pop)

// Table 5b: Next 4 top sectors (counts)

ivreghdfe iwipov50 (L2.health = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model41
ivreghdfe iwipov50 (L2.educ = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model42
ivreghdfe iwipov50 (L2.energy = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model43
ivreghdfe iwipov50 (L2.comms = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model44

* First stage regressions
reghdfe L2.health c.L3.ln_steel#c.health_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model45
reghdfe L2.educ c.L3.ln_steel#c.educ_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model46
reghdfe L2.energy c.L3.ln_steel#c.energy_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model47
reghdfe L2.comms c.L3.ln_steel#c.comms_p ln_pop, absorb(gdlcode country#year) cluster(country)
estimates store model48

* Table 5b: 2SLS & 1st Stage (health, educ, energy & comms)
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model41 model42 model43 model44 model45 model46 model47 model48 using table5b.rtf, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(ln_pop)


// Table 6: Other poverty rates

* 2SLS - Depvar: iwipov35 (percentage of the population below IWI 35)
ivreghdfe iwipov35 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model49
ivreghdfe iwipov35 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model50
ivreghdfe iwipov35 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model51
ivreghdfe iwipov35 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model52

* 2SLS - Depvar: iwipov70 (percentage of the population below IWI 70)
ivreghdfe iwipov70 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model53
ivreghdfe iwipov70 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model54
ivreghdfe iwipov70 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model55
ivreghdfe iwipov70 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model56

* Table 6: Other poverty rates
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model49 model50 model51 model52 model53 model54 model55 model56, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 7: other poverty rates and other sectors

* 2SLS - Depvar: iwipov35 (percentage of the population below IWI 35)
ivreghdfe iwipov35 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model57
ivreghdfe iwipov35 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model58
ivreghdfe iwipov35 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model59
ivreghdfe iwipov35 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model60

* 2SLS - Depvar: iwipov70 (percentage of the population below IWI 70)
ivreghdfe iwipov70 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model61
ivreghdfe iwipov70 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model62
ivreghdfe iwipov70 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model63
ivreghdfe iwipov70 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(gdlcode country#year) cluster(country) first
estimates store model64

* Table 7: Other poverty rates
estfe model*, labels(gdlcode "Region FE" country#year "Country-Year FE")
esttab model57 model58 model59 model60 model61 model62 model63 model64, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)


/// COUNTRY DATASET
clear
est clear
cd C:\Users\fstev\mthesis
use data_iso.dta
encode iso_code, g(country)
xtset country year
drop index

/// Summary Table

estpost summarize iwipov50 regpopm ln_pop steel ln_steel total oda oof transport health educ energy comms total_d oda_d oof_d transport_d health_d educ_d energy_d comms_d total_p oda_p oof_p transport_p health_p educ_p energy_p comms_p amount_total amount_oda amount_oof amount_transport
est store summarytable_iso
esttab summarytable_iso using summarytable_iso.rtf, replace cells("count mean sd min max") noobs nonum

/// Table 8: Country Level total ODA OOF (dummies)

* Reduced form
reghdfe iwipov50 c.L3.ln_steel#c.total_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model1
reghdfe iwipov50 c.L3.ln_steel#c.oda_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model2
reghdfe iwipov50 c.L3.ln_steel#c.oof_p ln_pop, absorb(i.country i.year) vce(robust)
estimates store model3

* 2SLS (dummies)
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) ln_pop, absorb(country year) cluster(country) first
estimates store model4
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) ln_pop, absorb(country year) cluster(country) first
estimates store model5
ivreghdfe iwipov50 (L2.oof_d = c.L3.ln_steel#c.oof_p) ln_pop, absorb(country year) cluster(country) first
estimates store model6

* 1st stage regression (dummies)
reghdfe L2.total_d c.L3.ln_steel#c.total_p ln_pop, absorb(country year) cluster(country)
estimates store model7
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p ln_pop, absorb(country year) cluster(country)
estimates store model8
reghdfe L2.oof_d c.L3.ln_steel#c.oof_p ln_pop, absorb(country year) cluster(country)
estimates store model9

* Table 8: Conutry Level 1
estfe model*, labels(country "Country FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 model9, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 9: Country Level Top 5 Sectors (dummies)

ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) ln_pop, absorb(country year) cluster(country) first
estimates store model10
ivreghdfe iwipov50 (L2.health_d = c.L3.ln_steel#c.health_p) ln_pop, absorb(country year) cluster(country) first
estimates store model11
ivreghdfe iwipov50 (L2.educ_d = c.L3.ln_steel#c.educ_p) ln_pop, absorb(country year) cluster(country) first
estimates store model12
ivreghdfe iwipov50 (L2.energy_d = c.L3.ln_steel#c.energy_p) ln_pop, absorb(country year) cluster(country) first
estimates store model13
ivreghdfe iwipov50 (L2.comms_d = c.L3.ln_steel#c.comms_p) ln_pop, absorb(country year) cluster(country) first
estimates store model14

reghdfe L2.transport_d c.L3.ln_steel#c.transport_p ln_pop, absorb(country year) cluster(country)
estimates store model15
reghdfe L2.health_d c.L3.ln_steel#c.health_p ln_pop, absorb(country year) cluster(country)
estimates store model16
reghdfe L2.educ_d c.L3.ln_steel#c.educ_p ln_pop, absorb(country year) cluster(country)
estimates store model17
reghdfe L2.energy_d c.L3.ln_steel#c.energy_p ln_pop, absorb(country year) cluster(country)
estimates store model18
reghdfe L2.comms_d c.L3.ln_steel#c.comms_p ln_pop, absorb(country year) cluster(country)
estimates store model19

* Table 9: Conutry Level top 5 sectors
estfe model*, labels(country "Country FE" year "Year FE")
esttab model10 model11 model12 model13 model14 model15 model16 model17 model18 model19, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 10: Country Level total ODA OOF (counts)

* 2SLS (dummies)
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) ln_pop, absorb(country year) cluster(country) first
estimates store model10
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) ln_pop, absorb(country year) cluster(country) first
estimates store model11
ivreghdfe iwipov50 (L2.oof = c.L3.ln_steel#c.oof_p) ln_pop, absorb(country year) cluster(country) first
estimates store model12

* 1st stage regression (dummies)
reghdfe L2.total c.L3.ln_steel#c.total_p ln_pop, absorb(country year) cluster(country)
estimates store model13
reghdfe L2.oda c.L3.ln_steel#c.oda_p ln_pop, absorb(country year) cluster(country)
estimates store model14
reghdfe L2.oof c.L3.ln_steel#c.oof_p ln_pop, absorb(country year) cluster(country)
estimates store model15

* Table 10: Conutry Level 1
estfe model*, labels(country "Country FE" year "Year FE")
esttab model10 model11 model12 model13 model14 model15 using table10.rtf, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)

/// Table 11: Country Level Top 5 Sectors (counts)

ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) ln_pop, absorb(country year) cluster(country) first
estimates store model16
ivreghdfe iwipov50 (L2.health = c.L3.ln_steel#c.health_p) ln_pop, absorb(country year) cluster(country) first
estimates store model17
ivreghdfe iwipov50 (L2.educ = c.L3.ln_steel#c.educ_p) ln_pop, absorb(country year) cluster(country) first
estimates store model18
ivreghdfe iwipov50 (L2.energy = c.L3.ln_steel#c.energy_p) ln_pop, absorb(country year) cluster(country) first
estimates store model19
ivreghdfe iwipov50 (L2.comms = c.L3.ln_steel#c.comms_p) ln_pop, absorb(country year) cluster(country) first
estimates store model20

reghdfe L2.transport c.L3.ln_steel#c.transport_p ln_pop, absorb(country year) cluster(country)
estimates store model21
reghdfe L2.health c.L3.ln_steel#c.health_p ln_pop, absorb(country year) cluster(country)
estimates store model22
reghdfe L2.educ c.L3.ln_steel#c.educ_p ln_pop, absorb(country year) cluster(country)
estimates store model23
reghdfe L2.energy c.L3.ln_steel#c.energy_p ln_pop, absorb(country year) cluster(country)
estimates store model24
reghdfe L2.comms c.L3.ln_steel#c.comms_p ln_pop, absorb(country year) cluster(country)
estimates store model25

* Table 11: Conutry Level top 5 sectors (counts)
estfe model*, labels(country "Country FE" year "Year FE")
esttab model16 model17 model18 model19 model20 model21 model22 model23 model24 model25 using table11.rtf, replace indicate(`r(indicate_fe)') nocons obslast compress se star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(ln_pop)
