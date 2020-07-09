*******************************
** china_devprojects_poverty **
*******************************

* 2SLS strategy for determining short term impact of Chinese development projects on poverty
* Strategy adopted from Dreher et al. (2017; https://bit.ly/2ZJBmJ1

* July 2020, Frank Stevens: fstevens92@gmail.com
* https://github.com/frankstevens1/china_devprojects_poverty

* Written for Stata 15.1
* Install requirements:
do C:\Users\fstev\china_devprojects_poverty\stata_do\stata_req.do

*******************************************************************************
** A. Main Regressions: OLS, Reduced Form, 2SLS & 1st Stage (Regional Level) **
*******************************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
encode ISO_Code, g(country)
egen regyear = concat(GDLCODE year)
* outliers (62)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do
xtset gdlcode year
drop index

* Histogram of independant variable: iwipov50
hist iwipov50

** A1. OLS
*** iwipov50
reghdfe iwipov50 L2.total L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.transport L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model3
** A2. Reduced Form
reghdfe iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model4
reghdfe iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model6

* Table 1: OLS & Reduced Form (Main Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 using table1.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a_within N_clust N_full) order(L.iwipov50)

** A3. 2SLS
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year, resid(r1)) cluster(country) first
estimates store model7
predict yhat1, xb
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model9
** A4. 1st stage regression
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
reghdfe L2.total c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model10
reghdfe L2.oda c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model11
reghdfe L2.transport c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model12
 
* Table 2: 2SLS & 1st Stage (Main Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 using table2.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50) 

** Plot 1 & 2: Residuals- & Actual vs Predicted Values:
*** 2SLS
scatter r1 yhat1, xline(0) xline(1) yline(0)
scatter iwipov50 yhat1, || lfit iwipov50 yhat1

************************************************************************************
** B. Secondary Regressions: OLS, Reduced Form, 2SLS & 1st Stage (National Level) **
************************************************************************************

*** Prepare dataset & variables (National Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data_iso.dta
encode iso_code, g(country)
egen countryyear = concat(iso_code year)
* outliers (27)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers_iso.do
xtset country year
drop index

* Histogram of independant variable: iwipov50
hist iwipov50

** B1. OLS 
*** iwipov50
reghdfe iwipov50 L2.total L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.transport L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model3
** B2. reduced form
reghdfe iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model4
reghdfe iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.transport_p L1.iwipov50, absorb(country year) vce(cluster country)
estimates store model6

* Table 3: OLS (National Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
esttab model1 model2 model3 model4 model5 model6 using table3.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_within N_clust N_full) order(L.iwipov50)

** B3. 2SLS
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) L1.iwipov50, absorb(country year, resid(r1)) cluster(country) first
predict yhat1, xb
estimates store model7
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) L1.iwipov50, absorb(country year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) L1.iwipov50, absorb(country year) cluster(country) first
estimates store model9
** B4. 1st stage regression
reghdfe L2.total c.L3.ln_steel#c.total_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model10
reghdfe L2.oda c.L3.ln_steel#c.oda_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model11
reghdfe L2.transport c.L3.ln_steel#c.transport_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model12
 
* Table 4: 2SLS & 1st Stage (National Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
esttab model7 model8 model9 model10 model11 model12 using table4.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50) 

** Plot 4 & 5: Residuals- & Actual vs Predicted Values:
scatter r1 yhat1, xline(0) xline(1) yline(0)
scatter iwipov50 yhat1, || lfit iwipov50 yhat1


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

do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do

** C1. 2SLS
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.health = c.L3.ln_steel#c.health_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model1
ivreghdfe iwipov50 (L2.educ = c.L3.ln_steel#c.educ_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model2
ivreghdfe iwipov50 (L2.energy = c.L3.ln_steel#c.energy_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model3
ivreghdfe iwipov50 (L2.comms = c.L3.ln_steel#c.comms_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model4
* Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
reghdfe L2.health c.L3.ln_steel#c.health_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model5
reghdfe L2.educ c.L3.ln_steel#c.educ_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model6
reghdfe L2.energy c.L3.ln_steel#c.energy_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model7
reghdfe L2.comms c.L3.ln_steel#c.comms_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model8

* Table 5: 2SLS (Top5 Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 using table5.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)
 
***********************************************************************
** D. Alternate ivar forms: project values & dummies(Regional Level) **
***********************************************************************

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

do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do

** D1. Amounts
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.ln_total_amount = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model1
ivreghdfe iwipov50 (L2.ln_oda_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model2
ivreghdfe iwipov50 (L2.ln_transport_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model3
** D2. Dummies
* Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year, resid(r1)) cluster(country) first
estimates store model4
predict yhat1, xb
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model5
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model6

* Table 6: 2SLS (Amounts & Dummies Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 using table6.rtf, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)
