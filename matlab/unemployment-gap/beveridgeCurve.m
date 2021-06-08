%% beveridgeCurve.m
%
% This script plots the Beveridge curve for the US, 1951--2019.
%
%% Data sources
% 
% * Unemployment rate, 1951--2019: BLS CPS
% * Vacancy rate, 1951--2000: Barnichon (2010)
% * Vacancy rate, 2001--2019: BLS JOLTS
% * Civilian labor force, 2001--2019: BLS CPS 
%
%% ----------------------------------------

close all;
clear;
version='20200722';

%% ---------- Input data ----------

%% Construct vacancy rate

% Vacancy rate from Barnichon (2010) for 1951--2000
vBarnichon = xlsread('hosios.xlsx','BARNICHON','B48:B647')./100; 

% Vacancy level from JOLTS for 2001--2019
vJolts = xlsread('hosios.xlsx','JOLTS','C3:C230'); 

% Civilian labor force from CPS for 2001--2019
laborforce = xlsread('hosios.xlsx','CLF16OV','B648:B875');

% Aggregate vacancy rates for 1951--2019
v = [vBarnichon;vJolts./laborforce];

%% Input unemployment rate

u = xlsread('hosios.xlsx','UNRATE','B48:B875')./100;

%% Take quarterly averages of monthly series

u = quarterly(u);
v = quarterly(v);

%% Construct timeline

years = xlsread('hosios.xlsx','epsilon','A3:A278');
quarters = (xlsread('hosios.xlsx','epsilon','B3:B278')-1)./4;;
timeline = years + quarters;

%% Save unemployment & vacancies data

csvwrite(['output/beveridge_',version,'.csv'],[timeline,ones(size(u)),log(u),log(v)]);
csvwrite(['output/uv_',version,'.csv'],[timeline,u,v]);

%% Construct branches of the Beveridge curve for display

% Pick break years
breaks = [1970,1990,2010];
% Translate into indices
breaks = 1+((breaks-1951).*4);
% Add first & last indices
breaks = [1,breaks,length(timeline)+1];
% Construct branches
nBranch = length(breaks)-1;
for iBranch = 1:nBranch
	uBranch{iBranch} = u(breaks(iBranch):breaks(iBranch+1)-1);
	vBranch{iBranch} = v(breaks(iBranch):breaks(iBranch+1)-1);
end

%% Construct recessions dates

startRecession = xlsread('hosios.xlsx','NBER','C27:C36');
endRecession = xlsread('hosios.xlsx','NBER','D27:D36');
nRecession  =  length(startRecession);

% Translate dates to years
startRecession = floor((startRecession-1)/3)/4+1800; 
endRecession = floor((endRecession-1)/3)/4+1800;

%% ---------- Format graphics ----------

%% Set properties for figures & axes

set(groot,'defaultFigureUnits', 'inches')
set(groot,'defaultFigurePosition', [1,1,7.7779,5.8334]);
set(groot,'defaultFigurePaperPosition', [0, 0, 7.7779,5.8334]);
set(groot,'defaultFigurePaperSize', [7.7779,5.8334]);

set(groot,'defaultAxesFontName','Helvetica')
set(groot,'defaultAxesFontSize',22)
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

purple = '#7570b3';
gray = [0.75 0.75 0.75];

%% Set properties for areas & lines & axes

areaSetting.FaceColor = 'black';
areaSetting.LineStyle = 'none';
areaSetting.FaceAlpha = 0.15;
areaSetting=[fieldnames(areaSetting),struct2cell(areaSetting)]';

lineSetting.Color = purple;
lineSetting.LineWidth = 3;
lineSetting=[fieldnames(lineSetting),struct2cell(lineSetting)]';

graySetting.Color = gray;
graySetting.LineWidth = 1;
graySetting=[fieldnames(graySetting),struct2cell(graySetting)]';

xSetting.XLim = [1951,2019.75];
xSetting.XTick = [1951,1970,1985,2000,2019];
xSetting=[fieldnames(xSetting),struct2cell(xSetting)]';


%% ---------- Plot unemployment rate & vacancy rate ----------

%% Unemployment rate

figure(1)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:});
end

% Plot unemployment rate
plot(timeline,u,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.12],'yTick',[0:0.03:0.12],'yTickLabel',[' 0%';' 3%';' 6%';' 9%';'12%'])
print('-dpdf',['figures/unemployment_',version,'.pdf'])

%% Vacancy rate

figure(2)
clf
hold on

% Paint recession areas
for iRecession = 1:nRecession
	area([startRecession(iRecession),endRecession(iRecession)],[2,2],areaSetting{:})
end

% Plot vacancy rate
plot(timeline,v,lineSetting{:})

% Populate axes & print
set(gca,xSetting{:})
set(gca,'yLim',[0,0.05],'yTick',[0:0.01:0.05],'yTickLabel',['0%';'1%';'2%';'3%';'4%';'5%'])
print('-dpdf',['figures/vacancy_',version,'.pdf'])

%% ---------- Plot Beveridge curves ----------

% Adjust axes properties for scatter plots
set(groot,'defaultAxesXGrid','on')
set(groot,'defaultAxesTickLength',[0 0])

% Plot each Beveridge curve branch on a different figure
for iBranch = 1:nBranch

	figure(iBranch+2)
	clf
	hold on

	% Plot background Beveridge curve
	plot(log(u),log(v),graySetting{:})

	% Plot relevant branch of Beveridge curve
	plot(log(uBranch{iBranch}),log(vBranch{iBranch}),lineSetting{:})

	% Populate axes & print
	set(gca,'xLim',[-3.7,-2.2],'xTick',[-3.7:0.3:-2.2])
	set(gca,'yLim',[-4.2,-3],'yTick',[-4.2:0.3:-3])
	xlabel('Log unemployment rate')
	ylabel('Log vacancy rate')
	set(gca,'Position',get(gca,'Position')+[0.01,0.01,0,0]); 
	print('-dpdf',['figures/logbeveridge_',num2str(iBranch),'_',version,'.pdf'])

end