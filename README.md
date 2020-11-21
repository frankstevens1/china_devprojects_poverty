![alt text](https://steelguru.com/uploads/news/belt_and_road_development_initiate_between_china_and_africa_59480.jpg)

# Chinese Development Projects & Subnational Poverty

This repository contains all the required files and documentation to reproduce a study of the effects of development projects financed by China on subnational poverty levels around the world. The study was conducted as a master's thesis for completion of an MSc in International Economics and Development at the Radboud University of Nijmegen. Selected sections of the thesis are provided below to summarize the study conducted, the full thesis is available [here](thesis_complete.pdf).

### Skip to Section:
- [Introduction](#INTRO)
- [Data](#DATA)
- [Empirical Strategy](#STRAT)
- [Results](#RES)
- [References](#REF)
- [Reproducing the Dataset](#RTD)
- [Reproducing the Analysis](#RTA)

## Introduction <a name="INTRO"></a>

China’s emergence as a development financier presents renewed opportunity to study the impact of investment in infrastructure on global poverty. A preference for investing in connective infrastructure and a willingness to implement projects globally are distinguishing features of China’s policies on aid delivery. This policy decision is reflected by the sectoral composition and geographical location of their development finance. This study employs a 2SLS instrumental regression strategy, introduced by [Dreher et al. (2017)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3051044), that exploits differences in local exposures to a common overproduction shock originating in China’s steel industry to form a shift-share style instrument to study the short-term effects of development projects. Leveraging two sources of variation to determine the local average treatment effect (LATE) of development projects financed by China on subnational poverty levels around the world. Results suggest that infrastructure projects within the transport sector have a significant short-term poverty reducing effect of as high as a 2.8%. Which translates roughly to 18 thousand households lifted out of poverty in an average subnational region 2 years after a transport project is committed. A significant effect that is in line with theoretical considerations and previous empirical studies. This study encourages traditional OECD donors to revaluate the importance of their aid budgets to further global infrastructure development to reduce geographic inequalities.

The aim of this repository is to provide all the required documentation to reproduce the dataset used and the analysis conducted for this study. Data in their original formats as provided by the source are included along with scripts written in Python to clean & merge and compute the variables included in the dataset used. The analysis is carried out using a user written package for Stata, which facilitates the addition of multiple fixed effects for regression & instrumental regression analyses. A Stata syntax file is included for the reproduction of the analysis. The Python and Stata dependencies are listed in *requirements.txt* and *stata_do/stata_req.do* respectively, detailed installation instructions are provided under the sections [Reproducing the Dataset](#RTD) and [Reproducing the Analysis](#RTA).

## Data <a name="DATA"></a>

The dataset used in the study consists of data from 3 different sources used to construct a panel of 1202 subnational regions over 14 years.
The variables from the various sources are defined below.

1. [AidData's Geocoded Global Chinese Official Finance](https://www.aiddata.org/data/geocoded-chinese-global-official-finance-dataset) - A dataset of 3,485 Chinese development projects committed between 2000-2014 globally. Comprising largely of infrastructure projects, primarily in the transport sector. The following variables are generated from this data:

  - *CnAid <sub>irt</sub>* : Commitment in year *t* destined for subnational region *r* in country *i*, classified by CRS<sup>[1](#CRS)</sup> sectors & flow types. The variable can take 3 forms; a dummy indicating the presence of atleast 1 project, a count variable indicating the number of projects, or an estimated dollar value of the total commitment. The preferred variable is the dummy variable.
  - *p<sub>ir</sub>* : The probability of region *r*, in country *i*, receiving a project. Calculated as the fraction of years a region received a project over the period 2000-2014. This variable varies only across regions not over time, and is used as the share in the shift-share instrument employed. Interpreted as a region's local exposure to Chinese development projects.


2. [Global Data Lab's (GDL) subnational socio-economic indicators](https://globaldatalab.org/areadata/) - Database of socio-economic, demographic and health indicators for subnational regions within low- and middle-income countries. GDL hosts and maintains a database of the International Wealth Index (IWI). The first asset based index of household material well-being that is comparable across place & time and applicable to all low an middle income countries [(Smits & Steendijk, 2015)](https://link.springer.com/article/10.1007%2Fs11205-014-0683-x#page-1). The IWI is based on household surveys that are periodically conducted by external organizations ([UNICEF](http://mics.unicef.org/surveys), [USAID](https://www.dhsprogram.com/)) and GDL continually releases IWI data as new rounds of the surveys are published.

  - *IWI <sub>irt</sub>* : Mean [International Wealth Index (IWI)](https://link.springer.com/article/10.1007%2Fs11205-014-0683-x#page-1) of region *r* in country *i* in year *t*. An asset based wealth index that runs from 0 (none of the tracked assets and lowest quality of housing) to 100 (all of the tracked assets and highest quality of housing).
  - *iwipov50 <sub>irt</sub>* : Percentage of households in region *r* in country *i* below an *IWI* value of 50 in year *t*. A poverty indicator that is strongly correlated with the World Bank's poverty headcount ratio at $2.00 a day.


3. [World Steel Association Statistical Yearbooks](https://www.worldsteel.org/steel-by-topic/statistics/steel-statistical-yearbook.html) - Publisher of a cross-section of steel industry statistics. Yearbooks  2000, 2010, 2018 & 2019 are used for this study.

  - *steel <sub>t</sub>* : Total production of crude steel in year *t* (thousand tonnes). This time series is used as the shift in the shift-share instrument employed. Interpreted as an exogenous shock that is highly correlated with the following year's commitments in development finance from China.

###### Notes:
<a name="CRS">1</a> - [Common reporting standard](https://www.oecd.org/dac/financing-sustainable-development/development-finance-standards/dacandcrscodelists.htm) used by participating donors to report their aid flows to the Development Assistance Committee (DAC) databases. China and many other non-DAC donors do not participate, but AidData researchers have classified Chinese financial flows according to these standards.

## Empirical strategy <a name="STRAT"></a>

To determine the effect of Chinese development assistance on regional poverty levels, the dependant variable used is the percentage of households in a region that are below the poverty line. [Smits & Steendijk (2015)](https://link.springer.com/article/10.1007/s11205-014-0683-x) have demonstrated the effectiveness of IWI in measuring poverty, with an impressive Pearson’s correlation of 0.914 between national percentages of households with an IWI value below 50 and the World Bank’s Poverty Headcount Ratio at $2.00 a day. Therefore, we define the poverty line as IWI 50 (iwipov50) and examine the local average treatment effect (LATE) of Chinese development projects on subnational poverty.

Unfortunately, the explanatory variable suffers from a simultaneity bias, because in order for the subnational allocation of development projects to “make great efforts to ensure benefits for as many needy people as possible” [(State Council, 2014)](http://english.www.gov.cn/archive/white_paper/2014/08/23/content_281474982986592.htm) it is bound to be based on regional poverty levels. The empirical strategy addresses this issue by following [Bluhm et al. (2018)](https://www.aiddata.org/publications/connective-finance-chinese-infrastructure-projects) who employ a two stage least squares (2SLS) approach, initially developed by [Dreher et al. (2017)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3051044), with a shift-share style instrument to study the impact of Chinese infrastructure projects on the diffusion of economic activity in developing countries. The strategy exploits two sources of variations. First, the plausibly exogenous time variation in Chinese steel production, which is a supply-driven component of the explanatory variable of interest – Chinese infrastructure development assistance (CnAid). China’s steel production has long been considered the strategic industry and drove their rapid economic growth and as domestic demand slows the industry is producing surpluses which are driving exports, see figure 2. Chinese overproduction of steel leads to increased exports in the following year, much of which is destined to foreign infrastructure projects. Projects of which some are financed by China, whose development assistance does not usually involve bilateral financial transfers but are commonly delivered in kind, as exports of Chinese goods & materials, complete projects, export credits and/or technical cooperation ([Bräutigam, 2011](https://doi.org/10.1002/jid.1798); [State Council, 2014](http://english.www.gov.cn/archive/white_paper/2014/08/23/content_281474982986592.htm); [Zhang et al., 2015](http://opendocs.ids.ac.uk/opendocs/bitstream/handle/123456789/5781/ER111_DevelopmentBanksfromtheBRICS.pdf?sequence=1)). Therefore, steel is expected to be a relevant instrument for Chinese development assistance, particularly in the form of infrastructure projects. To demonstrate this relationship Figure 3 shows the correlation between Chinese steel production and the total dollar value of development assistance committed in the following year. The 1-year lag of steel production allows for surpluses to translate to international development projects. Together, Figures 1 & 2, show that overproduction in steel leads to greater exports, which is argued to lead to more commitments to large scale infrastructure projects requiring physical inputs.

((((figure2&3 here))))

Chinese steel production only varies over time; however, the second source of variation is the cross-sectional variation in a regions’ probability of being a recipient of Chinese development assistance (pir). Which is measured as the fraction of the number of years over the period 2000 and 2014 in which the region had an active project. Taken together, the interaction of these two sources of variation form a shift-share style instrument that exploits differences in local exposure to a common overproduction shock originating in China. The logic behind this approach is similar to that of a difference-in-difference estimation. In other words, the effects of Chinese development assistance on regional poverty levels induced by domestic overproduction of steel is compared across two groups: regular recipient regions and irregular recipient regions. To see this, we turn to the reduced form shown in figure 4. The regions in the sample are divided into two groups based on the frequency of receiving Chinese development projects during the sample period. The sample’s median value is used to create 2 similarly sized groups, the regions below the median are considered irregular recipients and those above are regular recipients. The reduced form demonstrates the relationship between Chinese steel production, lagged by an additional 2 years to allow for the completion of development projects, and the average poverty level in regular and irregular recipient regions. There is a strong negative correlation among regular recipients, while that correlation is weak amongst irregular recipients. Naturally, these correlations do not imply causation. To distinguish the effects that are attributable to the presence of Chinese development projects our estimation strategy makes use of a strict set of fixed effects and controls for initial poverty levels. The expectation based on theoretical considerations and the relationship demonstrated by the reduced form in figure 4 is that there is a significant and negative effect on poverty levels in regions that regularly host a Chinese development project.

(((((((figure4 here)))))))

This identification strategy relies on the interaction term being exogenous and assumes that a change in Chinese steel production does not lead to a change in the likelihood of receiving development projects between regular regions and irregular regions. An assumption that appears to be realistic. Additionally, [Bluhm et al. (2018)](https://www.aiddata.org/publications/connective-finance-chinese-infrastructure-projects) test this assumption in detail by examining the variation in steel production along variations in the location of projects for different quartiles of probabilities to receive projects and conclude that there is no reason to believe the assumption is violated. A limitation of this strategy is that it relies on annual variation as well as a large sample for instrument strength. Therefore a dataset which spans only 15 years, limits the analysis to the use of annual data instead of data averaged over several periods as is common in aid effectiveness literature. This means that the results will be interpreted as short term effects. Another difference is the lack of control variables available at subnational level, such as institutional quality. Therefore, the specification relies on multiple fixed effects to absorb a wider variety of potential sources of variation and isolate the effect of development projects. REGHDFE, a Stata module developed by [Correia (2017)](https://ideas.repec.org/c/boc/bocode/s457874.html) is employed to fit 2SLS regression while absorbing multiple fixed effects and clustering standard errors at the country level to account for within country spillover effects. Regional fixed effects absorbs variation at unit of analysis to account for a lack of control variables available at the subnational level. While year fixed effects absorbs shocks that affect all regions of a country similarly in a particular year. Taken together the 1st and 2nd stage equations that are jointly estimated through 2SLS are:

**First Stage:** *CnAid<sub>ir(t-2)</sub> = β<sub>1</sub> + (ln⁡(Steel<sub>(t-3)</sub>) × p<sub>ir</sub> ) + iwipov50<sub>ir(t-1)</sub> + u<sub>ir</sub> + λ<sub>it</sub> + v<sub>irt</sub>*

**Second Stage:** *iwipov50<sub>irt</sub> = β<sub>2</sub> + CnAid<sub>i(t-2)</sub> + iwipov50<sub>ir(t-1)</sub> + μ<sub>ir</sub> + λ<sub>it</sub> + v<sub>irt</sub>*

Where equation 2 is the main equation of interest and 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟𝑡 is the percentage of households in poverty in region r in country i in year t. 𝐶𝑛𝐴𝑖𝑑𝑖𝑟(𝑡−2) indicates the presence of a Chinese development project, lagged by 2 years to allow for project completion – based on the average time that projects in the dataset are completed. ln⁡(𝑆𝑡𝑒𝑒𝑙𝑡−3) is measured as the natural logarithm of metric tonnes of steel produced in China lagged by an additional year to allow for domestic over production to translate into the commitment of international development projects. 𝑝𝑖𝑟⁡is the probability that a region receives a project. The initial level of poverty, 𝑖𝑤𝑖𝑝𝑜𝑣50𝑖𝑟(𝑡−1), is included to control for an overall trend in poverty levels. The control is also included in the first stage equation.
The coefficient of the instrument in the first stage equation (𝛽1) is interpreted as the elasticity of the probability to receive a project induced by changes in Chinese steel production. Consider that the average annual change in steel production between 2000 to 2014 was 13.7% and take the coefficient of the first stage equation (𝛽1)=⁡0.349 (see table 4 column 4 on page 30). This average production increase raises the probability of a receiving a project by about 4.7% (0.137×0.349) in regions that always receive projects. While in regions that only receive a project in 15% of all years, the average production increase raises the probability of receiving a project by 0.7% (0.137×(0.349×0.15)).
The main result of the study lies in the coefficient of the second stage equation (𝛽2) which is interpreted as the short term local average treatment effect (LATE) on poverty levels of Chinese development projects induced by domestic overproduction of steel. This LATE is for regions that host a project in all years and is therefore considered the upper boundary of the effects on poverty that regions can expect from hosting a Chinese development project.

## Results <a name="RES"></a>

All results are reported in the regressions tables saved in [china_devprojects_poverty/tables/](https://github.com/frankstevens1/china_devprojects_poverty/tree/master/tables).

*Tables 3 & 4* present the main results of this paper, the specifications estimating the effects of all Chinese development projects, those that are classified as ODA and those within the transport sector. First, the OLS models in *table 3 columns 1-3*, foreshadow a negative relationship although they are all insignificant and suffer from an expected simultaneity bias. *Columns 4-6* report the reduced form estimates, in which the instrument of lagged Chinese steel production interacted with the regional probability of receiving a project is regressed directly on the poverty indicator. Similarly, the direction of the effect is negative though the effect size is increased by an order of magnitude. Significance is also improved, the instrument for all projects and ODA projects are significant at the 10% level while for transport is significant at the 5% level. This is impressive given the restrictive two-way fixed effects while controlling for initial poverty levels with a lagged dependant variable. Tentatively suggesting that the OLS estimates are indeed upwardly biased due to simultaneity, contingent on the strength of our instrument. *Table 4 columns 1-3* present the results of the joint estimation of the first and second stage, which sees the effect of total and ODA projects turn insignificant. Transport projects, however, remains quantitively and qualitatively similar to the reduced form estimate. The Kleibergen-Paap F-statistic of 36.79 is well above the rule of thumb 10% critical value of 16.38. Indicating that we can reject the null hypothesis that the maximum bias relative to OLS due to a weak instrument is below 10% [(Stock & Yogo, 2005)](https://doi.org/10.1017/CBO9780511614491.006). Additionally, the first stage regression in *columns 4-6* show that our instrument is significant at the 1% level and strongest for transport projects with a positive relationship of 0.706. Indicating that a 10% annual growth in Chinese steel production translates to an increase in a regular recipient region’s probability of hosting a project by 7.1% (0.706×0.10) or by 1.8% in regions that only received projects in a quarter of the years ((0.706×0.25)×0.10). The first stage coefficient of total projects and ODA projects are both about 0.3, still relevant but clearly less highly correlated. Encouragingly, the first stage results are similar in magnitude to those found by [Bluhm et al. (2018)](https://www.aiddata.org/publications/connective-finance-chinese-infrastructure-projects) despite the smaller sample size. Considering the strength of the instrument, our results suggest that subnational regions that receive a Chinese transportation project can expect a regional reduction in poverty levels of around 3.4%. Translating to approximately 18 thousand households for the average region with a household population of 600 thousand.

## References <a name="REF"></a>

## Reproducing the Dataset <a name="RTD"></a>

Notebooks detailing the process of wrangling and cleaning the data to produce the final dataset can be viewed using the links:
  1. Region level dataset [data.dta](data.dta): [dataset_prep.ipynb](dataset_prep.ipynb) or using [nbviewer](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep.ipynb)
  2. Country level dataset [data_iso.dta](data_iso.dta): [dataset_prep_iso.ipynb](dataset_prep_iso.ipynb) or using [nbviewer](https://nbviewer.jupyter.org/github/frankstevens1/china_devprojects_poverty/blob/master/dataset_prep_iso.ipynb)

### Installing Dependencies: Python
Python 3.8 on Windows was used to create the dataset used in the analysis. Reproducing the dataset requires the packages listed in [requirements.txt](requirements.txt).

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
virtualenv cdpenv
```
5. Activate virtual environment:
```
.\cdpenv\Scripts\activate
```
**Some dependencies (GDAL, fiona & Rtree) can be installed from .whl files saved in** [china_devprojects_poverty/dependencies](https://github.com/frankstevens1/china_devprojects_poverty/tree/master/dependencies).

*Note: the .whl files save in the dependencies directory are for windows 64bit systems, for other systems the appropriate .whl file can be downloaded from:*
* [GDAL](https://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal)
* [fiona](https://www.lfd.uci.edu/~gohlke/pythonlibs/#fiona)
* [Rtree](https://www.lfd.uci.edu/~gohlke/pythonlibs/#rtree)

6. Install GDAL dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\GDAL-3.0.4-cp38-cp38-win_amd64.whl
```
7. Install Fiona dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\Fiona-1.8.13-cp38-cp38-win_amd64.whl
```
8. Install Rtree dependency (note: change file name in path if .whl file downloaded for another system):
```
pip install .\dependencies\Rtree-0.9.4-cp38-cp38-win_amd64.whl
```
9. Install all packages from [requirements.txt](requirements.txt):
```
pip install -r requirements.txt --upgrade
```
10. Setup ipyknernel to recognize cdpenv, the virtual environment that now has all required dependencies to run *dataset_prep_v2.ipynb*:
```
python -m ipykernel install --name=cdpenv
```

## Reproducing the Analysis <a name="RTA"></a>
The analysis is done using Stata 15, all output reported in the report [china_devprojects_poverty.pdf]() can be reproduced using [analysis.do](stata_do/analysis.do). The analysis requires adding multiple levels of fixed effects, this has been made possible by Sergio Correia's (IV)REGHDFE, more info can be found on the developer's [page](http://scorreia.com/software/reghdfe/index.html).

### Installing Dependencies: Stata
1. (IV)REGHDFE and requirements can be installed from SSC [stata_req.do](stata_do/stata_req.do) contains all the package requirements to install & use (IV)REGHDFE:
```
cd C:\Users\...\china_devprojects_poverty\stata_do
do stata_req.do
```
