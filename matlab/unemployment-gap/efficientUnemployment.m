%% efficientUnemployment.m
%
% This script plots the efficient unemployment rate for the US, 1951--2019.
%
%% ----------------------------------------

close all;
clear;

%% ---------- Input data ----------

%% Construct timeline

timeline = readmatrix('book.xlsx','Sheet','results','Range','A2:A277');

%% Construct recessions dates

startRecession = readmatrix('book.xlsx','Sheet','NBER','Range','C27:C36');
endRecession = readmatrix('book.xlsx','Sheet','NBER','Range','D27:D36');
nRecession  =  length(startRecession);

% Translate dates to years
startRecession = floor((startRecession-1)/3)/4+1800; 
endRecession = floor((endRecession-1)/3)/4+1800;

%% Input unemployment & vacancy rates & construct tightness

% Unemployment rate
u = readmatrix('book.xlsx','Sheet','data','Range','C2:C277');

% Vacancy rate
v = readmatrix('book.xlsx','Sheet','data','Range','D2:D277');

% Labor market tightness
theta= v./u;

%% Input Beveridge elasticity, computed by Bai-Perron algorithm

epsilon = readmatrix('book.xlsx','Sheet','results','Range','B2:B277');
epsilonLow = readmatrix('book.xlsx','Sheet','results','Range','C2:C277');
epsilonHigh = readmatrix('book.xlsx','Sheet','results','Range','D2:D277');

%% Input other sufficient statistics

% Social value of nonwork
zeta = 0.26;

% Recruiting cost
kappa = 0.92; 

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
% gray=[0.75 0.75 0.75];

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

starSetting.Color = pink;
starSetting.LineWidth = 3;
starSetting=[fieldnames(starSetting),struct2cell(starSetting)]';

pinkSetting.Color = pink;
pinkSetting.LineWidth = 0.5;
pinkSetting=[fieldnames(pinkSetting),struct2cell(pinkSetting)]';

xSetting.XLim = [1951,2019.75];
xSetting.XTick = [1951,1970,1985,2000,2019];
xSetting=[fieldnames(xSetting),struct2cell(xSetting)]';

iFigure = 0;

%% ---------- Compute efficient tightness & unemployment ----------

thetaStar= (1-zeta)./(kappa.*epsilon); 
uStar=u.*(theta./thetaStar).^(1./(1+epsilon));

%% ---------- Plot efficient tightness & unemployment  ----------

%%  Efficient tightness

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot elasticity

a = area(timeline,[thetaStar,max(theta-thetaStar,0),min(theta-thetaStar,0)],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(3).FaceAlpha = 0.2;
a(2).FaceColor = purple;
a(3).FaceColor = pink;
plot(timeline,theta,lineSetting{:})
plot(timeline,thetaStar,starSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.5],'yTick',[0:0.3:1.5])
ylabel('Labor market tightness')
print('-dpdf',['efficienttightness.pdf'])

%%  Efficient unemployment

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot unemployment

a = area(timeline,[uStar,max(u-uStar,0),min(u-uStar,0)],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(3).FaceAlpha = 0.2;
a(2).FaceColor = purple;
a(3).FaceColor = pink;
plot(timeline,u,lineSetting{:})
plot(timeline,uStar,starSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['efficientunemployment.pdf'])

%%  Unemployment gap

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],-1,areaSetting{:});
end

% Plot unemployment

plot(timeline,u-uStar,lineSetting{:})
% plot(timeline,uStar,starSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[-0.02,0.08],'yTick',[-0.02:0.02:0.08],'yTickLabel',['-2%';' 0%';' 2%';' 4%';' 6%';' 8%'])
% ylabel('Unemployment rate')
print('-dpdf',['unemploymentgap.pdf'])


%% -- Compute efficient tightness & unemployment for different calibrations ----

%% Lower bound on Beveridge elasticity

thetaStarEpsilonLow = (1- zeta)./(kappa.*epsilonLow);
uStarEpsilonLow=u.*(theta./thetaStarEpsilonLow).^(1./(1+epsilonLow));

%% Upper bound on Beveridge elasticity

thetaStarEpsilonHigh = (1-zeta)./(kappa.*epsilonHigh);
uStarEpsilonHigh = u.*(theta./thetaStarEpsilonHigh).^(1./(1+epsilonHigh));

%% Lower bound on social value of unemployment

zetaLow=0.03;
thetaStarZetaLow = (1-zetaLow)./(kappa.*epsilon);
uStarZetaLow=u.*(theta./thetaStarZetaLow).^(1./(1+epsilon));

%% Upper bound on social value of unemployment

zetaHigh=0.49;
thetaStarZetaHigh = (1-zetaHigh)./(kappa.*epsilon);
uStarZetaHigh = u.*(theta./thetaStarZetaHigh).^(1./(1+epsilon));

%% Lower bound on recruiting cost

kappaLow=0.84;
thetaStarKappaLow = (1-zeta)./(kappaLow.*epsilon);
uStarKappaLow=u.*(theta./thetaStarKappaLow).^(1./(1+epsilon));

%% Upper bound on recruiting cost

kappaHigh=0.98;
thetaStarKappaHigh = (1-zeta)./(kappaHigh.*epsilon);
uStarKappaHigh = u.*(theta./thetaStarKappaHigh).^(1./(1+epsilon));

%% Hagedorn-Manovskii (2008) calibration of  social value of unemployment

zetaHm=0.96;
thetaStarHm= (1-zetaHm)./(kappa.*epsilon);
uStarHm=u.*(theta./thetaStarHm).^(1./(1+epsilon));

%% ---------- Plot unemployment gaps for different calibrations ----------

%%  Efficient unemployment for range of Beveridge elasticity

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot unemployment

a = area(timeline,[uStarEpsilonLow,uStarEpsilonHigh-uStarEpsilonLow],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(2).FaceColor = pink;
plot(timeline,uStarEpsilonLow,pinkSetting{:})
plot(timeline,uStarEpsilonHigh,pinkSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,u,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['unemploymentgap_epsilon.pdf'])

%%  Efficient unemployment for range of social value of unemployment

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot unemployment

a = area(timeline,[uStarZetaLow,uStarZetaHigh-uStarZetaLow],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(2).FaceColor = pink;
plot(timeline,uStarZetaLow,pinkSetting{:})
plot(timeline,uStarZetaHigh,pinkSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,u,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['unemploymentgap_zeta.pdf'])

%%  Efficient unemployment for range of recruiting costs

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot unemployment

a = area(timeline,[uStarKappaLow,uStarKappaHigh-uStarKappaLow],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(2).FaceColor = pink;
plot(timeline,uStarKappaLow,pinkSetting{:})
plot(timeline,uStarKappaHigh,pinkSetting{:})
plot(timeline,uStar,starSetting{:})
plot(timeline,u,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
ylabel('Unemployment rate')
print('-dpdf',['unemploymentgap_kappa.pdf'])


