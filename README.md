# Correlation analysis for "MYH9 mutation N93K triggers abnormal myosin filament stabilization and aggregation in amoeboid cells"


## Functions

The "functions" folder contains custom MATLAB functions needed to perform the analysis.

- `autocrop.m`: automatic cropping of the correlation function
- `corrfunc.m`: calculation of autocorrelation functions
- `corrfunc_cross.m`: calculation of cross-correlation functions
- `gauss2d.m`, `gauss2dwxy.m`, `gaussfit.m`: Gaussian fitting of the correlation functions
- `wnCorr.m`: background correction for images

The majority of MATLAB code for functions was written by David Kolin, a previous Wiseman Lab member.

## Runfiles

- ICS_runfile.m contains the script for executing correlation analysis
- summary_runfile.ipynb contains a simple script for data processing and summarization
