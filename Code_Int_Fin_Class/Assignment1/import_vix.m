
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
date_start= datenum('11/30/2000');       
date_end  = datenum(2020,7,30);

% ============================================= %
% Load in and clean VIX data from 2003 onwards
% ============================================= %

temp=readtable(strcat(newpath_vix,filename));
temp.DATE = datenum(temp.DATE);
% turn it into a matrix
vix_D1 = table2array(temp);

% ============================================= %
% Load in and clean VIX data from before 2003
% ============================================= %
temp=readtable(strcat(newpath_vix,filename_pre2003));
temp.Date = datenum(temp.Date);
% turn it into a matrix
vix_D2 = table2array(temp);
vix_D = cat(1,vix_D2, vix_D1);


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
% Load in the 6 portfolios
% ============================================= %

load(strcat(newpath,'portfolios_Spotchg_BarclaysandReuters.mat'));
% portfolios_HmL = zeros(size(portfolios_Spotchg_BarclaysandReuters
