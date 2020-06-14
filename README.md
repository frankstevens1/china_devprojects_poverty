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
  The main dependant variable is generated from the variables above as follows:
  - *hhpov50 <sub>irt</sub>* = (*regpopm <sub>irt</sub>* / *hhsize <sub>irt</sub>*) x *iwipov50 <sub>irt</sub>*: Total households under the IWI poverty level of 50 in region *r* of country *i* in year *t* (millions).


3. [World Steel Association Statistical Yearbooks](https://www.worldsteel.org/steel-by-topic/statistics/steel-statistical-yearbook.html) - Presents a cross-section of steel industry statistics. Yearbooks  2000, 2010, 2018 & 2019 were used.
  - *steel <sub>t</sub>* : Total production of crude steel in year *t* (thousand tonnes)
  - *export <sub>t</sub>* : Indirect steel exports in year *t* (thousand tonnes)


##### Notes:
<a name="CRS">1</a> - Common reporting standard used by participating donors to report their aid flows to the Development Assistance Committee (DAC) databases. China and many other non-DAC donors do not participate, but AidData researchers have classified Chinese financial flows according to these standards.

## Empirical strategy
This study follows the approach developed by [Dreher et al. (2017)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3051044) to investigate the effects of Chinese aid projects on economic growth.

... to be added

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
