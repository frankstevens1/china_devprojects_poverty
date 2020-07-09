![alt text](https://steelguru.com/uploads/news/belt_and_road_development_initiate_between_china_and_africa_59480.jpg)

# china_devprojects_poverty
Studying the influence of Chinese development projects on sub-national poverty levels around the world.

## Contents
- Introduction
- Data
- Empirical strategy
- Results
- Reproducing the dataset
- Reproducing the analysis

## Introduction

... to be added.

## Data

1. [AidData's Geocoded Global Chinese Official Finance](https://www.aiddata.org/data/geocoded-chinese-global-official-finance-dataset) - A dataset of 3,485 Chinese development projects committed between 2000-2014 globally. The following variables are generated from this data:
  - *CnAid <sub>irt</sub> Dummy* : Commitment in year *t* of at least 1 development project destined for sub-national region *r* in country *i*, classified by CRS<sup>[1](#CRS)</sup> sectors & flow types.
  - *CnAid <sub>irt</sub> Count* : Number of projects committed in year *t* destined for sub-national region *r* in country *i*, classified by CRS sector (purpose) & flow type.
  - *p<sub>ir</sub>* : The probability of region *r* in country *i* receiving a project, calculated as the fraction of years a region received a project over the period 2000-2014. Varies only across regions not over time.


2. [Global Data Lab's (GDL) subnational socio-economic indicators](https://globaldatalab.org/areadata/) - Database of socio-economic, demographic and health indicators for sub-national regions within low- and middle-income countries. The GDL data used are asset based poverty measures and population figures. All indicators are inter- and extrapolated to 3 years.

  - *IWI <sub>irt</sub>* : Mean [International Wealth Index (IWI)](https://link.springer.com/article/10.1007%2Fs11205-014-0683-x#page-1) of region *r* in country *i* in year *t*. An asset based wealth index that runs from 0 (none of the tracked assets and lowest quality of housing) to 100 (all of the tracked assets and highest quality of housing).
  - *iwipov50 <sub>irt</sub>* : Percentage of households in region *r* in country *i* below an *IWI* value of 50 in year *t*. A poverty indicator that is strongly correlated with poverty headcount ratio at $2.00 a day.
  - *regpopm <sub>irt</sub>* : Total population in region *r* of country *i* in year *t* (millions)
  - *hhsize <sub>irt</sub>* : Mean household size in region *r* of country *i* in year *t*
  - *hhpov50 <sub>irt</sub>* = (*regpopm <sub>irt</sub>* / *hhsize <sub>irt</sub>*) x *iwipov50 <sub>irt</sub>*: Total households under the IWI poverty level of 50 in region *r* of country *i* in year *t* (millions).

[SHDI](https://www.nature.com/articles/sdata201938)

3. [World Steel Association Statistical Yearbooks](https://www.worldsteel.org/steel-by-topic/statistics/steel-statistical-yearbook.html) - Presents a cross-section of steel industry statistics. Yearbooks  2000, 2010, 2018 & 2019 were used.
  - *steel <sub>t</sub>* : Total production of crude steel in year *t* (thousand tonnes)
  - *export <sub>t</sub>* : Indirect steel exports in year *t* (thousand tonnes)


##### Notes:
<a name="CRS">1</a> - Common reporting standard used by participating donors to report their aid flows to the Development Assistance Committee (DAC) databases. China and many other non-DAC donors do not participate, but AidData researchers have classified Chinese financial flows according to these standards.

## Empirical strategy
This study follows an approach initially developed by [Dreher et al. (2017)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3051044) to investigate the effects of Chinese aid projects on economic growth.

To determine the effect of Chinese development assistance on regional poverty levels, the dependant variable used is the percentage of households in a region that are below the poverty line. [Smits & Steendijk (2015)](https://link.springer.com/article/10.1007/s11205-014-0683-x) have demonstrated the effectiveness of IWI in measuring poverty, with an impressive Pearson’s correlation of 0.914 between national percentages of households with an IWI value below 50 and the World Bank’s Poverty Headcount Ratio at $2.00 a day. Therefore, we define the poverty line as IWI 50, and examine the effects of regions receiving a Chinese development projects through the change in the percentage of households below this level.

The main explanatory variable of interest would ideally be a dollar value committed per region per year, unfortunately comprehensive estimates of dollar values committed per project location are near impossible to estimate (Bluhm et al., 2018). Individual projects often fall under an umbrella investment and AidData then splits these data evenly across project locations. For this reason, this study follows Bluhm et al. (2018) who suggest that a dummy variable indicating the presence of development projects is preferred. A project count variable is employed in secondary regressions, which can be interpreted as a robustness check of the significance, direction, and magnitude of the effect. However, both forms of the explanatory variable suffer from a simultaneity bias. Given that in order for the subnational allocation of development projects to “make great efforts to ensure benefits for as many needy people as possible” (State Council, 2014) it is bound to be based on regional poverty levels. Following Bluhm et al. (2018) the empirical strategy addresses this issue by employing a two stage least squares (2SLS) approach with a shift-share style instrument to study the impact of Chinese infrastructure projects on the diffusion of economic activity in developing countries. The strategy exploits two sources of variations. First, the plausibly exogenous time variation in Chinese steel production, which is a supply-driven component of the explanatory variable of interest – Chinese development assistance (CnAid). With this setup the main results will be interpreted as the local average treatment effect (LATE) of Chinese development projects induced by domestic overproduction of steel on regional poverty across recipients. China’s steel production has long been considered as strategic industry that drove their rapid economic growth and as demand slows the industry is producing surpluses which are driving exports, see *figure 2*. Additionally, China’s development assistance rarely involves bilateral financial transfer and are instead delivered in kind, as exports of Chinese goods & materials, complete projects and technical cooperation (Bräutigam, 2011; State Council, 2014; Zhang et al., 2015). Therefore, steel is expected to be a relevant instrument for Chinese development assistance, particularly in the form of infrastructure projects. *Figure 3* shows the correlation between Chinese steel production and total dollar value of development assistance committed in the following year to demonstrate this relationship. A 1-year lag of steel production allows for surpluses to translate to international development projects.

This identification strategy relies on the interaction term being exogenous and assumes that a change in Chinese steel production does not lead to a change in the likelihood of receiving development projects between regular regions and irregular regions. An assumption that appears to be realistic. Additionally, Bluhm et al. (2018) examine this assumption in detail by examining the variation in steel production along variations in the location of projects for different quartiles of probabilities to receive projects and conclude that there is no reason to believe the assumption is violated. A limitation of this strategy is that it relies on annual variation as well as a large sample for instrument strength. In combination with a dataset which spans only 15 years the analysis is limited to the use of annual data instead of data averaged over several periods. This means that the results will be interpreted as short term effects, unlike typical aid effectiveness literature. Another difference is the lack of control variables available at subnational level, such as institutional quality. Therefore, the specification relies on multiple fixed effects to absorb a wider variety of potential sources of variation and isolate the effect of development projects. REGHDFE, a Stata module developed by [Correia (2017)](https://ideas.repec.org/c/boc/bocode/s457874.html) is employed to fit 2SLS regression while absorbing multiple fixed effects and clustering standard errors at the country level to account for within country spillover effects. Regional fixed effects and country-year fixed effects, which absorbs shocks that affect all regions of a country similarly in a particular year.



## Results

... to be added.

## Reproducing the dataset

Notebooks detailing the process of wrangling and cleaning the data to produce the final dataset can be viewed using the links:
  1. Region level dataset *data.dta*: [dataset_prep.ipynb](dataset_prep.ipynb) or using [nbviewer](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep.ipynb)
  2. Country level dataset *data_iso.dta*: [dataset_prep_iso.ipynb](dataset_prep_iso.ipynb) or using [nbviewer](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep_iso.ipynb)

#### Python Packages
Python 3.8 on Windows was used to create the dataset used in the analysis. Reproducing the dataset requires the packages listed in *requirements.txt*.

From the command prompt (cmd):
1. Install virtual environment manager:
```
pip install virtualenv
```
2. Install JupyterLab (or skip step and use preferred notebook interpreter):
```
pip install jupyterlab
```
3. Change to the repository *china_devprojects_poverty* downloaded or cloned from https://github.com/frankstevens1/china_devprojects_poverty:
```
cd C:\Users\...\china_devprojects_poverty
```
4. Create python virtual environment (cdpenv is the name given the the environment):
```
vitualenv cdpenv
```
5. Activate virtual environment:
```
.\cdpenv\Scripts\activate
```
6. Install all packages from *requirements.txt*:
```
pip install -r requirements.txt --upgrade
```
**For some dependencies (GDAL, fiona & Rtree) installation via pip may fail, but they can be installed from .whl files saved in the** *china_devprojects_poverty/dependencies* **directory.**
*Note: the .whl files save in the dependencies directory are for windows 64bit systems, for other systems the appropriate .whl file can be downloaded from:*
* [GDAL](https://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal)
* [fiona](https://www.lfd.uci.edu/~gohlke/pythonlibs/#fiona)
* [Rtree](https://www.lfd.uci.edu/~gohlke/pythonlibs/#rtree)

7. Install GDAL dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\GDAL-3.0.4-cp38-cp38-win_amd64.whl
```
8. Install Fiona dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\Fiona-1.8.13-cp38-cp38-win_amd64.whl
```
9. Install Rtree dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\Rtree-0.9.4-cp38-cp38-win_amd64.whl
```
10. Setup ipyknernel to recognize cdpenv, the virtual environment that now has all required dependencies to run *dataset_prep_v2.ipynb*:
```
python -m ipykernel install --name=cdpenv
```
#### Stata Packages:
The analysis is done using Stata 15, the regession results can be reproduced using *analysis.do*. The analysis requires adding multiple levels of fixed effects, this has been made possible by Sergio Correia's (IV)REGHDFE, more info can be found on the developer's [page](http://scorreia.com/software/reghdfe/index.html).

## Reproducing the analysis:
The analysis is done using Stata 15, the regession results can be reproduced using *analysis.do*. The analysis requires adding multiple levels of fixed effects, this has been made possible by Sergio Correia's (IV)REGHDFE, more info can be found on the developer's [page](http://scorreia.com/software/reghdfe/index.html).

### Dependencies: Stata Packages
1. (IV)REGHDFE and requirements can be installed from SSC *stata_req.do* contains all the package requirements to install & use (IV)REGHDFE:
```
cd C:\Users\...\china_devprojects_poverty
do stata_req.do
```
