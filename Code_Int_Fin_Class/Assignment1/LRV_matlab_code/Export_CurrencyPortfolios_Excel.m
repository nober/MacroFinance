% Export data to Excel

% ============================================= %
% Clear
% ============================================= %
clc;
close all;
clear;


% ============================================= %
% Load portfolios & Build Excel File
% ============================================= %
if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end

date_start= datenum('11/30/1983');       
% date_end  = datenum('09/28/2018');       
% date_end  = datenum('10/31/2018');       
% date_end  = datenum('9/30/2019');       
% date_end  = datenum('3/31/2020');       
% date_end  = datenum('4/30/2020');       
date_end  = datenum(2021,5,31);

% One-month lag (to automate end date)
% if month(now)==1
%     date_end  = datenum(year(now)-1,12,eomday(year(now)-1,12));       
% else
%     date_end  = datenum(year(now),month(now)-1,eomday(year(now),month(now)-1));       
% end


% --------------------
% Sorted on forward discounts, all countries
% --------------------

load(strcat(newpath,'portfolios_xretba_BarclaysandReuters.mat'),'portfolios_xretba_BarclaysandReuters');
Data      = portfolios_xretba_BarclaysandReuters;
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'All currencies (net)','A2');

load(strcat(newpath,'portfolios_xret_BarclaysandReuters.mat'),'portfolios_xret_BarclaysandReuters');
Data      = portfolios_xret_BarclaysandReuters;
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'All currencies','A2');

% Average Equity volatility (from excess returns for foreign investors in local currencies)
% load(strcat(newpath,'average_Rlocvol_MSCI_dM.mat'),'average_Rlocvol_MSCI_dM');
% Data      = average_Rlocvol_MSCI_dM;
load(strcat(newpath,'BR_MSCI_Market_M_vol.mat'),'BR_MSCI_Market_M_vol');
Data      = [BR_MSCI_Market_M_vol(:,1) nanmean(BR_MSCI_Market_M_vol(:,2:end),2)];
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'All currencies','N2');

% --------------------
% Sorted on forward discounts, developed countries
% --------------------

load(strcat(newpath,'portfolios_xretba_Barclays.mat'),'portfolios_xretba_Barclays');
Data      = portfolios_xretba_Barclays;
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'Developed currencies (net)','A2');

load(strcat(newpath,'portfolios_xret_Barclays.mat'),'portfolios_xret_Barclays');
Data      = portfolios_xret_Barclays;
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'Developed currencies','A2');

% Average Equity volatility (from excess returns for foreign investors in local currencies)
% load(strcat(newpath,'average_Rlocvol_MSCI_Barclays_dM.mat'),'average_Rlocvol_MSCI_Barclays_dM');
% Data      = average_Rlocvol_MSCI_Barclays_dM;
load(strcat(newpath,'Barclays_MSCI_Market_M_vol.mat'),'Barclays_MSCI_Market_M_vol');
Data      = [Barclays_MSCI_Market_M_vol(:,1) nanmean(Barclays_MSCI_Market_M_vol(:,2:end),2)];
line_start= find(Data(:,1)==date_start);
line_end  = find(Data(:,1)==date_end);
Data      = Data(line_start:line_end,:);
Data(:,1) = Data(:,1)-693960;
xlswrite('CurrencyPortfolios.xls', Data, 'Developed currencies','N2');

                    