%%====================================================================================
%% this code studies the numerical properties of a simple business-cycle matching model
%% the model only features self-employed workers who sell their services on a goods market
%% it would be possible to have firms and separate labor and goods markets using the model in Michaillat & Saez (QJE, 2015) 
%% 
%% the code calibrates the model to US data
%% then the code simulates the model in response to aggregate demand shocks
%% last the code simulates the model in response to government spending shocks
%%
%% note that the simulations do not describe the response of the model to stochastic shocks (as in state-of-the-art macro)
%% rather the simulations simply are "quantitative comparative statics": they show the responses to "MIT shocks"
%%
%% for all derivations:  see section 2.2, section 2.4, section 5, and online appendix A of Michaillat & Saez (Review of Economic Studies, 2019) 
%%===================================================================================

close all;clear;

%%-------  calibration of the matching model with land to US data -----------

k=1; % productive capacity | k can be endogenized by adding a labor market where firms hire workers
epsilon=1; % elasticity of substitution between public and private consumption
eta=0.6; % matching elasticity
s=0.028; % job-separation rate
omega=0.60; % matching efficacy
ubar=0.061; % target for average unemployment
xbar=0.43; % target for average tightness

Ybar=k.*(1-ubar); % target for average output
Mbar=0.5; % target for average output multiplier (same as unemployment multiplier)
GCbar=0.197; % target for average G/C
gamma=1./(1+1./GCbar); % preference parameter

GY=@(gc)gc./(1+gc); % G/Y
CY=@(gc)1-GY(gc); % C/Y
GYbar=GY(GCbar);
CYbar=CY(GCbar);
GC=@(GY)GY./(1-GY); % G/C
Gbar=GYbar.*Ybar;
Cbar=CYbar.*Ybar;
r=(Mbar.*epsilon.*CYbar)./(1-Mbar.*GYbar); % price rigidity to match multiplier target

q=@(x)omega.*x.^(-eta); % buying rate
f=@(x)omega.*x.^(1-eta); % selling rate
u=@(x)s./(s+f(x)); % unemployment rate
Y=@(x)(1-u(x)).*k; % output
taubar=(1-eta).*ubar./eta; % average matching wedge
rho=q(xbar)./s.*taubar./(1+taubar); % matching cost
tau=@(x)s.*rho./(q(x)-s.*rho); % matching wedge
dlnydlnx=@(x)(1-eta).*u(x)-eta.*tau(x); % elasticity of output to tightness

%% general CES utility function | see online appendix A 
scalar=(1-gamma).^(1-gamma).*gamma.^gamma;
if epsilon==1
	U=@(c,g)c.^(1-gamma).*g.^(gamma)./scalar;
else
	U=@(c,g)((1-gamma).^(1./epsilon).*c.^((epsilon-1)./epsilon)+gamma.^(1./epsilon).*g.^((epsilon-1)./epsilon)).^(epsilon./(epsilon-1));
end
dUdc=@(gc)((1-gamma).*U(1,gc)).^(1./epsilon);
dUdcbar=dUdc(GCbar);
dUdg=@(gc)(gamma.*U(1./gc,1)).^(1./epsilon);
MRS=@(gc)gamma.^(1./epsilon)./(1-gamma).^(1./epsilon).*gc.^(-1./epsilon); % MRS between public and private consumption
dlnUdlnc=@(gc)(1-gamma).^(1./epsilon).*(U(1,gc)).^((1-epsilon)./epsilon);
dlnUdlng=@(gc)gamma.^(1./epsilon).*(U(1./gc,1)).^((1-epsilon)./epsilon);
dlnUcdlnc=@(gc)(dlnUdlnc(gc)-1)./epsilon;
dlnUcdlng=@(gc)dlnUdlng(gc)./epsilon;

p0=dUdcbar.^r./(1+taubar); % price level
p=@(G)p0.*dUdc(G./(Ybar-G)).^(1-r); % price mechanism
dlnpdlng=@(G)(1-r).*(dlnUcdlng(G./(Ybar-G))-dlnUcdlnc(G./(Ybar-G)).*(G./(Ybar-G)));% equation (A4)
dlncdlnx=@(G,x)eta.*tau(x)./dlnUcdlnc(G./(Y(x)-G));% equation (A6)
dlncdlng=@(G,x)(dlnpdlng(G)-dlnUcdlng(G./(Y(x)-G)))./dlnUcdlnc(G./(Y(x)-G));% equation (A7)
dlnxdlng=@(G,x)(G./Y(x)+(1-G./Y(x)).*dlncdlng(G,x))./(dlnydlnx(x)-(1-G./Y(x)).*dlncdlnx(G,x));% equation (A9)
m=@(G,x)(1-eta).*u(x).*(1-u(x)).*dlnxdlng(G,x).*Y(x)./G;% equation (A11): theoretical unemployment multiplier
M=@(G,x)m(G,x)./(1-u(x)+G./Y(x).*eta.*tau(x)./(1-eta)./u(x).*m(G,x));% equation (A11): output multiplier

findx=@(G,x,alpha)abs(dUdc(G./(Y(x)-G))-((1+tau(x)).*p(G)./alpha)); % gap between aggregate supply & aggregate demand for tightness x, government spending G, and demand alpha


%%-------------- business-cycle simulations under aggregate-demand shocks | see section 5 -----------------------

%% we compute equilibrium variables for a range of aggregate demands
%% public-expenditure policy: G/Y=16.5%

ALPHA=[0.97:0.0025:1.03]; %range of aggregate demand
x0=[0.001:0.0002:2]; %grid to search for equilibrium tightness x
j=0;

for alpha=ALPHA
	
	j=j+1;
	
	G0=GYbar.*Y(x0);	% G such that G/Y=16.5%
	eva=findx(G0,x0,alpha);
	[val,ind]=min(eva); % finds x such aggregate supply = aggregate demand
	xad(j)=x0(ind); % equilibrium x 
	Gad(j)=G0(ind); % equilibrium G 

end

%% we compute all other equilibrium variables with G/Y=16.5%

Yad=Y(xad); % output
GYad=Gad./Yad; % G/Y
uad=u(xad); % unemployment rate
Mad=M(Gad,xad); % output multiplier
% pad = p(Gad); % price of services relative to land

%%-------------- business-cycle simulations under public-spending shocks | see section 5 -----------------------

%% we compute equilibrium variables for a range of public spending G/Y

GY0=[0.10:0.00005:0.25]; % range of public expenditure G/Y
j=0;
% [GY1,x1]=ndgrid(GY0,x0);

for gy=GY0

		j=j+1;
	
		G0=gy.*Y(x0);	% G such that G/Y=gy
		eva=findx(G0,x0,1);
		[val,ind]=min(eva); % finds x such aggregate supply = aggregate demand
		xgy(j)=x0(ind); % equilibrium x 
		Ggy(j)=G0(ind); % equilibrium G 

end

% we compute all other equilibrium variables

Ygy=Y(xgy); % output
GYgy=Ggy./Ygy; % G/Y
ugy=u(xgy); % unemployment rate
Mgy=M(Ggy,xgy); % output multiplier
% pgy = p(Ggy); % price of services relative to land


%%--------------------------  format figures  --------------------------

set(groot,'DefaultFigureUnits', 'inches')
set(groot,'DefaultFigurePosition', [0,0,7.7779,5.8334]);
set(groot,'DefaultFigurePaperPosition', [0, 0, 7.7779,5.8334]);
set(groot,'DefaultFigurePaperSize', [7.7779,5.8334]);
set(groot,'DefaultAxesFontName', 'Times New Roman')
set(groot,'DefaultAxesFontSize', 22)
set(groot,'DefaultLineLineWidth', 3)
set(groot,'DefaultAxesLineWidth', 1)
set(groot,'DefaultAxesXColor','k')
set(groot,'DefaultAxesYColor','k')
set(groot,'DefaultAxesYGrid','on')
set(groot,'DefaultAxesXGrid','on')
set(groot,'DefaultAxesTickLength',[0 0])
co = [217,95,2
		  8,81,156
			107,174,214];
co = co./255;
set(groot,'DefaultAxesColorOrder',co)


%%-------------- plots equilibrium under different aggregate demand   -----------

xmi=min(ALPHA);xma=max(ALPHA);
fign=0;

% figure: unemployment rate

x1=ALPHA;
y1=uad.*100;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Aggregate demand')
set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
set(gca,'YLim',[4,12],'YTick',[4:2:12],'YTickLabel',[' 4%';' 6%';' 8%';'10%';'12%'])
ylabel('Unemployment/idleness rate')
print('-dpdf','unemployment_ad.pdf')

% figure: output multiplier

x1=ALPHA;
y1=Mad;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Aggregate demand')
set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
% set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
ylabel('Output multiplier (dY/dG)')
print('-dpdf','multiplier_ad.pdf')

% figure: output

x1=ALPHA;
y1=Yad;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Aggregate demand')
set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
% set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
ylabel('Output = measured productivity')
print('-dpdf','output_ad.pdf')

% % figure: price of services relative to land

% x1=ALPHA;
% y1=pad;

% fign=fign+1;
% figure(fign)
% clf
% hold on
% plot(x1,y1,'-','Color',co(2,:))
% xlabel('Aggregate demand')
% set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
% % set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
% ylabel('Relative price services / land')
% print('-dpdf','price_ad.pdf')

%%-------------- plots equilibrium under different government spending   -----------

xmi=min(GY0);xma=max(GY0);

% figure: unemployment rate

x1=GY0;
y1=ugy.*100;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Public expenditure G/Y')
% set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
set(gca,'XLim',[xmi,xma],'XTick',[0.1:0.05:0.25],'XTickLabel',['10%';'15%';'20%';'25%'])
set(gca,'YLim',[4,12],'YTick',[4:2:12],'YTickLabel',[' 4%';' 6%';' 8%';'10%';'12%'])
ylabel('Unemployment/idleness rate')
print('-dpdf','unemployment_gy.pdf')

% figure: output multiplier

x1=GY0;
y1=Mgy;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Public expenditure G/Y')
set(gca,'XLim',[xmi,xma],'XTick',[0.1:0.05:0.25],'XTickLabel',['10%';'15%';'20%';'25%'])
% set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
ylabel('Output multiplier (dY/dG)')
print('-dpdf','multiplier_gy.pdf')

% figure: output

x1=GY0;
y1=Ygy;

fign=fign+1;
figure(fign)
clf
hold on
plot(x1,y1,'-','Color',co(2,:))
xlabel('Public expenditure G/Y')
set(gca,'XLim',[xmi,xma],'XTick',[0.1:0.05:0.25],'XTickLabel',['10%';'15%';'20%';'25%'])
% set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
ylabel('Output = measured productivity')
print('-dpdf','output_gy.pdf')

% % figure: price of services relative to land

% x1=GY0;
% y1=pgy;

% fign=fign+1;
% figure(fign)
% clf
% hold on
% plot(x1,y1,'-','Color',co(2,:))
% xlabel('Public expenditure G/Y')
% % set(gca,'XLim',[xmi,xma],'XTick',[0.97,1,1.03])
% set(gca,'YLim',[0,1.5],'YTick',[0:0.5:1.5])
% ylabel('Relative price services / land')
% print('-dpdf','price_gy.pdf')
