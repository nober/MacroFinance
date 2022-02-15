% This program imports US daily  interest rates

% ============================================= %
% Clear
% ============================================= %
clc;
close all;
% clear;

if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end

newpath = '/Users/whn2105/Documents/MacroFinance/Data_Int_Fin_Class/rawdata/fx/';

%///////////////////////////
% US Interest Rates
%///////////////////////////
% Source: Datastream

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.

% 1: dates
% 2: US TREASURY CONSTANT MATURITIES 1 MTH
% 3: US TREASURY CONSTANT MATURITIES 3 MTH
% 4: US TREASURY CONSTANT MATURITIES 6 MTH
% 5: US TREASURY CONSTANT MATURITIES 1 YR
% 6: US TREASURY CONSTANT MATURITIES 2 YR
% 7: US TREASURY CONSTANT MATURITIES 3 YR
% 8: US TREASURY CONSTANT MATURITIES 5 YR
% 9: US TREASURY CONSTANT MATURITIES 7 YR
% 10: US TREASURY CONSTANT MATURITIES 10 YR
% 11: US TREASURY CONSTANT MATURITIES 20 YR
% 12: US TREASURY CONSTANT - 30 YR
% 13: US EURO$ DEP. 1 MTH (BID,LDN)
% 14: US EURO$ DEP. 3 MTH (BID,LDN)
% 15: US EURO$ DEP. 6 MTH (BID,LDN)
% 16: US FEDERAL FUNDS (EFFECTIVE)
% 17: US FED FUNDS EFFECT RATE (7 DAY AVG)
% 18: US FEDERAL FUNDS TARGET RATE
% 19: US TREASURY BILL 2ND MKT 4-WK - MIDDLE RATE
% 20: US TREASURY BILL 2ND MARKET 3 MONTH - MIDDLE RATE
% 21: US TREASURY BILL 2ND MARKET 6 MONTH - MIDDLE RATE
% 22: US INTERBANK O/N (LDN:BBA)
% 23: US INTERBANK 1 WEEK (LDN:BBA)
% 24: US INTERBANK 2 WEEK (LDN:BBA)
% 25: US INTERBANK 1 MTH (LDN:BBA)
% 26: US INTERBANK 2 MTH (LDN:BBA)
% 27: US INTERBANK 3 MTH (LDN:BBA)
% 28: US INTERBANK 4 MTH (LDN:BBA)
% 29: US INTERBANK 5 MTH (LDN:BBA)
% 30: US INTERBANK 6 MTH (LDN:BBA)
% 31: US INTERBANK 7 MTH (LDN:BBA)
% 32: US INTERBANK 8 MTH (LDN:BBA)
% 33: US INTERBANK 9 MTH (LDN:BBA)
% 34: US INTERBANK 10 MTH (LDN:BBA)
% 35: US INTERBANK 11 MTH (LDN:BBA)
% 36: US INTERBANK 12 MTH (LDN:BBA)
% 37: US EURO-$ 1 M (FT/ICAP)
% 38: US EURO-$ 1 WK (FT/ICAP)
% 39: US EURO-$ 1 Y (FT/ICAP)
% 40: US EURO-$ 3 M (FT/ICAP)
% 41: US EURO-$ 6 M (FT/ICAP)
% 42: US EURO-$ S/T (FT/ICAP)


USIR_temp1=xlsread(strcat(newpath,'DataRequest_USInterestrates.xlsm'),'Sheet1');% 1962-2002
USIR_temp2=xlsread(strcat(newpath,'DataRequest_USInterestrates.xlsm'),'Sheet2');% 2002-2009
USIR_temp3=xlsread(strcat(newpath,'DataRequest_USInterestrates.xlsm'),'Sheet3');% 2009-
USIR_temp = [USIR_temp1;USIR_temp2(2:end,:);USIR_temp3(2:end,:)];

% Matlab dates
USIR_temp(:,1)=USIR_temp(:,1)+693960;

% Graph
figure;plot(USIR_temp(:,1),USIR_temp(:,2:end));datetick;title('US Interest Rates');

figure;plot(USIR_temp(:,1),USIR_temp(:,19:21),...
    USIR_temp(:,1),USIR_temp(:,37),USIR_temp(:,1),USIR_temp(:,40:41));datetick;title('US Short-Term Interest Rates');
legend('TREASURY BILL 2ND MKT 4-WK','TREASURY BILL 2ND MARKET 3 MONTH','TREASURY BILL 2ND MARKET 6 MONTH',...
    'EURO-$ 1 M','US EURO-$ 3 M','US EURO-$ 6 M');

figure;plot(USIR_temp(:,1),USIR_temp(:,5:12));datetick;title('US Long-Term Interest Rates - CONSTANT MATURITIES');
legend('1 YR','2 YR','3 YR','5 YR','7 YR','10 YR','20 YR','30 YR');


% Export
USIR_D = USIR_temp;
save(strcat(newpath,'USIR_D.mat'),'USIR_D');

% Extend Samples to End-of-Month
USIR_D    = Extend_EndofMonth(USIR_D);

% Transform  series into end-of-the month series
NM=split(between(datetime(USIR_D(1,1),'ConvertFrom','datenum'),datetime(USIR_D(end,1),'ConvertFrom','datenum'),'Months'),'Months');
USIR_dM     = NaN*zeros(NM,size(USIR_D,2));
k=1;
for t=2:size(USIR_D,1)-1
    if month(datetime(USIR_D(t,1),'ConvertFrom','datenum'))~=month(datetime(USIR_D(t+1,1),'ConvertFrom','datenum')) % find end-of-month
        [N, S]=weekday(datetime(USIR_D(t,1),'ConvertFrom','datenum'));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        USIR_dM(k,:) = USIR_D(t+j,:);
        k=k+1;
    end
end
save(strcat(newpath,'USIR_dM.mat'),'USIR_dM');

figure;
subplot(3,1,1);plot(USIR_dM(:,1),USIR_dM(:,19:21));datetick;title('US Short-Term Interest Rates - TREASURY BILL 2ND MARKET');
legend('4-WK','3 MONTH','6 MONTH');
subplot(3,1,2);plot(USIR_dM(:,1),USIR_dM(:,13:15));datetick;title('US Short-Term Interest Rates - US EURO$ DEP.');
legend('1 MTH','3 MTH','6 MTH');
subplot(3,1,3);plot(USIR_dM(:,1),USIR_dM(:,37),USIR_dM(:,1),USIR_dM(:,40:41));datetick;title('US Short-Term Interest Rates - US EURO-$.');
legend('1 MTH','3 MTH','6 MTH');

figure;plot(USIR_dM(:,1),USIR_dM(:,5:12));datetick;title('US Long-Term Interest Rates - CONSTANT MATURITIES');
legend('1 YR','2 YR','3 YR','5 YR','7 YR','10 YR','20 YR','30 YR');

