%% dmpModel.m
%
% This script uses the DMP model to construct various versions of the efficient unemployment rate for the US, 1951--2019.
%
%% ----------------------------------------

close all;
clear;
version='20201209';

%% ---------- Input data ----------

%% Construct timeline

years = xlsread('hosios.xlsx','beveridge','A3:A278');
quarters = (xlsread('hosios.xlsx','beveridge','B3:B278')-1)./4;;
timeline = years + quarters;

%% Construct recessions dates

startRecession = xlsread('hosios.xlsx','NBER','C27:C36');
endRecession = xlsread('hosios.xlsx','NBER','D27:D36');
nRecession  =  length(startRecession);

% Translate dates to years
startRecession = floor((startRecession-1)/3)/4+1800; 
endRecession = floor((endRecession-1)/3)/4+1800;

%% Input Beveridge elasticity, computed by Bai-Perron algorithm

epsilon = xlsread('hosios.xlsx','beveridge','E3:E278');

%% Input other sufficient statistics

% Social value of nonwork
zeta = 0.26;

% Recruiting cost
kappa = 0.92; 

%% Input labor productivity

% raw productivity
productivityData = xlsread('hosios.xlsx','productivity','B28:B303');

% detrended productivity
lambda = 1600;
[productivityTrend,productivityHp] = hpfilter(log(productivityData),lambda);
p = exp(productivityHp);

[productivityTrend2,productivityHp2] = hpfilter(productivityData,lambda);
p2 = productivityData./productivityTrend2;

%% Compute job-finding rate (monthly), as in Shimer (2012)

DATA=xlsread('hosios.xlsx','CPS','C3:F831');
u=DATA(1:end-1,1);
u5=DATA(1:end-1,3);
uf=DATA(2:end,1);
u5f=DATA(2:end,3);
f=1-(uf-u5f)./u;
f=-log(1-f);

%% Compute job-separation rate (monthly), as in Shimer (2012)

l=DATA(1:end-1,4);
s0=[0:10^(-6):0.1];
sn=size(s0,2);
[F,S0]=ndgrid(f,s0);
U=repmat(u,1,sn);
UF=repmat(uf,1,sn);
L=repmat(l,1,sn);
H=L+U;
LOSS=abs((1-exp(-F-S0)).*S0.*H./(F+S0)+U.*exp(-F-S0)-UF);
[val,ind]=min(LOSS,[],2);
s=s0(ind)';

% Quarterly average, and quarterly frequency
f = quarterly(f.*3);
s = quarterly(s.*3);

%% Input unemployment & vacancy rates & construct tightness

% Unemployment rate
u = xlsread('hosios.xlsx','beveridge','C3:C278');

%% Compute average unemployment rate for each Beveridge branch

% Beveridge curve breaks
breakDate = [41,84,153,194,235];
nBreak = length(breakDate);
nBranch = nBreak + 1;
beginDate = [1,breakDate+1];
endDate = [breakDate,length(timeline)];

% average unemployment in each branch
for iBranch = 1:nBranch	
	uAverage(beginDate(iBranch):endDate(iBranch),1) = mean(u(beginDate(iBranch):endDate(iBranch)));
end

% Vacancy rate
v = xlsread('hosios.xlsx','beveridge','D3:D278');

% Labor market tightness
theta= v./u;

% Steady-state unemployment

uBar = s./(s+f);

%% ---------- Compute parameters of DMP model ----------

% Matching elasticity
uCorrection = uAverage./(1 - uAverage);
alpha = (epsilon - uCorrection)./(1 + epsilon);

% Job-separation rate / matching efficacy (on Beveridge curve)
sMu = u./(1-u).*theta.^(1-alpha);

% Recruiting cost
c = kappa;

% Value of nonwork
z = zeta;

% Discount rate
r = 0.012;

% matching efficacy

mu = f./(theta.^(1-alpha));

%% ---------- Format graphics ----------

%% Set properties for figures & axes

set(groot,'defaultFigureUnits', 'inches')
set(groot,'defaultFigurePosition', [1,1,7.7779,5.8334]);
set(groot,'defaultFigurePaperPosition', [0, 0, 7.7779,5.8334]);
set(groot,'defaultFigurePaperSize', [7.7779,5.8334]);

set(groot,'defaultAxesFontName','Helvetica')
set(groot,'defaultAxesFontSize', 22)
set(groot,'defaultAxesLabelFontSizeMultiplier',1)
set(groot,'defaultAxesTitleFontSizeMultiplier',1)
set(groot,'defaultAxesTitleFontWeight','normal')
set(groot,'defaultAxesXColor','k')
set(groot,'defaultAxesYColor','k')
set(groot,'defaultAxesGridColor','k')
set(groot,'defaultAxesLineWidth',1)
set(groot,'defaultAxesYGrid','on')
set(groot,'defaultAxesXGrid','off')
set(groot, 'defaultAxesTickDirMode', 'manual')
set(groot,'defaultAxesTickLength',[0.01 0.025])
set(groot, 'defaultAxesTickDir', 'out')

%% Pick color palette

green = '#1b9e77';
orange = '#d95f02';
purple = '#7570b3';
pink = '#e7298a';
black='#666666';
gray=[0.75 0.75 0.75];

%% Set properties for areas & lines & axes

areaSetting.FaceColor = 'black';
areaSetting.LineStyle = 'none';
areaSetting.FaceAlpha = 0.15;
areaSetting=[fieldnames(areaSetting),struct2cell(areaSetting)]';

lineSetting.Color = purple;
lineSetting.LineWidth = 3;
lineSetting=[fieldnames(lineSetting),struct2cell(lineSetting)]';

orangeSetting.Color = orange;
orangeSetting.LineWidth = 3;
orangeSetting=[fieldnames(orangeSetting),struct2cell(orangeSetting)]';

greenSetting.Color = green;
greenSetting.LineWidth = 3;
greenSetting=[fieldnames(greenSetting),struct2cell(greenSetting)]';

starSetting.Color = pink;
starSetting.LineWidth = 3;
starSetting=[fieldnames(starSetting),struct2cell(starSetting)]';

% hairSetting.Color = [205/256, 73/256, 7/256, 0.2];
hairSetting.Color = [0, 0, 0, 0.15];
% hairSetting.Color = black;
hairSetting.LineWidth = 1;
hairSetting=[fieldnames(hairSetting),struct2cell(hairSetting)]';

hairySetting.Color = orange;
hairySetting.LineWidth = 1;
hairySetting=[fieldnames(hairySetting),struct2cell(hairySetting)]';


xSetting.XLim = [1951,2019.75];
xSetting.XTick = [1951,1970,1985,2000,2019];
xSetting=[fieldnames(xSetting),struct2cell(xSetting)]';

iFigure = 0;

%% ---------- Plot calibrated parameters  ----------

%% Separation rate

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,s,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.2])%,'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/s_',version,'.pdf'])

%% Job-finding rate

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,f,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,4])%,'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/f_',version,'.pdf'])

%% Labor-market tightness

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,theta,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.5],'yTick',[0:0.5:1.5])%,'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/theta_',version,'.pdf'])


%% Matching efficacy

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,mu,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,4])%,'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/mu_',version,'.pdf'])


%% Matching elasticity

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,alpha,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.6],'yTick',[0:0.2:0.6])%,'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/alpha_',version,'.pdf'])

for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uAverage,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.08],'yTick',[0:0.02:0.08],'yTickLabel',['0%';'2%';'4%';'6%';'8%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/uaverage_',version,'.pdf'])


%% Labor productivity

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[120,120],areaSetting{:});
end

plot(timeline,p,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0.94,1.06],'yTick',[0.94:0.03:1.06])%,'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/p_',version,'.pdf'])

%% Labor productivity trend

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[120,120],areaSetting{:});
end

plot(timeline,productivityData,lineSetting{:})
plot(timeline,exp(productivityTrend),hairySetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,120],'yTick',[0:30:120])
% set(gca,'yLim',[0.94,1.06],'yTick',[0.94:0.03:1.06])%,'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
print('-dpdf',['figures/trend_',version,'.pdf'])

%% ---------- Plot actual unemployment rates  ----------

% iFigure = iFigure+1;
% figure(iFigure)
% clf
% hold on

% % Paint recession areas
% for iRecession = 1:nRecession
% 	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
% end

% plot(timeline,u,lineSetting{:})

% % Populate axes & print
% set(gca,xSetting{:})
% set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
% print('-dpdf',['figures/actual_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uBar,orangeSetting{:})


% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/accuracy_',version,'.pdf'])



%% --- Compute efficient unemployment rate under various assumptions ----------

% %% Sufficient-statistic formula

thetaStar= (1-zeta)./(kappa.*epsilon); 
uStar=u.*(theta./thetaStar).^(1./(1+epsilon));


% iFigure = iFigure+1;
% figure(iFigure)
% clf
% hold on

% % Paint recession areas
% for iRecession = 1:nRecession
% 	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
% end

% plot(timeline,u,lineSetting{:})
% plot(timeline,uStar,starSetting{:})

% % Populate axes & print
% set(gca,xSetting{:})
% set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Unemployment rate')
% print('-dpdf',['figures/approximation_baseline_',version,'.pdf'])


%% Sufficient-statistic formula with productivity changes

thetaStarP = (p-z)./(c.*epsilon); 
uStarP = u.*(theta./thetaStarP).^(1./(1+epsilon));

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uStarP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/approximation_p_',version,'.pdf'])


%% Formula with endogenous Beveridge elasticity

thetaRange = [0.01:0.01:3]';
[ALPHA,THETA] = ndgrid(alpha,thetaRange);
SMU = repmat(sMu,1,length(thetaRange));
S = repmat(s,1,length(thetaRange));
MU = repmat(mu,1,length(thetaRange));
ZC = repmat((1-z)./c,size(THETA));

formulaEndogenous = ALPHA.*THETA + SMU.*THETA.^ALPHA - (1-ALPHA).*ZC;
[val,thetaIndexEndogenous] = min(abs(formulaEndogenous),[],2);
thetaEndogenous = thetaRange(thetaIndexEndogenous);
uEndogenous = sMu./(sMu + thetaEndogenous.^(1-alpha));

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
plot(timeline,uEndogenous,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/approximation_endogenous_',version,'.pdf'])

% %% Formula with endogenous Beveridge elasticity and productivity changes

PZC = repmat((p-z)./c,1,length(thetaRange));
% formulaEndogenousP = ALPHA.*THETA + SMU.*THETA.^ALPHA - (1-ALPHA).*PZC;
% [val,thetaIndexEndogenousP] = min(abs(formulaEndogenousP),[],2);
% thetaEndogenousP = thetaRange(thetaIndexEndogenousP);
% uEndogenousP = sMu./(sMu + thetaEndogenousP.^(1-alpha));


% iFigure = iFigure+1;
% figure(iFigure)
% clf
% hold on

% % Paint recession areas
% for iRecession = 1:nRecession
% 	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
% end

% plot(timeline,u,lineSetting{:})
% plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,orangeSetting{:})

% % Populate axes & print
% set(gca,xSetting{:})
% set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Efficient unemployment rate')
% print('-dpdf',['figures/approximation_endogenousp_',version,'.pdf'])

%% Formula with Hosios condition

% Tightness
formulaHosios = ALPHA.*THETA + (S+r)./(MU.*THETA.^(-ALPHA)) - (1-ALPHA).*ZC;
[val,thetaIndexHosios] = min(abs(formulaHosios),[],2);
thetaHosios = thetaRange(thetaIndexHosios);

% Job-finding rate
fHosios = mu.*thetaHosios.^(1-alpha);

% Steady-state unemployment
uBarHosios = s./(s+fHosios);

% Actual unemployment
uHosios = u(1,1);
for t = 1:(length(u)-1)
	uHosios(t+1,1) = uBarHosios(t) + (uHosios(t,1)-uBarHosios(t)).*exp(-(s(t)+fHosios(t)));
end


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/approximation_hosios_',version,'.pdf'])


% %% Formula with Hosios condition and prodductivity changes

% % Tightness
% formulaHosiosP = ALPHA.*THETA + (S+r)./(MU.*THETA.^(-ALPHA)) - (1-ALPHA).*PZC;
% [val,thetaIndexHosiosP] = min(abs(formulaHosiosP),[],2);
% thetaHosiosP = thetaRange(thetaIndexHosiosP);

% % Job-finding rate
% fHosiosP = mu.*thetaHosiosP.^(1-alpha);

% % Steady-state unemployment
% uBarHosiosP = s./(s+fHosiosP);

% % Actual unemployment
% uHosiosP = u(1);
% for t = 1:(length(u)-1)
% 	uHosiosP(t+1) = uBarHosiosP(t) + (uHosiosP(t)-uBarHosiosP(t)).*exp(-(s(t)+fHosiosP(t)));
% end

% iFigure = iFigure+1;
% figure(iFigure)
% clf
% hold on

% % Paint recession areas
% for iRecession = 1:nRecession
% 	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
% end

% plot(timeline,u,lineSetting{:})
% plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
% plot(timeline,uHosios,hairSetting{:})
% plot(timeline,uHosiosP,orangeSetting{:})

% % Populate axes & print
% set(gca,xSetting{:})
% set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
% ylabel('Efficient unemployment rate')
% print('-dpdf',['figures/approximation_hosiosp_',version,'.pdf'])

%% Effect of new flows: recompute 4 efficient unemployment rates with new flow

%% Sufficient-statistic formula

% uStarFlow = s./(s+mu.*thetaStar.^(1-alpha));
uStarFlow = s./(s+mu.*thetaStar.^(1-epsilon./(1+epsilon)));
uStarPFlow = s./(s+mu.*thetaStarP.^(1-alpha));

%% Formula with endogenous Beveridge elasticity

formulaEndogenous = ALPHA.*THETA + S./MU.*THETA.^ALPHA - (1-ALPHA).*ZC;
[val,thetaIndexEndogenous] = min(abs(formulaEndogenous),[],2);
thetaEndogenous = thetaRange(thetaIndexEndogenous);
uEndogenousFlow = s./(s + mu.*thetaEndogenous.^(1-alpha));

% Formula with endogenous Beveridge elasticity and productivity changes

formulaEndogenousP = ALPHA.*THETA + S./MU.*THETA.^ALPHA - (1-ALPHA).*PZC;
[val,thetaIndexEndogenousP] = min(abs(formulaEndogenousP),[],2);
thetaEndogenousP = thetaRange(thetaIndexEndogenousP);
uEndogenousPFlow = s./(s + mu.*thetaEndogenousP.^(1-alpha));


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,orangeSetting{:})
% plot(timeline,uHosiosP,hairySetting{:})
plot(timeline,uStarFlow,greenSetting{:})
% plot(timeline,uStarPFlow,hairySetting{:})
% plot(timeline,uEndogenousFlow,hairySetting{:})
% plot(timeline,uEndogenousPFlow,hairySetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/approximation_flows_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,thetaStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,thetaHosios,orangeSetting{:})
% plot(timeline,uHosiosP,hairySetting{:})
% plot(timeline,uStarFlow,greenSetting{:})
% plot(timeline,uStarPFlow,hairySetting{:})
% plot(timeline,uEndogenousFlow,hairySetting{:})
% plot(timeline,uEndogenousPFlow,hairySetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.2],'yTick',[0:0.3:1.2])%,'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient labor-market tightness')
print('-dpdf',['figures/theta_flows_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,thetaEndogenous,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,thetaHosios,orangeSetting{:})
% plot(timeline,uHosiosP,hairySetting{:})
% plot(timeline,uStarFlow,greenSetting{:})
% plot(timeline,uStarPFlow,hairySetting{:})
% plot(timeline,uEndogenousFlow,hairySetting{:})
% plot(timeline,uEndogenousPFlow,hairySetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.2],'yTick',[0:0.3:1.2])%,'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient labor-market tightness')
print('-dpdf',['figures/theta_endogenous_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

% plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uEndogenousFlow,greenSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,orangeSetting{:})
% plot(timeline,uHosiosP,hairySetting{:})
% plot(timeline,uStarFlow,greenSetting{:})
% plot(timeline,uStarPFlow,hairySetting{:})
% plot(timeline,uEndogenousFlow,hairySetting{:})
% plot(timeline,uEndogenousPFlow,hairySetting{:})

set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/u_endogenous_flows_',version,'.pdf'])


return


%% ---------- Zooming graphs ----------

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_baseline_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
plot(timeline,uStarP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_p_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
plot(timeline,uEndogenous,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_endogenous_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
plot(timeline,uEndogenousP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_endogenousp_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_hosios_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
% plot(timeline,uHosios,hairSetting{:})
plot(timeline,uHosiosP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_hosiosp_',version,'.pdf'])


iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,uStar,starSetting{:})
% plot(timeline,uStarP,hairSetting{:})
% plot(timeline,uEndogenous,hairSetting{:})
% plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,hairySetting{:})
plot(timeline,uHosiosP,hairySetting{:})
plot(timeline,uStarFlow,hairySetting{:})
plot(timeline,uStarPFlow,hairySetting{:})
plot(timeline,uEndogenousFlow,hairySetting{:})
plot(timeline,uEndogenousPFlow,hairySetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.06],'yTick',[0:0.01:0.06],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%';'6%'])
ylabel('Efficient unemployment rate')
print('-dpdf',['figures/zoom_hosiosp_flow_',version,'.pdf'])




return

%% ---------- Plot efficient tightnesses  ----------

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,theta,lineSetting{:})
plot(timeline,thetaStar,starSetting{:})
plot(timeline,thetaStarP,hairSetting{:})
plot(timeline,thetaEndogenous,hairSetting{:})
plot(timeline,thetaEndogenousP,hairSetting{:})
plot(timeline,thetaHosios,hairSetting{:})
plot(timeline,thetaHosiosP,hairSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.5],'yTick',[0:0.3:1.5])
ylabel('Labor market tightness')
print('-dpdf',['figures/approximations_theta_',version,'.pdf'])


%% ---------- Plot efficient unemployment rates  ----------

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uStarP,hairSetting{:})
plot(timeline,uEndogenous,hairSetting{:})
plot(timeline,uEndogenousP,hairSetting{:})
plot(timeline,uHosios,hairSetting{:})
plot(timeline,uHosiosP,hairSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximations_u_',version,'.pdf'])

%% ---------- Plot separate efficient unemployment rates for slides  ----------



iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uEndogenous,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_endogenous_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uEndogenousP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_endogenousp_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uHosios,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_hosios_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uHosiosP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_hosiosp_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uBarHosiosP,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_barhosiosp_',version,'.pdf'])

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[6,6],areaSetting{:});
end

plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,uBarHosios,orangeSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['figures/approximation_barhosios_',version,'.pdf'])
