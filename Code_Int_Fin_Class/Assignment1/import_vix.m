
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
newpath_vix = '/Users/whn2105/Documents/MacroFinance/Data_Int_Fin_Class/rawdata/vix/';

% ============================================= %
% Options
% ============================================= %
filename='VIX_history.csv';  %  Return indices in local currency
filename_pre2003 = 'vixarchive.xls';
date_start= datenum(2004,11,30);       
date_end  = datenum(2020,7,31);

% ============================================= %
% Load in and clean VIX data from 2003 onwards
% ============================================= %

temp=readtable(strcat(newpath_vix,filename));
temp.DATE = datenum(temp.DATE);
% turn it into a matrix
vix_D = table2array(temp);

% ============================================= %
% Load in and clean VIX data from before 2003
% ============================================= %
% temp=readtable(strcat(newpath_vix,filename_pre2003));
% temp.Date = datenum(temp.Date);
% % turn it into a matrix
% vix_D2 = table2array(temp);
% vix_D = cat(1,vix_D2, vix_D1);


% =======
% Switch frequency of VIX series to monthly
% =======
% Transform all series into end-of-the month series
NM=split(between(datetime(vix_D(1,1),'ConvertFrom','datenum'),datetime(vix_D(end,1),'ConvertFrom','datenum'), 'Months'), 'Months');
vix_DM     = NaN*zeros(NM,size(vix_D,2));
vix_DM(1,:)= vix_D(1,:); % Codes

% Data
k=1;
for t=1:size(vix_D,1)-1
    if month(datetime(vix_D(t,1),'ConvertFrom','datenum'))~=month(datetime(vix_D(t+1,1),'ConvertFrom','datenum')) % find end-of-month
        [N, S]=weekday(datetime(vix_D(t,1),'ConvertFrom','datenum'));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        vix_DM(k,:) = vix_D(t+j,:);
        k=k+1;
    end
end

% ============================================= %
% Select the desired months of data
% ============================================= %
line_start= find(vix_DM(:,1)==date_start);
line_end  = find(vix_DM(:,1)==date_end);
vix_DM=vix_DM(line_start:line_end,:);

% ============================================= %
% Load in the 6 portfolios and cut down to specified dates
% ============================================= %

load(strcat(newpath,'portfolios_FXXR_BarclaysandReuters.mat'));
portfolios = portfolios_FXXR_BarclaysandReuters;
line_start= find(portfolios(:,1)==date_start);
line_end  = find(portfolios(:,1)==date_end);
portfolios=portfolios(line_start:line_end,:);
HML = 100*(portfolios(:,7)-portfolios(:,2));
fxxr_cumulative = zeros(size(portfolios, 1),2);
fxxr_cumulative(:,1) = portfolios(:,1);
fxxr_cumulative(:,2) = 100+cumsum(HML);

% ============================================= %
% Create array of dates, HmL portfolio returns, and volatility
% ============================================= %
data_to_graph = zeros(size(vix_DM, 1), 3);
data_to_graph(:,1) = vix_DM(:,1);
data_to_graph(:,2) = vix_DM(:,5); % the VIX close
% data_to_graph(:,3) = portfolios_FXXR_BarclaysandReuters(:,7)-portfolios_FXXR_BarclaysandReuters(:,2); % HmL spot change
data_to_graph(:,3) = fxxr_cumulative(:,2);
dates = datetime(data_to_graph(:,1),'ConvertFrom','datenum');

% ============================================= %
% Plot it
% ============================================= %
hold on;
figure('Name','AP using Equity Volatility or HML');
plot(dates,data_to_graph(:,2));
yyaxis right
plot(dates,data_to_graph(:,3));
ylabel('High Minus Low');
yyaxis left
ylabel('VIX');
title('Carry Trade Return and Global Volatility');
hold off;

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


