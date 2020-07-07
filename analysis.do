*******************************
** china_devprojects_poverty **
*******************************

* 2SLS strategy for determining effect of Chinese development projects on poverty in the short run

* Strategy adopted from Dreher et al. (2017;
*		https://www.aiddata.org/publications/aid-china-and-growth-evidence-from-a-new-global-development-finance-dataset

* https://github.com/frankstevens1/china_devprojects_poverty
* July 2020, Frank Stevens: fstevens92@gmail.com

*******************************************************************************
** A. Main Regressions: OLS, Reduced Form, 2SLS & 1st Stage (Regional Level) **
*******************************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index
egen regyear = concat(GDLCODE year)

* Ouliers, influence is minimal!
*drop if regyear == "BWAr1102001"
*drop if regyear == "BWAr1022001"
*drop if regyear == "SENr1082015"
*drop if regyear == "KGZr1042014"
*drop if regyear == "KGZr1022014"
*drop if regyear == "MUSr1012011"

* Histogram of independant variable: iwipov50
hist iwipov50

** A1. OLS
reghdfe iwipov50 L2.total L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.oof L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model3

** A2. reduced form
reghdfe iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model4
reghdfe iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.oof_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model6

* Table 1: OLS & Reduced Form (Main Regressions)
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(L.iwipov50)

** A3. 2SLS
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year, resid(r1)) cluster(country) first
estimates store model7
predict yhat1, xb
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.oof = c.L3.ln_steel#c.oof_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model9
* DEPVAR = SHDI
ivreghdfe shdi (L2.total = c.L3.ln_steel#c.total_p) L1.shdi , absorb(gdlcode year, resid(r2)) cluster(country) first
predict yhat2, xb
estimates store model10
ivreghdfe shdi (L2.oda = c.L3.ln_steel#c.oda_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model11
ivreghdfe shdi (L2.oof = c.L3.ln_steel#c.oof_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model12

** A4. 1st stage regression
reghdfe L2.total c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model13
reghdfe L2.oda c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model14
reghdfe L2.oof c.L3.ln_steel#c.oof_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model15
 
* Table 2: 2SLS & 1st Stage (Main Regressions)
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 model13 model14 model15, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf N_clust) order(L.iwipov50 L.shdi) 

** Plot 1 & 2: Residuals- & Actual vs Predicted Values:
*** iwipov50
scatter r1 yhat1, xline(0) yline(0)
scatter iwipov50 yhat1 || lfit iwipov50 yhat1
*** shdi
scatter r2 yhat2, xline(0) yline(0)
scatter shdi yhat2 || lfit shdi yhat2


************************************************************************************
** B. Secondary Regressions: OLS, Reduced Form, 2SLS & 1st Stage (National Level) **
************************************************************************************

*** Prepare dataset & variables (National Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data_iso.dta
encode iso_code, g(country)
xtset country year
drop index
egen countryyear = concat(country year)

* Histogram of independant variable: iwipov50
hist iwipov50

** B1. OLS
xtreg iwipov50 L2.total L1.iwipov50, fe vce(cluster country)
estimates store model1
xtreg iwipov50 L2.oda L1.iwipov50, fe vce(cluster country)
estimates store model2
xtreg iwipov50 L2.oof L1.iwipov50, fe vce(cluster country)
estimates store model3

** B2. reduced form
xtreg iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50, fe vce(cluster country)
estimates store model4
xtreg iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50, fe vce(cluster country)
estimates store model5
xtreg iwipov50 c.L3.ln_steel#c.oof_p L1.iwipov50, fe vce(cluster country)
estimates store model6

* Table 3: OLS & Reduced Form (National Regressions)
esttab model1 model2 model3 model4 model5 model6, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a N_clust) order(L.iwipov50)

** B3. 2SLS
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) L1.iwipov50, absorb(country year, resid(r1)) cluster(country) first
predict yhat1, xb
estimates store model7
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) L1.iwipov50, absorb(country year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.oof = c.L3.ln_steel#c.oof_p) L1.iwipov50, absorb(country year) cluster(country) first
estimates store model9
* DEPVAR = SHDI
ivreghdfe shdi (L2.total = c.L3.ln_steel#c.total_p) L1.shdi, absorb(country year, resid(r2) cluster(country) first
predict yhat2, xb
estimates store model10
ivreghdfe shdi (L2.oda = c.L3.ln_steel#c.oda_p) L1.shdi, absorb(country year) cluster(country) first
estimates store model11
ivreghdfe shdi (L2.oof = c.L3.ln_steel#c.oof_p) L1.shdi, absorb(country year) cluster(country) first
estimates store model12

** B4. 1st stage regression
reghdfe L2.total c.L3.ln_steel#c.total_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model13
reghdfe L2.oda c.L3.ln_steel#c.oda_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model14
reghdfe L2.oof c.L3.ln_steel#c.oof_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model15
 
* Table 4: 2SLS & 1st Stage (National Regressions)
esttab model7 model8 model9 model10 model11 model12 model13 model14 model15, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf cdf N_clust) order(L.iwipov50 L.shdi) 

** Plot 1 & 2: Residuals- & Actual vs Predicted Values:
scatter r2 yhat2, xline(0) yline(0)
scatter iwipov50 yhat2 || lfit iwipov50 yhat2


********************************************************************************
** C. Secondary Regressions (Top5 Sectors): 2SLS & 1st Stage (Regional Level) **
********************************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index
egen regyear = concat(GDLCODE year)

** C1. 2SLS
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model7
ivreghdfe iwipov50 (L2.health = c.L3.ln_steel#c.health_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.educ = c.L3.ln_steel#c.educ_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model9
ivreghdfe iwipov50 (L2.energy = c.L3.ln_steel#c.energy_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model10
ivreghdfe iwipov50 (L2.comms = c.L3.ln_steel#c.comms_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model11
* DEPVAR = SHDI
ivreghdfe shdi (L2.transport = c.L3.ln_steel#c.transport_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model12
ivreghdfe shdi (L2.health = c.L3.ln_steel#c.health_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model13
ivreghdfe shdi (L2.educ = c.L3.ln_steel#c.educ_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model14
ivreghdfe shdi (L2.energy = c.L3.ln_steel#c.energy_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model15
ivreghdfe shdi (L2.comms = c.L3.ln_steel#c.comms_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model16

* Table 5: 2SLS (Top5 Regressions)
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 model13 model14 model15 model16, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf N_clust) order(L.iwipov50 L.shdi)
 
 ** C2. 1st stage regression
reghdfe L2.transport c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model17
reghdfe L2.health c.L3.ln_steel#c.health_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model18
reghdfe L2.educ c.L3.ln_steel#c.educ_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model19
reghdfe L2.energy c.L3.ln_steel#c.energy_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model20
reghdfe L2.comms c.L3.ln_steel#c.comms_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model21

* Table 6: 1st Stage (Top5 Regressions)
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model17 model18 model19 model20 model21, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf N_clust) order(L.iwipov50)
 
********************************************************************************
** D. Secondary Regressions (Project Values): 2SLS & 1st Stage (Regional Level) **
********************************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
xtset gdlcode year
encode ISO_Code, g(country)
drop index
egen regyear = concat(GDLCODE year)

** C1. 2SLS
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.ln_total_amount = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model7
ivreghdfe iwipov50 (L2.ln_oda_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.ln_oof_amount = c.L3.ln_steel#c.oof_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model9
ivreghdfe iwipov50 (L2.ln_transport_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model10
* DEPVAR = SHDI
ivreghdfe shdi (L2.ln_total_amount = c.L3.ln_steel#c.total_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model11
ivreghdfe shdi (L2.ln_oda_amount = c.L3.ln_steel#c.oda_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model12
ivreghdfe shdi (L2.ln_oof_amount = c.L3.ln_steel#c.oof_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model13
ivreghdfe shdi (L2.ln_transport_amount = c.L3.ln_steel#c.transport_p) L1.shdi , absorb(gdlcode year) cluster(country) first
estimates store model14

* Table 2: 2SLS (Amount Regressions)
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 model13 model14, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a rkf N_clust) order(L.iwipov50 L.shdi)
