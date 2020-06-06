# china_devprojects_poverty
Studying the influence of Chinese development projects on sub-national poverty levels around the world.
Python 3.8 on Windows is used for the data wrangling/cleaning process & for generating visualizations.
Stata 15 with additional packages is used for running the regression analysis and generating regression tables.

## Contents

## Introduction
A rapidly expanding aid programme has positioned China amongst the largest international development financiers, has been met with significant international attention. As Chinese engagement with low- and middle income countries intensifies, so does criticism of China's development practices. 


## Data:
The dataset used in the analysis was created by merging variables from the followinng datasources:
* [AidData's Geocoded Global Chinese Official Finance Dataset](https://www.aiddata.org/data/geocoded-chinese-global-official-finance-dataset): tracks global Chinese development projects between 2000-2014
  1. Number of projects per sub-national region by CRS sector & flow type (count variable)
  2. Presence of a project per sub-national region by CRS sector & flow type (bianry variables)
  3. Region's probability of receiving a project (fraction of years a region received a project over the total period tracked)
* [Global Data Lab's (GDL) subnational socio-economic indicators](https://globaldatalab.org/areadata/)
  1. Mean international wealth index (IWI) score of region
  2. Percentage poorer households (with IWI value under 35/50/70)
  3. Total area population in millions
* [Chinese Steel Production Figures](https://www.worldsteel.org/steel-by-topic/statistics/steel-statistical-yearbook.html)
  1. Total production of crude steel in thousand tonnes
 
Two seperate datasets are used, the notebooks detailing the process of wrangling and cleaning the data can be viewed using the links:
1. Region level dataset *data.dta*: [dataset_prep.ipynb](dataset_prep.ipynb) or using nbviewer [dataset_prep.ipynb](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep.ipynb)
2. Country level dataset *data_iso.dta*: [dataset_prep_iso.ipynb](dataset_prep_iso.ipynb) or using nbviewer[dataset_prep_iso.ipynb](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep_iso.ipynb)

## Empirical strategy
Following the approach [Dreher et al. (2017)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3051044) who use a similar approach to study the impact of Chinese infrastructure projects on the diffusion of economic activity. The goal of Chinese development finance is to benefit ‘as many needy people as possible’ - (Information Office of the State Council, 2011), {!!add link to source!!} the sub-national allocation of development projects is expected to be endogenous to poverty rates across and within regions. Using a two stage least squares (2SLS) instrumental variable strategy the endogeneity issue is addressed. Chinese development projects are instrumented by a shift-share style instrument which leverages variation in cross-sectional exposure (share) to exogenous temporal changes (shift). Chinese development projects are primarily large infrastructure projects requiring physical inputs. To proxy for these physical inputs Bluhm et al. (2018) propose the use of China's annual steel production, of which overproduction is used to supply development projects in developing countries. The interaction of annual Chinese steel production and the region’s probability of receiving a development project then makes up the shift-share instrument. The share component is region's exposure to - or the probability of receiving a Chinese financed development project. Calculated as the fraction of the number of years a region had an active project over the total period Chinese development projects are tracked (2000-2014).

{!!} have requirements that goods purchased for them be at least 50 percent of Chinese origin {RAND Report}

## Results

## Dependencies:

### Python Packages
The steps in the data wrangling/cleaning process are detailed in the Jupyter notebook: *dataset_prep.ipynb*

To run *dataset_prep.ipynb*, the packages in *requirements.txt* need to the installed.

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
### Stata Packages:
The analysis requires adding multiple levels of fixed effects, this has been made possible by Sergio Correia's (IV)REGHDFE, more info can be found on the developer's [page](http://scorreia.com/software/reghdfe/index.html).

1. (IV)REGHDFE and requirements can be installed from SSC *stata_req.do* contains all the package requirements to install & use (IV)REGHDFE:
```
cd C:\Users\...\china_devprojects_poverty
do stata_req.do
```
