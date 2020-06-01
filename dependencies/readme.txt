1. Create python virtual environment:
virtualenv {name env}

// vitualenv mtenv

2. Activate vitual environment:
.\mtenv\Scripts\activate

3. Install GDAL dependency:
- download the right .whl file for our python interpreter & system from: https://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal
- pip install {path to .whl file downloaded} 

// pip install C:\Users\fstev\mthesis\dependencies\GDAL-3.0.4-cp38-cp38-win_amd64.whl

4. Install Fiona dependency:
- donwload the right .whl file for your python interpreter & system from: https://www.lfd.uci.edu/~gohlke/pythonlibs/#fiona
- - pip install {path to .whl file downloaded}

// pip install C:\Users\fstev\mthesis\dependencies\Fiona-1.8.13-cp38-cp38-win_amd64.whl

5. Install Rtree dependency:
- donwload the right .whl file for your python interpreter & system from: https://www.lfd.uci.edu/~gohlke/pythonlibs/#rtree

// pip install C:\Users\fstev\mthesis\dependencies\Rtree-0.9.4-cp38-cp38-win_amd64.whl

6. Install geopandas
- pip install geopandas

7. Install matplotlib
- pip install matplotlib

8. Install ipykernel
- pip install ipykernel

9. Setup virtual env on jupyterlab 
- python -m ipykernel install --name=mtenv


