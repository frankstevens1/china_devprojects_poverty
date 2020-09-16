*******************************
** china_devprojects_poverty **
*******************************

* 2SLS strategy for determining short term impact of Chinese development projects on poverty
* Strategy adopted from Dreher et al. (2017; https://bit.ly/2ZJBmJ1

* Tables & figures are numbered as they appear in the text: china_devprojects_poverty.pdf
* Sections A - D can be run seperately to view all all unformatted tables within the ouput screen

* July 2020, Frank Stevens: fstevens92@gmail.com
* https://github.com/frankstevens1/china_devprojects_poverty

* Written for Stata 15.1
* Install requirements:
// do C:\Users\fstev\china_devprojects_poverty\stata_do\stata_req.do

**********************************************************************************************
** A. Main Regressions (tables 3 & 4): OLS, Reduced Form, 2SLS & 1st Stage (Regional Level) **
**********************************************************************************************

** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
encode ISO_Code, g(country)
egen regyear = concat(GDLCODE year)
*** outliers (62)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do

** reduce to time period with observed values
drop if year < 2000
drop if year > 2014

xtset gdlcode year
drop index

** Table 3 Columsn 1-3: OLS
reghdfe iwipov50 L2.total_d L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda_d L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.transport_d L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model3
** Table 3 Columns 4-6: Reduced Form
reghdfe iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model4
reghdfe iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(gdlcode year) vce(cluster country)
estimates store model6

** Table 4 Columns 1-3: 2SLS
*** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year, resid(r1)) cluster(country) first
estimates store model7
predict yhat1, xb
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model9
** Table 4 COlumns 4-6: 1st stage regression
*** Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
reghdfe L2.total_d c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model10
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model11
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model12

** Check influence of < 0 predicted values
drop if yhat1 < 0
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model13

** OUPUT ** Table 3: OLS & Reduced Form (Subnational Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_a_within N_clust N_full) order(L.iwipov50)

** OUPUT ** Table 4: 2SLS & 1st Stage (Subnational Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)

** OUPUT ** Table 9: Summary Statistics
quietly estpost summarize iwipov50 total_d oda_d transport_d total oda transport steel ln_steel /// 
	total_amount oda_amount transport_amount /// 
	total_p oda_p transport_p health_p educ_p energy_p comms_p
cd C:\Users\fstev\china_devprojects_poverty\tables
esttab . , cells("count mean sd min max") nonumber noobs replace

** OUTPUT ** Table 10: Predicted values < 0
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model9 model13 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)
 
** OUPUT ** Figure 7: Histogram Dependant Variable
hist iwipov50
 
** OUTPUT ** Figure 8: Residuals- & Actual vs Predicted Values (2SLS):
scatter r1 yhat1, xline(0) xline(1) yline(0)
scatter iwipov50 yhat1, || lfit iwipov50 yhat1

***************************************************************************************************
** B. Secondary Regressions (tables 5 & 6): OLS, Reduced Form, 2SLS & 1st Stage (National Level) **
***************************************************************************************************

** Prepare dataset & variables (National Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data_iso.dta
encode iso_code, g(country)
egen countryyear = concat(iso_code year)
*** outliers (27)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers_iso.do

** reduce to time period with observed values
drop if year < 2000
drop if year > 2014

xtset country year
drop index
g ln_fdi = log(fdi)


** Table 5 Columns 1-3: OLS 
reghdfe iwipov50 L2.total_d L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model1
reghdfe iwipov50 L2.oda_d L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model2
reghdfe iwipov50 L2.transport_d L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model3
** Table 5 Columns 4-6: reduced form
reghdfe iwipov50 c.L3.ln_steel#c.total_p L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model4
reghdfe iwipov50 c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model5
reghdfe iwipov50 c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(country year) vce(cluster country)
estimates store model6
 
** Table 6 Columns 1-3: 2SLS
*** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total_d = c.L3.ln_steel#c.total_p) L1.iwipov50, absorb(country year, resid(r1)) cluster(country) first
predict yhat1, xb
estimates store model7
ivreghdfe iwipov50 (L2.oda_d = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(country year) cluster(country) first
estimates store model8
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) L1.iwipov50, absorb(country year) cluster(country) first
estimates store model9
** Table 6 Columns 4-6: 1st stage regression
*** Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
reghdfe L2.total_d c.L3.ln_steel#c.total_p L1.iwipov50, absorb(country year) cluster(country)
estimates store model10
reghdfe L2.oda_d c.L3.ln_steel#c.oda_p L1.iwipov50 , absorb(country year) cluster(country)
estimates store model11
reghdfe L2.transport_d c.L3.ln_steel#c.transport_p L1.iwipov50 , absorb(country year) cluster(country)
estimates store model12
** Table 6 Column 7: Robustness check (addition of FDI)
ivreghdfe iwipov50 (L2.transport_d = c.L3.ln_steel#c.transport_p) L1.iwipov50 L2.ln_fdi, absorb(country year) cluster(country) first
estimates store model13

** OUTPUT ** Table 5: OLS (National Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(country "Country FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se ///
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(r2_within N_clust N_full) order(L.iwipov50)

** OUTPUT ** Table 6: 2SLS & 1st Stage (National Regressions)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(country "Country FE" year "Year FE")
esttab model7 model8 model9 model10 model11 model12 model13 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50 L2.ln_fdi)
 
** OUTPUT ** Table 10: Summary Statistics
quietly estpost summarize iwipov50 total_d oda_d transport_d total oda transport steel ln_steel /// 
	total_amount oda_amount transport_amount /// 
	total_p oda_p transport_p health_p educ_p energy_p comms_p fdi ln_fdi
cd C:\Users\fstev\china_devprojects_poverty\tables
esttab . , cells("count mean sd min max") nonumber noobs replace

** (Not Reported) histogram independant variable
// hist iwipov50

** NOT REPORTED ** Residuals- & Actual vs Predicted Values (National Level):
// scatter r1 yhat1, xline(0) xline(1) yline(0)
// scatter iwipov50 yhat1, || lfit iwipov50 yhat1

********************************************************************************
** C. Secondary Regressions (Top5 Sectors): 2SLS & 1st Stage (Regional Level) **
********************************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
encode ISO_Code, g(country)
egen regyear = concat(GDLCODE year)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do

** reduce to time period with observed values
drop if year < 2000
drop if year > 2014

xtset gdlcode year
drop index

** Table 7 Columns 1-4: 2SLS
*** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.health_d = c.L3.ln_steel#c.health_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model1
ivreghdfe iwipov50 (L2.educ_d = c.L3.ln_steel#c.educ_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model2
ivreghdfe iwipov50 (L2.energy_d = c.L3.ln_steel#c.energy_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model3
ivreghdfe iwipov50 (L2.comms_d = c.L3.ln_steel#c.comms_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model4
** Table 7 Columns 5-8: 1st Stage
*** Stage 1: 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2)=(𝑆𝑡𝑒𝑒𝑙𝑡−3×𝑝𝑖𝑟)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝑢𝑖𝑟+𝜔𝑖(𝑡−2)+𝑣𝑖𝑟(𝑡−2)
reghdfe L2.health_d c.L3.ln_steel#c.health_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model5
reghdfe L2.educ_d c.L3.ln_steel#c.educ_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model6
reghdfe L2.energy_d c.L3.ln_steel#c.energy_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model7
reghdfe L2.comms_d c.L3.ln_steel#c.comms_p L1.iwipov50 , absorb(gdlcode year) cluster(country)
estimates store model8

** OUPUT ** Table 7: 2SLS (Top5 Sectors)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8 , ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)
 
***********************************************************************
** D. Alternate ivar forms: project values & counts (Regional Level) **
***********************************************************************

*** Prepare dataset & variables (Regional Level):
clear
est clear
cd C:\Users\fstev\china_devprojects_poverty
use data.dta
encode GDLCODE, g(gdlcode)
encode ISO_Code, g(country)
egen regyear = concat(GDLCODE year)
do C:\Users\fstev\china_devprojects_poverty\stata_do\outliers.do

** reduce to time period with observed values
drop if year < 2000
drop if year > 2014

xtset gdlcode year
drop index

** Table 8 Columns 1-3: Amounts
*** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.ln_total_amount = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model1
ivreghdfe iwipov50 (L2.ln_oda_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model2
ivreghdfe iwipov50 (L2.ln_transport_amount = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model3
ivreghdfe iwipov50 (L2.ln_energy_amount = c.L3.ln_steel#c.energy_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model4
** Table 8 Columns 4-6: Counts
*** Stage 2: 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡=𝛽𝐶𝑛𝐴𝑖𝑑𝑖(𝑡−2)+𝑟𝑒𝑔𝑝𝑜𝑝𝑚𝑖𝑟𝑡+𝜇𝑖𝑟+𝜆𝑖𝑡+𝜖𝑖𝑟𝑡
ivreghdfe iwipov50 (L2.total = c.L3.ln_steel#c.total_p) L1.iwipov50 , absorb(gdlcode year, resid(r1)) cluster(country) first
estimates store model5
predict yhat1, xb
ivreghdfe iwipov50 (L2.oda = c.L3.ln_steel#c.oda_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model6
ivreghdfe iwipov50 (L2.transport = c.L3.ln_steel#c.transport_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model7
ivreghdfe iwipov50 (L2.energy = c.L3.ln_steel#c.energy_p) L1.iwipov50 , absorb(gdlcode year) cluster(country) first
estimates store model8

** OUPUT ** Table 8: 2SLS (Amounts & Counts)
cd C:\Users\fstev\china_devprojects_poverty\tables
estfe model*, labels(gdlcode "Region FE" year "Year FE")
esttab model1 model2 model3 model4 model5 model6 model7 model8, ///
 replace indicate(`r(indicate_fe)') nocons obslast compress se /// 
 star(* 0.10 ** 0.05 *** 0.01 **** 0.001) scalars(rkf N_clust N_full) order(L.iwipov50)
