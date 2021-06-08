%% beveridgeElasticity.m
%
% This script plots the Beveridge curve and Beveridge elasticity for the US, 1951--2019.
%
%% Description
%
% * This script first collects the results from the Bai-Perron algorithm used to compute the Beveridge elasticity (baiPerron.m).
% * The script then plots the estimated branches of the Beveridge curve.
% * Finally the script plots the Beveridge elasticity and its confidence interval.
%
%% -------------------------------- 

close all;
clear;

%% ---------- Input data ----------

%% Construct timeline

years = readmatrix('book.xlsx','Sheet','data','Range','A2:A277');
quarters = (readmatrix('book.xlsx','Sheet','data','Range','B2:B277')-1)./4;;
timeline = years + quarters;

%% Construct recessions dates

startRecession = readmatrix('book.xlsx','Sheet','NBER','Range','C27:C36');
endRecession = readmatrix('book.xlsx','Sheet','NBER','Range','D27:D36');
nRecession  =  length(startRecession);

% Translate dates to years
startRecession = floor((startRecession-1)/3)/4+1800; 
endRecession = floor((endRecession-1)/3)/4+1800;

%% Input unemployment & vacancy rates

% Unemployment rate
u = readmatrix('book.xlsx','Sheet','data','Range','C2:C277');

% Vacancy rate
v = readmatrix('book.xlsx','Sheet','data','Range','D2:D277');

%% -- Input results from the Bai-Perron algorithm (obtained by running baiPerron.m) --

%% Input break dates

% Beveridge curve breaks ("Output from the global optimization")
breakDate = [41,84,153,194,235];
nBreak = length(breakDate);

'break dates are:'
1951+(breakDate-1)./4

beginDate = [1,breakDate+1];
endDate = [breakDate,length(timeline)];

% 95% confidence intervals for break dates ("Confidence intervals for the break dates" in "Output from the estimation of the model selected by LWZ")
lowBreak = [40,80,152,193,232];
highBreak = [48,89,160,200,237];

%% Input Beveridge elasticity

% Beveridge elasticities ("Estimator" in "Output from the estimation of the model selected by LWZ")
epsilonEstimate = [0.84,1.02,0.84,0.94,1.00,0.84];

% Corrected standard errors ("Corrected standard errors for the coefficients" in "Output from the estimation of the model selected by LWZ")
se = [0.067,0.069,0.112,0.148,0.057,0.057];


%% Construct Beveridge curve branches defined by estimated breaks

for iBranch = 1:(nBreak+1)	
	uBranch{iBranch} = u(beginDate(iBranch):endDate(iBranch));
	vBranch{iBranch} = v(beginDate(iBranch):endDate(iBranch));
end

% Confidence intervals of breaks
for iBreak = 1:nBreak
	uCi{iBreak} = u(lowBreak(iBreak):highBreak(iBreak));
	vCi{iBreak} = v(lowBreak(iBreak):highBreak(iBreak));
end

%% Construct elasticity time series & 95% confidence intervals

epsilon = zeros(length(timeline),1);
epsilonLow = zeros(length(timeline),1);
epsilonHigh = zeros(length(timeline),1);
z = 1.960;

for iBranch = 1:(nBreak+1)	
	epsilon(beginDate(iBranch):endDate(iBranch)) = epsilonEstimate(iBranch);
	epsilonLow(beginDate(iBranch):endDate(iBranch)) = epsilonEstimate(iBranch) - z .* se(iBranch);
	epsilonHigh(beginDate(iBranch):endDate(iBranch)) = epsilonEstimate(iBranch) + z .* se(iBranch);
end	

%% Record results in Excel sheet

results = [timeline,epsilon,epsilonLow,epsilonHigh];
writematrix(results,'book.xlsx','Sheet','results','Range','A2:D277')

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
purpleLight = '#bfbddc';
pink = '#e7298a';
black = '#666666';
gray = [0.75 0.75 0.75];

%% Set properties for areas & lines & axes

areaSetting.FaceColor = 'black';
areaSetting.LineStyle = 'none';
areaSetting.FaceAlpha = 0.15;
areaSetting=[fieldnames(areaSetting),struct2cell(areaSetting)]';

lineSetting.Color = purple;
lineSetting.LineWidth = 3;
lineSetting=[fieldnames(lineSetting),struct2cell(lineSetting)]';

purpleSetting.Color = purple;
purpleSetting.LineWidth = 0.5;
purpleSetting=[fieldnames(purpleSetting),struct2cell(purpleSetting)]';

xSetting.XLim = [1951,2019.75];
xSetting.XTick = [1951,1970,1985,2000,2019];
xSetting=[fieldnames(xSetting),struct2cell(xSetting)]';

iFigure = 0;

%% ---------- Plot Beveridge elasticity with confidence interval ----------

iFigure = iFigure+1;
figure(iFigure)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Paint confidence intervals
a = area(timeline,[epsilonLow,epsilonHigh-epsilonLow],'LineStyle','none');
a(1).FaceAlpha=0;
a(2).FaceAlpha = 0.2;
a(2).FaceColor = purple;
plot(timeline,epsilon,lineSetting{:})
plot(timeline,epsilonLow,purpleSetting{:})
plot(timeline,epsilonHigh,purpleSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,1.5],'yTick',[0:0.3:1.5])
print('-dpdf',['elasticity.pdf'])

%% ---------- Plot confidence interval of Beveridge breaks  ----------

%% Adjust axes properties for scatter plots

set(groot,'defaultAxesXGrid','on')
set(groot,'defaultAxesTickLength',[0 0])

%% Set properties for lines & scatters

graySetting.Color = gray;
graySetting.LineWidth = 1;
graySetting=[fieldnames(graySetting),struct2cell(graySetting)]';

ciSetting.Color = [0.459, 0.439, 0.702, 0.2];
ciSetting.LineWidth = 12;
ciSetting=[fieldnames(ciSetting),struct2cell(ciSetting)]';

%% Plot branches of Beveridge curve defined by breaks

for iBranch = 1:(nBreak+1)
	
	iFigure = iFigure+1;
	figure(iFigure)
	clf
	hold on

	% Plot background Beveridge curve
	plot(log(u),log(v),graySetting{:})

	% Plot pre-branch
	if iBranch>1
		plot(log(uCi{iBranch-1}),log(vCi{iBranch-1}),ciSetting{:})
	end

	% Plot post-branch
	if iBranch<=nBreak
		plot(log(uCi{iBranch}),log(vCi{iBranch}),ciSetting{:})
	end

	% Plot relevant branch of Beveridge curve
	plot(log(uBranch{iBranch}),log(vBranch{iBranch}),lineSetting{:})

	% Populate axes & print
	set(gca,'xLim',[-3.7,-2.2],'xTick',[-3.7:0.3:-2.2])
	set(gca,'yLim',[-4.2,-3],'yTick',[-4.2:0.3:-3])
	xlabel('Log unemployment rate')
	ylabel('Log vacancy rate')
	set(gca,'Position',get(gca,'Position')+[0.01,0.01,0,0]); 
	print('-dpdf',['beveridgebreaks_',num2str(iBranch),'.pdf'])

end
