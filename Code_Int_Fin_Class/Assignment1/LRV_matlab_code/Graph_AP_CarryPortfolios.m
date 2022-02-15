
% ============================================= %
% Clear
% ============================================= %
clc;
close all;
clear;


% ============================================= %
% Load portfolios & risk factors
% ============================================= %

if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end

newpath = '/Users/whn2105/Documents/MacroFinance/Data_Int_Fin_Class/rawdata/fx/';


date_start= datenum('11/30/1983');       
% date_end  = datenum(2020,7,31);
% date_end  = datenum(2020,9,30);
% date_end  = datenum(2020,10,30);
date_end  = datenum(2021,7,30);
% Do not use last month available (as data are extended to fill the month), use the previous one
% load(strcat(newpath,'portfolios_logxretba_BarclaysandReuters.mat'),'portfolios_logxretba_BarclaysandReuters');
% date_end  = portfolios_logxretba_BarclaysandReuters(end-1,1);  

sample = 1;
        % 1 = Barclays-Reuters (developed and emerging countries)
        % 2 = Barclays (developed countries)

% --------------------
% Portfolios of currencies sorted on forward discounts
% --------------------

switch sample
    case 1
        load(strcat(newpath,'portfolios_logxret_BarclaysandReuters.mat'),'portfolios_logxret_BarclaysandReuters');
        Data      = portfolios_logxret_BarclaysandReuters;
    case 2
        load(strcat(newpath,'portfolios_logxret_Barclays.mat'),'portfolios_logxret_Barclays');
        Data      = portfolios_logxret_Barclays;
end
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
DataFX    = Data(line_start:line_end,:);

HMLFX     = DataFX(:,end)-DataFX(:,2);
RX        = nanmean(DataFX(:,2:end),2);


% --------------------
% Realized equity vol
% --------------------

% Average Equity volatility (from excess returns for foreign investors in local currencies)
switch sample
    case 1
%         load(strcat(newpath,'average_Rlocvol_MSCI_dM.mat'),'average_Rlocvol_MSCI_dM');
%         Data      = average_Rlocvol_MSCI_dM;
        
        load(strcat(newpath,'BR_MSCI_Market_M_vol.mat'),'BR_MSCI_Market_M_vol');
        Data_EquityVol = [BR_MSCI_Market_M_vol(:,1) nanmean(BR_MSCI_Market_M_vol(:,2:end),2)];

    case 2
%         load(strcat(newpath,'average_Rlocvol_MSCI_Barclays_dM.mat'),'average_Rlocvol_MSCI_Barclays_dM');
%         Data      = average_Rlocvol_MSCI_Barclays_dM;   
%         average_Rlocvol_MSCI_dM = average_Rlocvol_MSCI_Barclays_dM; % use Barclays data for graph too
        
        load(strcat(newpath,'Barclays_MSCI_Market_M_vol.mat'),'Barclays_MSCI_Market_M_vol');
        Data_EquityVol = [Barclays_MSCI_Market_M_vol(:,1) nanmean(Barclays_MSCI_Market_M_vol(:,2:end),2)];

end

% figure;
% plot(Data(:,1),Data(:,2));hold on;
% plot(Data_EquityVol(:,1),Data_EquityVol(:,2));hold off;
% datetick

Data = Data_EquityVol;

date_end_vol = datenum(year(date_end),month(date_end),eomday(year(date_end),month(date_end)));
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end_vol);
EqVol     = Data(line_start:line_end,2)-Data(line_start-1:line_end-1,2);
EqVolDates= Data(line_start:line_end,1);


% --------------------
% Equity returns, TB, and equity excess returns
% --------------------

code_imf                   = 111; %USA
load(strcat(newpath,'MSCI_Market_dM.mat'),'MSCI_Market_dM');
c                          = find(MSCI_Market_dM(1,:)==code_imf);
line_begin_ret             = find(MSCI_Market_dM(:,1)==date_start);
line_end_ret               = find(MSCI_Market_dM(:,1)==date_end);
USEquityRet_smple          = log(MSCI_Market_dM(line_begin_ret:line_end_ret,c)./MSCI_Market_dM(line_begin_ret-1:line_end_ret-1,c));


% US risk-free rate
load(strcat(newpath,'USIR_dM.mat'),'USIR_dM');
line_begin_ret             = find(USIR_dM(:,1)==date_start);
line_end_ret               = find(USIR_dM(:,1)==date_end);
RiskFree_smple             = USIR_dM(line_begin_ret-1:line_end_ret-1,20)/1200; % 20: US TREASURY BILL 2ND MARKET 3 MONTH - MIDDLE RATE

USEquityXRet_smple         = USEquityRet_smple-RiskFree_smple;


% ================================================================================================================================================================================== %
%                                                                               PORTFOLIO BETAS
% ================================================================================================================================================================================== %
% % Options:
% showresult    = 1; % no table, no graph; 
% %               = 1 report results.
% estmethod     = 1; % 1 = OLS;
%                    % 2 = GLS;
%                    % 3 = FMB;

                   
portfolios = DataFX(:,2:end);
factors    = [RX HMLFX];
        
numfactor = size(factors,2);   % # of pricing factors
T         = size(portfolios,1);        % # of periods
N         = size(portfolios,2);        % # of assets
% Time-series regression of each portfolio of excess returns on a constant and factors
betas     = zeros(N,numfactor);
betas_se  = zeros(N,numfactor);
ERRols    = zeros(T,N);
for i=1:N
    [B,BINT,R]=regress(portfolios(:,i),[ones(T,1),factors]); 
    betas(i,1:numfactor)=B(2:length(B))';
    ERRols(:,i)=R;
    
    lags   = 2;
    weight = 1;
    [bv,sebv,R2v,R2vadj,v,F] = olsgmm(portfolios(:,i),[ones(T,1),factors],lags,weight);
    betas_se(i,1:numfactor) = sebv(2:length(bv))';
end
regrHML      = betas; % without intercept in the cross-sectional regression
lambdahatHML = pinv(regrHML'*regrHML)*regrHML'*mean(portfolios)';



factors   = [RX EqVol];

% Time-series regression of each portfolio of excess returns on a constant and factors
betas     = zeros(N,numfactor);
betasVol_se = zeros(N,numfactor);
ERRols    = zeros(T,N);
for i=1:N
    [B,BINT,R]=regress(portfolios(:,i),[ones(T,1),factors]); 
    betas(i,1:numfactor)=B(2:length(B))';
    ERRols(:,i)=R;
    
    [bv,sebv,R2v,R2vadj,v,F] = olsgmm(portfolios(:,i),[ones(T,1),factors],lags,weight);
    betasVol_se(i,1:numfactor) = sebv(2:length(bv))';
end
regrVol      = betas; % without intercept in the cross-sectional regression
lambdahatVol = pinv(regrVol'*regrVol)*regrVol'*mean(portfolios)';


% % Time-series regression of each portfolio of excess returns on a constant and factors
factors   = USEquityXRet_smple;
betas     = zeros(N,1);
betasMkt_se = zeros(N,1);
ERRols    = zeros(T,N);
for i=1:N
    [B,BINT,R]=regress(portfolios(:,i),[ones(T,1),factors]); 
    betas(i,1)=B(2:length(B))';
    ERRols(:,i)=R;
    
    [bv,sebv,R2v,R2vadj,v,F] = olsgmm(portfolios(:,i),[ones(T,1),factors],lags,weight);
    betasMkt_se(i,1:numfactor) = sebv(2:length(bv))';
end
regrMkt      = betas; % without intercept in the cross-sectional regression
% lambdahatMkt = pinv(regrMkt'*regrMkt)*regrMkt'*mean(portfolios)';
lambdahatMkt = mean(factors);


% ================================================================================================================================================================================== %
%                                                                               FIGURES
% ================================================================================================================================================================================== %


figure('Name','AP using Equity Volatility or HML');
xtext=12*100*regrHML*lambdahatHML;
ytext=12*100*mean(portfolios);
scatter(xtext,ytext,'filled','b');hold on;
% for i=1:N;
%    text(xtext(i)-0.2,ytext(i)+0.2,int2str(i),'FontSize',11,'Color','b');
% end;
xtext=12*100*regrVol*lambdahatVol;
ytext=12*100*mean(portfolios);
scatter(xtext,ytext,'filled','r')
axis([floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext))) floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext)))]);                                             
axis square
line(floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),'LineWidth',2,'Color',[1 0 0])    
xlabel('Predicted Mean Excess Return (in %)','FontSize',8);ylabel('Actual Mean Excess Return (in %)','FontSize',8);
% for i=1:N;
%    text(xtext(i)-0.2,ytext(i)+0.2,int2str(i),'FontSize',11,'Color','r');
% end;

switch sample
    case 1 % Barclays and Reuters
        print('-depsc2','AP_CarryPortfoliosFMB_BR.eps');
    case 2 % Barclays
        print('-depsc2','AP_CarryPortfoliosFMB_Barclays.eps');
end



figure('Name','AP using HML');
xtext=12*100*regrHML*lambdahatHML;
ytext=12*100*mean(portfolios);
scatter(xtext,ytext,'filled','b');hold on;
% for i=1:N;
%    text(xtext(i)-0.2,ytext(i)+0.2,int2str(i),'FontSize',11,'Color','b');
% end;
% xtext=12*100*regrVol*lambdahatVol;
% ytext=12*100*mean(portfolios);
% scatter(xtext,ytext,'filled','r')
axis([floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext))) floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext)))]);                                             
axis square
line(floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),'LineWidth',2,'Color',[1 0 0])    
xlabel('Predicted Mean Excess Return (in %)','FontSize',8);ylabel('Actual Mean Excess Return (in %)','FontSize',8);
% for i=1:N;
%    text(xtext(i)-0.2,ytext(i)+0.2,int2str(i),'FontSize',11,'Color','r');
% end;

switch sample
    case 1 % Barclays and Reuters
        print('-depsc2','AP_CarryPortfoliosFMB_noVol_BR.eps');
    case 2 % Barclays
        print('-depsc2','AP_CarryPortfoliosFMB_noVol_Barclays.eps');
end



figure('Name','AP using Equity Vol');
xtext=12*100*regrVol*lambdahatVol;
ytext=12*100*mean(portfolios);
scatter(xtext,ytext,'filled','r')
axis([floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext))) floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext)))]);                                             
axis square
line(floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),'LineWidth',2,'Color','k')    
xlabel('Predicted Mean Excess Return (in %)','FontSize',8);ylabel('Actual Mean Excess Return (in %)','FontSize',8);
% for i=1:N;
%    text(xtext(i)-0.2,ytext(i)+0.2,int2str(i),'FontSize',11,'Color','r');
% end;

switch sample
    case 1 % Barclays and Reuters
        print('-depsc2','AP_CarryPortfoliosFMB_Vol_BR.eps');
    case 2 % Barclays
        print('-depsc2','AP_CarryPortfoliosFMB_Vol_Barclays.eps');
end


figure('Name','AP using Equity Market Returns');
xtext=12*100*regrMkt*lambdahatMkt;
ytext=12*100*mean(portfolios);
scatter(xtext,ytext,'filled','r')
axis([floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext))) floor(min(min(xtext),min(ytext))) ceil(max(max(xtext),max(ytext)))]);                                             
axis square
line(floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),floor(min(min(xtext),min(ytext))):1/10:ceil(max(max(xtext),max(ytext))),'LineWidth',2,'Color','k')    
xlabel('Predicted Mean Excess Return (in %)','FontSize',8);ylabel('Actual Mean Excess Return (in %)','FontSize',8);

switch sample
    case 1 % Barclays and Reuters
        print('-depsc2','AP_CarryPortfoliosFMB_Mkt_BR.eps');
    case 2 % Barclays
        print('-depsc2','AP_CarryPortfoliosFMB_Mkt_Barclays.eps');
end


% S.e on the mean
mean_se  = zeros(N,1);
for i=1:N
    lags   = 2;
    weight = 1;
    [bv,sebv,R2v,R2vadj,v,F] = olsgmm(12*100*portfolios(:,i),ones(T,1),lags,weight);
    mean_se(i,1) = sebv(1);
end

disp('Results for Table');
Table = [12*100*mean(portfolios); mean_se';sqrt(12)*100*std(portfolios);sqrt(12)*mean(portfolios)./std(portfolios);...
    regrHML(:,1)'; betas_se(:,1)' ; regrHML(:,2)'; betas_se(:,2)';...
    regrVol(:,1)'; betasVol_se(:,1)' ; regrVol(:,2)'; betasVol_se(:,2)'];
latex(Table,'%6.2f');

% ===================================================
% Returns in high vs low volatility times
% ===================================================
disp(' ');
disp('----------------------------------------- ');
disp('Returns in high vs low volatility times');
disp('----------------------------------------- ');
disp(' ');
disp('----------------- ');
disp(' Excess returns');
disp('----------------- ');
portfolios_highvol = portfolios;
for t=1:size(portfolios_highvol,1)
    if EqVol(t)<mean(EqVol)+2*std(EqVol)
        portfolios_highvol(t,:)=NaN;
    end
end
portfolios_lowvol = portfolios;
for t=1:size(portfolios_highvol,1)
    if EqVol(t)>mean(EqVol)+2*std(EqVol)
        portfolios_lowvol(t,:)=NaN;
    end
end
disp('All portfolios ' );
disp(12*100*nanmean(portfolios));
disp(12*100*nanmean(portfolios_highvol));
disp(12*100*nanmean(portfolios_lowvol));
disp('Carry Trades ' );
disp(12*100*nanmean(portfolios(:,end)-portfolios(:,1)));
disp(12*100*nanmean(portfolios_highvol(:,end)-portfolios(:,1)));
disp(12*100*nanmean(portfolios_lowvol(:,end)-portfolios(:,1)));
disp(' ');

figure('Name','Returns High vs Low Vol');
subplot(2,1,1);
bar(12*100*nanmean(portfolios),'y');title('Average Currency Excess Returns');ylabel('in percentages, annualized');
grid on;
subplot(2,1,2);
bar(12*100*nanmean(portfolios_highvol),'r');title('Average Currency Excess Returns in Times of High Global Equity Volatility');ylabel('in percentages, annualized');
grid on;
switch sample
    case 1 % Barclays and Reuters
        print('-depsc2','Returns_High_vs_Low_Vol_BR.eps');
    case 2 % Barclays
        print('-depsc2','Returns_High_vs_Low_Vol_Barclays.eps');
end






% ================================================================================================================================================================================== %
%                                                                               GRAPH CUMULATIVE RETURNS
% ================================================================================================================================================================================== %
date_start= datenum('1/31/2003');       

% sample = 2;
% sample = 1;

switch sample
    case 1
        load(strcat(newpath,'portfolios_logxret_BarclaysandReuters.mat'),'portfolios_logxret_BarclaysandReuters');
        Data      = portfolios_logxret_BarclaysandReuters;
    case 2
        load(strcat(newpath,'portfolios_logxret_Barclays.mat'),'portfolios_logxret_Barclays');
        Data      = portfolios_logxret_Barclays;
end
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
DataFX    = Data(line_start:line_end,:);

HML       = [DataFX(:,1) DataFX(:,end)-DataFX(:,2)];
Cumret    = NaN*zeros(size(HML));
Cumret(:,1) = HML(:,1);
Cumret(1,2) = 100;
for t=2:size(HML,1)
    Cumret(t,2) = Cumret(t-1,2)*(1+HML(t,2));
end


line_start   = find(Data_EquityVol(:,1)==date_start);
line_end     = find(Data_EquityVol(:,1)==date_end_vol);
EqVol_sample = Data_EquityVol(line_start:line_end,2);

line_start_recession  = find(Cumret(:,1)==datenum('11/30/2007'));
line_end_recession    = find(Cumret(:,1)==datenum('6/30/2009'));

line_start_recession_covid  = find(Cumret(:,1)==datenum('2/28/2020'));
line_end_recession_covid    = find(Cumret(:,1)==datenum('4/30/2020')); 


switch sample
    
    case 1 % Barclays and Reuters
        
        figure('Name','Cumulative Returns with Volatility');
        
        rectangle('Position',[Cumret(line_start_recession,1),80.2,Cumret(line_end_recession,1)-Cumret(line_start_recession,1),240-80.2],'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);hold on
        rectangle('Position',[Cumret(line_start_recession_covid,1),80.2,100+Cumret(line_end_recession_covid,1)-Cumret(line_start_recession_covid,1),240-80.2],'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);hold on
               
        x_temp  = Cumret(:,1);
        y1_temp = sqrt(255)*100*EqVol_sample(:,1);
        y2_temp = Cumret(:,2);
        yyaxis left
        plot(x_temp,y2_temp,'LineStyle','-','Color','b','LineWidth',4);% Carry
        ylim([80 240]);
        grid on
        ylabel('Cumulative Returns on Carry Trades','Color','b') % right y-axis
        yyaxis right
        plot(x_temp,y1_temp,'LineStyle','-','Color','r','LineWidth',2);% Vol
        ylim([0 80]);
        ylabel('World Equity Volatility (Annualized, in %)','Color','r') % left y-axis
        datetick
        print('-depsc2','CumulativeReturns_withEquityVolandUSrecession_BR');

    case 2 % Barclays
        
        figure('Name','Cumulative Returns with Volatility');
        rectangle('Position',[Cumret(line_start_recession,1),80.2,Cumret(line_end_recession,1)-Cumret(line_start_recession,1),200-80.2],'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);hold on
        rectangle('Position',[Cumret(line_start_recession_covid,1),80.2,100+Cumret(line_end_recession_covid,1)-Cumret(line_start_recession_covid,1),240-80.2],'FaceColor',[0.9 0.9 0.9],'EdgeColor',[0.9 0.9 0.9]);hold on

        x_temp  = Cumret(:,1);
        y1_temp = sqrt(255)*100*EqVol_sample(:,1);
        y2_temp = Cumret(:,2);
        yyaxis left
        plot(x_temp,y2_temp,'LineStyle','-','Color','b','LineWidth',4);% Carry
        ylim([80 200]);
        grid minor
        ylabel('Cumulative Returns on Carry Trades','Color','b') % right y-axis
        yyaxis right
        plot(x_temp,y1_temp,'LineStyle','-','Color','r','LineWidth',2);% Vol
        ylim([0 90]);
        ylabel('World Equity Volatility (Annualized, in %)','Color','r') % left y-axis
        datetick('x',12)
        ax = gca;
        c = ax.Color;
        ax(1).YAxis(1).Color = 'blue';
        ax(1).YAxis(2).Color = 'red';
       print('-depsc2','CumulativeReturns_withEquityVolandUSrecession_Barclays');
end







        
