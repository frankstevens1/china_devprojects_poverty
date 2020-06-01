# china_devprojects_poverty
A 2SLS strategy for determining the effects of Chinese development projects on sub-national poverty levels around the world.

Python 3.8 on Windows is used for the data wrangling/cleaning process & for generating visualizations.

Stata 15 with additional packages is used for running the analysis and generating regression tables.

## Dependencies:

### A. Python Packages
The steps in the data wrangling/cleaning process are detailed in the Jupyter notebook: *dataset_prep_v2.ipynb*

To run *dataset_prep_v2.ipynb*, the packages in requirements.txt need to the installed.

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
5. Activate vitual environment:
```
.\cdpenv\Scripts\activate
```
6. Install all packages from requirements.txt
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
10. Setup ipyknernel to recognize mtenv, the virtual environment that now has all required dependencies to run dataset_prep_v2.ipynb:
```
python -m ipykernel install --name=mtenv
```
### B. Stata Packages:
The analysis requires adding multiple levels of fixed effects, this has been made possible by Sergio Correira's REGHDFE, more info can be found on the developer's [page](http://scorreia.com/software/reghdfe/index.html).

1. REGHDFE and its requirements can be installed from SSC, *stata_req.do* contains all the stata packages:
```
cd C:\Users\...\china_devprojects_poverty
do stata_req.do
```
