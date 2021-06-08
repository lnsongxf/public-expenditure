%% baiPerron.m
%
% This script runs the Bai-Perron algorithm on unemployment and vacancy data to compute the Beveridge elasticity for the US, 1951--2019.
%
%% Original code
%
% * All functions to run the algorithm are contained in the folder /baiperron.
% * This file is based on the file brcode.m in /baiperron.
% * The original code is available at http://blogs.bu.edu/perron/files/2020/05/m-break-matlab.zip.
% 
%% References
%
% * Jushan Bai and Pierre Perron. 1998. "Estimating and Testing Linear
% Models with Multiple Structural Changes." Econometrica, vol. 66, pp. 47-78
% * Jushan Bai and Pierre Perron. 2003. "Computation and Analysis of
%  Multiple Structural Change Models." Journal of Applied Econometrics, vol. 18, pp. 1-22
% 
%% -------------------------------- 

clear;
clc;
addpath('baiperron');

%% ---------- Input data ----------

% Unemployment rate
u = readmatrix('book.xlsx','Sheet','data','Range','C2:C277');

% Vacancy rate
v = readmatrix('book.xlsx','Sheet','data','Range','D2:D277');

% Effective sample size
bigt = length(u); 

% Dependent variable
y = log(v);           

% Matrix of regressors (bigt,q) whose coefficients are allowed to change across regimes
z = [ones(bigt,1),log(u)];

% Number of regressors z
q = size(z,2);             

% Matrix of regressors with coefficients fixed across regimes
x = [];

% Number of regressors x 
p = size(x,2);  

%% ---------- Setup algorithm ----------

% Value of the trimming for the construction and the critical values of the supF type tests (supF test, Dmax test, supF(l+1|l) test, and sequential  procedure). There are five options for eps1: 0.05, 0.10, 0.15, 0.20, and 0.25. 
eps1 = 0.15;   
        
% Maximum number of structural changes allowed. For each triming value, the maximal value of m is: m = 10 for eps1 = 0.05, m = 8 for eps1 = 0.10, m = 5 for eps1 = 0.15, m = 3 for eps1 = 0.20, and m = 2 for eps1 = 0.25.
m = 5;

% Minimal length of segment (h>q)
h = round(eps1*bigt); 

% Set to 1 to allow for heterogeneity & autocorrelation in the residuals, 0 otherwise.
robust = 1;      

% Set to 1 to apply AR(1) prewhitening prior to estimating the long run covariance matrix.         
prewhit = 0;

% Set to 1 to allow for the variance of the residuals to be different across segments. If hetvar = 0, the variance of the residuals is assumed constant across segments and constructed from the ful sample. This option applies for the construction of the F tests. 
hetvar = 1; 

% Set to 1 to allow different moment matrices of the regressors across segments. If hetdat = 0, the same moment matrices are assumed for each segment  and estimated from the ful sample. This option applies for the construction of the F tests.
hetdat = 1;    

% Set to 1 to allow for long-run covariance matrix of the residuals to be different across segments. If hetomega = 0, the long-run covariance matrix of the residuals is assumed identical across segments (the variance of the errors if robust  =  0). This option applies to the construction of the confidence intervals for the break dates.
hetomega = 1; 

% Set to 1 to allow different moment matrices of the data across segments. If hetq = 0, the moment matrix of the data is assumed identical across segments. This option applies to the construction of the confidence intervals for the break dates.
hetq = 1;

%% ---------- Choose algorithm output ----------

% Set to 1 to obtain global minimizers
doglobal = 1;

 % Set to 1 to construct the supF, UDmax, and WDmax tests (doglobal must be set to 1 to run this procedure).
dotest = 1;               

% Set to 1 to construct the supF(l+1|l) tests under the null the l breaks are obtained using global minimizers (doglobal must be set to 1 to run this procedure).
dospflp1 = 1;

% Set to 1 to selects the number of breaks using information criteria (doglobal must be set to 1 to run this procedure).
doorder = 1;               

% Set to 1 to estimate the breaks sequentialy and estimate the number of breaks using supF(l+1|l) test.
dosequa = 1;   

% Set to 1 to modify the break dates obtained from the sequential method using the repartition method of Bai (1995), estimating breaks one at a time. This is needed for the confidence intervals obtained with estim below to be valid.
dorepart = 0;

% Set to 1 to estimate the model with the number of breaks selected by BIC.
estimbic = 1;              

% Set to 1 to estimate the model with the number of breaks selected by LWZ
estimlwz = 1;

% Set to 1 to estimate the model with the number of breaks selected using the sequential procedure              
estimseq = 1;

% Set to 1 to estimate the model with the breaks selected using the repartition method
estimrep = 0;              

 % Set to 1 to estimate the model with a prespecified number of breaks equal to fixn
estimfix = 0;             
fixn = 6;

% The following options only apply to partial structural change models. They are not relevant here but need to be setup to default values.
fixb = 0;
betaini = 0;
maxi = 20;
printd = 1;
eps = 0.0001; 

%% ---------- Run the Bai-Perron algorithm ----------

pbreak(bigt,y,z,q,m,h,eps1,robust,prewhit,hetomega,hetq,doglobal,dotest,dospflp1,doorder,dosequa,dorepart,estimbic,estimlwz,estimseq,estimrep,estimfix,fixb,x,p,eps,maxi,betaini,printd,hetdat,hetvar,fixn)
