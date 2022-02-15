% ==================================================== %
% IMPORT MSCI DAILY DATA
% ==================================================== %
% Program : 
% 1 ) Import daily data on market, value and growth indices,
% 2 ) Check units and errors
% 3 ) Save data in Matlab format
% 4 ) Build monthly series of stock market return volatility


% ============================================= %
% Clear
% ============================================= %
clc;
close all;
clear;

if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end


% ============================================= %
% MSCI STOCK INDICES
% ============================================= %
% MSCI price indices for market, growth and value portfolios for each country

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before importing to Matlab

temp=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet1');
s=size(temp);
MSCI_temp=zeros(s(1),s(2),3);
% First column : Dates
MSCI_Market_temp1=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet1'); % Market Price Index 1976-1986
MSCI_Growth_temp1=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet2'); % Growth Price Index 1976-1986
MSCI_Value_temp1=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet3');  % Value Price Index 1976-1986

MSCI_Market_temp2=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet4'); % Market Price Index 1986-1996
MSCI_Growth_temp2=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet5'); % Growth Price Index 1986-1996
MSCI_Value_temp2=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet6'); % Value Price Index 1986-1996

MSCI_Market_temp3=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet7'); % Market Price Index 1996-2009
MSCI_Growth_temp3=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet8'); % Growth Price Index 1996-2009
MSCI_Value_temp3=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet9'); % Value Price Index 1996-2009

MSCI_Market_temp4=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet10'); % Market Price Index 2009-now
MSCI_Growth_temp4=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet11'); % Growth Price Index 2009-now
MSCI_Value_temp4=xlsread(strcat(newpath,'DataRequests_MSCI_ReturnIndices_USDollars_D.xlsm'),'Sheet12'); % Value Price Index 2009-now

% Aggregate
MSCI_Market_temp=[MSCI_Market_temp1;MSCI_Market_temp2(2:end,:);MSCI_Market_temp3(2:end,:);MSCI_Market_temp4(2:end,:)];
MSCI_Growth_temp=[MSCI_Growth_temp1;MSCI_Growth_temp2(2:end,:);MSCI_Growth_temp3(2:end,:);MSCI_Growth_temp4(2:end,:)];
MSCI_Value_temp=[MSCI_Value_temp1;MSCI_Value_temp2(2:end,:);MSCI_Value_temp3(2:end,:);MSCI_Value_temp4(2:end,:)];

% Transform the date from Excel to Matlab
MSCI_Market_temp(:,1)=MSCI_Market_temp(:,1)+693960;
MSCI_Growth_temp(:,1)=MSCI_Growth_temp(:,1)+693960;
MSCI_Value_temp(:,1)=MSCI_Value_temp(:,1)+693960;

% Code countries
% The MSCI data are available for the following 50 countries:
% ARGENTINA; AUSTRALIA; AUSTRIA; BELGIUM; BRAZIL; CANADA; CHILE; COLOMBIA; CZECH REPUBLIC; DENMARK; EGYPT;
% FINLAND; FRANCE; GERMANY; GREECE; HONG KONG; HUNGARY; INDIA; INDONESIA; IRELAND; ISRAEL; ITALY; JAPAN; JORDAN;
% KOREA; MALAYSIA; MEXICO; MOROCCO; NETHERLANDS; NEW ZEALAND; NORWAY; PAKISTAN; PERU; PHILIPPINES; POLAND; PORTUGAL;
% RUSSIA; SINGAPORE; SOUTH AFRICA; SPAIN; SRI LANKA; SWEDEN; SWITZERLAND; TAIWAN; THAILAND; TURKEY; UK
% USA; VENEZUELA; WORLD.

MSCI_countries={'WORLD';'ARGENTINA'; 'AUSTRALIA'; 'AUSTRIA'; 'BELGIUM'; 'BRAZIL'; 'CANADA'; 'CHILE';...
    'COLOMBIA'; 'CZECH REPUBLIC'; 'DENMARK'; 'EGYPT';'FINLAND'; 'FRANCE'; 'GERMANY'; 'GREECE';...
    'CHINA HONG KONG'; 'HUNGARY'; 'INDIA'; 'INDONESIA'; 'IRELAND'; 'ISRAEL'; 'ITALY'; 'JAPAN'; 'JORDANIA';...
    'SOUTH KOREA'; 'MALAYSIA'; 'MEXICO'; 'MOROCCO'; 'NETHERLANDS'; 'NEW ZEALAND'; 'NORWAY'; 'PAKISTAN'; 'PERU';...
    'PHILIPPINES'; 'POLAND'; 'PORTUGAL';'RUSSIA'; 'SINGAPORE'; 'SOUTH AFRICA'; 'SPAIN'; 'SRI LANKA'; 'SWEDEN';...
    'SWITZERLAND'; 'TAIWAN'; 'THAILAND'; 'TURKEY'; 'UNITED KINGDOM';'UNITED STATES'; 'VENEZUELA';'EMU';...
    'UNITED ARAB EMIRATES';'KUWAIT';'SAUDI ARABIA'};

% Import Country codes (IMF coding)
[CountryCode, CountryName_IMF]= xlsread('IMF_codes');

IMF_codes_MSCI=zeros(1,size(MSCI_countries,1));
for i=1:size(MSCI_countries,1)
    % Find the corresponding IMF code
    for j=1:size(CountryName_IMF,1)     
        if strcmp(CountryName_IMF(j,1),MSCI_countries(i,1))==1
            IMF_codes_MSCI(1,i)=CountryCode(j,1);
        end       
        % Add code 999 for the world aggregate:
        if strcmp('WORLD',MSCI_countries(i,1))==1
            IMF_codes_MSCI(1,i)=999;
        end
        % Add code 163 (EURO AREA) for the EMU aggregate:
        if strcmp('EMU',MSCI_countries(i,1))==1
            IMF_codes_MSCI(1,i)=163;
        end
    end
end

% Insert IMF codes in the first lines:   
MSCI_Market_D=[NaN IMF_codes_MSCI;MSCI_Market_temp];
MSCI_Growth_D=[NaN IMF_codes_MSCI;MSCI_Growth_temp];
MSCI_Value_D=[NaN IMF_codes_MSCI;MSCI_Value_temp];


% ============================================= %
% ERRORS
% ============================================= %

%==========
% Brazil: first values are 0 (then values are rather stale for a while, but I keep them)
%==========
pbBrazil_start=find(MSCI_Market_D(:,1,1)==datenum('12/31/1987'));
pbBrazil_end=find(MSCI_Market_D(:,1)==datenum('1/5/1990'));

for j=1:size(CountryName_IMF,1)
   if strcmp(CountryName_IMF(j,1),'BRAZIL')==1;code_imf=CountryCode(j,1);end       
end
% Find the right series using its IMF code
col_c=find(MSCI_Market_D(1,:)==code_imf);
% Replace 0 with NaN
MSCI_Market_D(pbBrazil_start:pbBrazil_end,col_c)=NaN;


% %==========
% % NEW ZEALAND
% %==========
% 
% for j=1:size(CountryName_IMF,1)
%    if strcmp(CountryName_IMF(j,1),'NEW ZEALAND')==1;code_imf=CountryCode(j,1);end;       
% end;
% % Find the right series using its IMF code
% col_nl=find(MSCI_Market_D(1,:)==code_imf);
% gr_nl=log(MSCI_Market_D(2:end,col_nl))-log(MSCI_Market_D(1:end-1,col_nl));
% line_nl=find(gr_nl==min(gr_nl));
% % MSCI_Market_D(line_nl+2,col_nl)
% % MSCI_Market_D(line_nl+1,col_nl)
% % MSCI_Market_D(line_nl,col_nl)
% % MSCI_Market_D(line_nl-1,col_nl)
% MSCI_Market_D(line_nl+1,col_nl)=NaN;


% ============================================= %
% EXAMPLE
% ============================================= %

% Example: find US market Portfolio data
% First look for the IMF code of the USA
for j=1:size(CountryName_IMF,1)
   if strcmp(CountryName_IMF(j,1),'USA')==1
      code_imf=CountryCode(j,1);
   end       
end
% Find the right series using its IMF code
c=find(MSCI_Market_D(1,:,1)==code_imf);
MSCI_Mkt_USA(:,2)=MSCI_Market_D(2:end,c,1);
MSCI_Mkt_USA(:,1)=MSCI_Market_D(2:end,1,1);
% Compute mean and std of US market return
MSCI_Mkt_USA_ret=MSCI_Mkt_USA(3:end,2)./MSCI_Mkt_USA(2:end-1,2)-1;
% Select 1983 - 2007 period
m= find(MSCI_Market_D(:,1)==datenum(1983,1,31));
n= find(MSCI_Market_D(:,1)==datenum(2007,1,31));
disp(' ');
disp(['Annualized (x 260) average market return US (in %): ' num2str(260*100*nanmean(MSCI_Mkt_USA_ret(m:n,1)),'%10.2f')]);
disp(['Annualized (x sqrt(260)) std market return US (in %): ' num2str(sqrt(260)*100*nanstd(MSCI_Mkt_USA_ret(m:n,1)),'%10.2f')]);
disp(' ');


% ============================================= %
% GRAPHS
% ============================================= %
%There are 50 countries in the sample
show_graphs=1;

if show_graphs==1
    
    % MSCI Market return
    figure('Name','Country by Country MSCI Market return  (in percentage points)');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_D(3:end,1),100*(MSCI_Market_D(3:end,1+k)./MSCI_Market_D(2:end-1,1+k)-1),'b');
        title(MSCI_countries(k,1));
        datetick('x',11)     
    end

    figure('Name','Country by Country MSCI Market return  (in percentage points)');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_D(3:end,1),100*(MSCI_Market_D(3:end,1+25+k)./MSCI_Market_D(2:end-1,1+25+k)-1),'b');
        title(MSCI_countries(25+k,1));
        datetick('x',11)     
    end

end

% ============================================= %
% Extend Samples to End-of-Month
% ============================================= %
MSCI_Market_D    = Extend_EndofMonth(MSCI_Market_D);
MSCI_Growth_D    = Extend_EndofMonth(MSCI_Growth_D);
MSCI_Value_D     = Extend_EndofMonth(MSCI_Value_D);


% =======
% Select Barclays Countries
% =======
load(strcat(newpath,'Barclays_FX_Spot_D.mat'),'Barclays_FX_Spot_D');

Barclays_MSCI_Market_D=NaN*zeros(size(MSCI_Market_D,1),size(Barclays_FX_Spot_D,2));
Barclays_MSCI_Market_D(:,1)=MSCI_Market_D(:,1);       % Dates
Barclays_MSCI_Market_D(1,:)=Barclays_FX_Spot_D(1,:);     % Country codes
for i=2:size(Barclays_FX_Spot_D,2)
    col=find(MSCI_Market_D(1,:)==Barclays_FX_Spot_D(1,i));
    if isempty(col)==0
        Barclays_MSCI_Market_D(2:end,i)=MSCI_Market_D(2:end,col);
    end
end


% =======
% Switch frequency to monthly
% =======
% Transform all series into end-of-the month series

NM=months(Barclays_MSCI_Market_D(2,1),Barclays_MSCI_Market_D(end,1));
Barclays_MSCI_Market_dM     = NaN*zeros(NM,size(Barclays_MSCI_Market_D,2));
Barclays_MSCI_Market_dM(1,:)= Barclays_MSCI_Market_D(1,:); % Codes

% Data
k=2;
for t=2:size(Barclays_MSCI_Market_D,1)-1
    if month(Barclays_MSCI_Market_D(t,1))~=month(Barclays_MSCI_Market_D(t+1,1)) % find end-of-month
        [N, S]=weekday(Barclays_MSCI_Market_D(t,1));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        Barclays_MSCI_Market_dM(k,:) = Barclays_MSCI_Market_D(t+j,:);
        k=k+1;
    end
end

% =======
% Select Barclays/Reuters Countries
% =======
load(strcat(newpath,'BR_Spot_D.mat'),'BR_Spot_D');

BR_MSCI_Market_D=NaN*zeros(size(MSCI_Market_D,1),size(BR_Spot_D,2));
BR_MSCI_Market_D(:,1)=MSCI_Market_D(:,1);       % Dates
BR_MSCI_Market_D(1,:)=BR_Spot_D(1,:);               % Country codes
for i=2:size(BR_Spot_D,2)
    col=find(MSCI_Market_D(1,:)==BR_Spot_D(1,i));
    if isempty(col)==0
        BR_MSCI_Market_D(2:end,i)=MSCI_Market_D(2:end,col);
    end
end

% =======
% Switch frequency to monthly
% =======
% Transform all series into end-of-the month series

NM=months(BR_MSCI_Market_D(2,1),BR_MSCI_Market_D(end,1));
BR_MSCI_Market_dM     = NaN*zeros(NM,size(BR_MSCI_Market_D,2));
BR_MSCI_Market_dM(1,:)= BR_MSCI_Market_D(1,:); % Codes

% Data
k=2;
for t=2:size(BR_MSCI_Market_D,1)-1
    if month(BR_MSCI_Market_D(t,1))~=month(BR_MSCI_Market_D(t+1,1)) % find end-of-month
        [N, S]=weekday(BR_MSCI_Market_D(t,1));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        BR_MSCI_Market_dM(k,:) = BR_MSCI_Market_D(t+j,:);
        k=k+1;
    end
end


% =======
% Switch frequency to monthly (ALL SERIES)
% =======
% Transform all series into end-of-the month series

NM=months(MSCI_Market_D(2,1),MSCI_Market_D(end,1));
MSCI_Market_dM     = NaN*zeros(NM,size(MSCI_Market_D,2));
MSCI_Market_dM(1,:)= MSCI_Market_D(1,:); % Codes
MSCI_Growth_dM     = NaN*zeros(NM,size(MSCI_Growth_D,2));
MSCI_Growth_dM(1,:)= MSCI_Growth_D(1,:); % Codes
MSCI_Value_dM     = NaN*zeros(NM,size(MSCI_Value_D,2));
MSCI_Value_dM(1,:)= MSCI_Value_D(1,:); % Codes

% Data
k=2;
for t=2:size(MSCI_Market_D,1)-1
    if month(MSCI_Market_D(t,1))~=month(MSCI_Market_D(t+1,1)) % find end-of-month
        [N, S]=weekday(MSCI_Market_D(t,1));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        MSCI_Market_dM(k,:) = MSCI_Market_D(t+j,:);
        MSCI_Growth_dM(k,:) = MSCI_Growth_D(t+j,:);
        MSCI_Value_dM(k,:)  = MSCI_Value_D(t+j,:);
        k=k+1;
    end
end


% ============================================= %
% SAVE .MAT
% ============================================= %
save(strcat(newpath,'BR_MSCI_Market_ReturnIndices_USDollars_D.mat'),'BR_MSCI_Market_D');
save(strcat(newpath,'BR_MSCI_Market_ReturnIndices_USDollars_dM.mat'),'BR_MSCI_Market_dM');
save(strcat(newpath,'Barclays_MSCI_Market_ReturnIndices_USDollars_D.mat'),'Barclays_MSCI_Market_D');
save(strcat(newpath,'Barclays_MSCI_Market_ReturnIndices_USDollars_dM.mat'),'Barclays_MSCI_Market_dM');
save(strcat(newpath,'MSCI_Market_ReturnIndices_USDollars_dM.mat'),'MSCI_Market_dM');
save(strcat(newpath,'MSCI_Growth_ReturnIndices_USDollars_dM.mat'),'MSCI_Growth_dM');
save(strcat(newpath,'MSCI_Value_ReturnIndices_USDollars_dM.mat'),'MSCI_Value_dM');

save(strcat(newpath,'MSCI_Market_ReturnIndices_USDollars_D.mat'),'MSCI_Market_D');
save(strcat(newpath,'MSCI_Growth_ReturnIndices_USDollars_D.mat'),'MSCI_Growth_D');
save(strcat(newpath,'MSCI_Value_ReturnIndices_USDollars_D.mat'),'MSCI_Value_D');
save(strcat(newpath,'MSCI_countries_ReturnIndices_USDollars.mat'),'MSCI_countries');


% ============================================= %
% BUILD MONTHLY SERIES OF MARKET RETURN VOLATILITY AND SHARPE RATIO
% ============================================= %

% =======
% Build daily market returns
% =======
MSCI_Market_D_ret=NaN*zeros(size(MSCI_Market_D));
MSCI_Market_D_ret(:,1)=MSCI_Market_D(:,1);                                                 % Dates
MSCI_Market_D_ret(1,:)=MSCI_Market_D(1,:);                                                 % IMF codes
MSCI_Market_D_ret(3:end,2:end)=MSCI_Market_D(3:end,2:end)./MSCI_Market_D(2:end-1,2:end)-1; % Market return

% =======
% Build monthly market return volatility
% =======
MSCI_Market_M_vol=NaN*zeros(1+months(MSCI_Market_D(2,1),MSCI_Market_D(end,1)),size(MSCI_Market_D,2)+1);
MSCI_Market_M_vol(1,:)=[MSCI_Market_D(1,:) NaN];                                                 % IMF codes
MSCI_Market_M_sr=NaN*zeros(1+months(MSCI_Market_D(2,1),MSCI_Market_D(end,1)),size(MSCI_Market_D,2)+1);
MSCI_Market_M_sr(1,:)=[MSCI_Market_D(1,:) NaN];                                                 % IMF codes
% Dates
for i=1:size(MSCI_Market_M_vol,1)-1
    MSCI_Market_M_vol(i+1,1)=datenum(1976+floor((i-1)/12),1+mod(i-1,12),eomday(1976+floor((i-1)/12),1+mod(i-1,12)));
    MSCI_Market_M_sr(i+1,1)=datenum(1976+floor((i-1)/12),1+mod(i-1,12),eomday(1976+floor((i-1)/12),1+mod(i-1,12)));
end
% Volatility
for t=2:size(MSCI_Market_M_vol,1)
    rows_temp=find(month(MSCI_Market_D_ret(:,1))==month(MSCI_Market_M_vol(t,1)) & ...
        year(MSCI_Market_D_ret(:,1))==year(MSCI_Market_M_vol(t,1)));
    for k=2:size(MSCI_Market_D_ret,2)
        MSCI_Market_M_vol(t,k)=nanstd(MSCI_Market_D_ret(rows_temp,k));
        MSCI_Market_M_sr(t,k)=nanmean(MSCI_Market_D_ret(rows_temp,k))/nanstd(MSCI_Market_D_ret(rows_temp,k));
    end
    % For HML
    MSCI_Market_M_vol(t,end)=nanstd(MSCI_Market_D_ret(rows_temp,end)-MSCI_Market_D_ret(rows_temp,2));
    MSCI_Market_M_sr(t,end)=nanmean(MSCI_Market_D_ret(rows_temp,end)-MSCI_Market_D_ret(rows_temp,2))...
                            /nanstd(MSCI_Market_D_ret(rows_temp,end)-MSCI_Market_D_ret(rows_temp,2));
end

% Check
disp(' ');
disp('Annualized (x sqrt(12)) std market return (in %): ');
disp(sqrt(12)*100*nanmean(MSCI_Market_M_vol(2:end,2:end)) )

% =======
% Build monthly market return correlation with US market
% =======
MSCI_Market_M_corr=NaN*zeros(1+months(MSCI_Market_D(2,1),MSCI_Market_D(end,1)),size(MSCI_Market_D,2));
MSCI_Market_M_corr(1,:)=MSCI_Market_D(1,:);                                                 % IMF codes
% Dates
for i=1:size(MSCI_Market_M_corr,1)-1
    MSCI_Market_M_corr(i+1,1)=datenum(1976+floor((i-1)/12),1+mod(i-1,12),eomday(1976+floor((i-1)/12),1+mod(i-1,12)));
end
% Correlation
colUS=find(MSCI_Market_D_ret(1,:)==111);
for t=2:size(MSCI_Market_M_vol,1)
%     % Correlation over one month
    rows_temp=find(month(MSCI_Market_D_ret(:,1))==month(MSCI_Market_M_vol(t,1)) & ...
        year(MSCI_Market_D_ret(:,1))==year(MSCI_Market_M_vol(t,1)));
%     for k=2:size(MSCI_Market_M_corr,2)
%         MSCI_Market_M_corr(t,k)=corr(MSCI_Market_D_ret(rows_temp,k),MSCI_Market_D_ret(rows_temp,colUS));
%     end;
    % Correlation over the last 100 days
    lags=100;
    date_temp=rows_temp(end);
    for k=2:size(MSCI_Market_M_corr,2)
        if t>12
            MSCI_Market_M_corr(t,k)=corr(MSCI_Market_D_ret(date_temp-lags:date_temp,k),MSCI_Market_D_ret(date_temp-lags:date_temp,colUS));
        end
    end
end

% =======
% Select Barclays Countries
% =======
load(strcat(newpath,'Barclays_FX_Spot_D.mat'),'Barclays_FX_Spot_D');
load(strcat(newpath,'Barclays_Countries.mat'),'List_names');

Barclays_Countries=List_names;
Barclays_MSCI_Market_M_vol=NaN*zeros(size(MSCI_Market_M_vol,1),size(Barclays_FX_Spot_D,2));
Barclays_MSCI_Market_M_vol(:,1)=MSCI_Market_M_vol(:,1);
Barclays_MSCI_Market_M_vol(1,:)=Barclays_FX_Spot_D(1,:);
Barclays_MSCI_Market_M_sr=NaN*zeros(size(MSCI_Market_M_sr,1),size(Barclays_FX_Spot_D,2));
Barclays_MSCI_Market_M_sr(:,1)=MSCI_Market_M_sr(:,1);
Barclays_MSCI_Market_M_sr(1,:)=Barclays_FX_Spot_D(1,:);
Barclays_MSCI_Market_M_corr=NaN*zeros(size(MSCI_Market_M_sr,1),size(Barclays_FX_Spot_D,2));
Barclays_MSCI_Market_M_corr(:,1)=MSCI_Market_M_corr(:,1);
Barclays_MSCI_Market_M_corr(1,:)=Barclays_FX_Spot_D(1,:);
for i=2:size(Barclays_FX_Spot_D,2)
    col=find(MSCI_Market_M_vol(1,:)==Barclays_FX_Spot_D(1,i));
    if isempty(col)==0
        Barclays_MSCI_Market_M_vol(2:end,i)=MSCI_Market_M_vol(2:end,col);
        Barclays_MSCI_Market_M_sr(2:end,i)=MSCI_Market_M_sr(2:end,col);
        Barclays_MSCI_Market_M_corr(2:end,i)=MSCI_Market_M_corr(2:end,col);
    end
end
% =======
% Select Barclays/Reuters Countries
% =======
load(strcat(newpath,'BR_Spot_D.mat'),'BR_Spot_D');
load(strcat(newpath,'List_names_BR.mat'),'List_names_BR');

BR_Countries=List_names_BR;
BR_MSCI_Market_M_vol=NaN*zeros(size(MSCI_Market_M_vol,1),size(BR_Spot_D,2));
BR_MSCI_Market_M_vol(:,1)=MSCI_Market_M_vol(:,1);
BR_MSCI_Market_M_vol(1,:)=BR_Spot_D(1,:);
BR_MSCI_Market_M_sr=NaN*zeros(size(MSCI_Market_M_vol,1),size(BR_Spot_D,2));
BR_MSCI_Market_M_sr(:,1)=MSCI_Market_M_vol(:,1);
BR_MSCI_Market_M_sr(1,:)=BR_Spot_D(1,:);
BR_MSCI_Market_M_corr=NaN*zeros(size(MSCI_Market_M_vol,1),size(BR_Spot_D,2));
BR_MSCI_Market_M_corr(:,1)=MSCI_Market_M_corr(:,1);
BR_MSCI_Market_M_corr(1,:)=BR_Spot_D(1,:);
for i=2:size(BR_Spot_D,2)
    col=find(MSCI_Market_M_vol(1,:)==BR_Spot_D(1,i));
    if isempty(col)==0
        BR_MSCI_Market_M_vol(2:end,i)=MSCI_Market_M_vol(2:end,col);
        BR_MSCI_Market_M_sr(2:end,i)=MSCI_Market_M_sr(2:end,col);
        BR_MSCI_Market_M_corr(2:end,i)=MSCI_Market_M_corr(2:end,col);
    end
end

% =======
% Save
% =======
save(strcat(newpath,'MSCI_Market_M_vol_ReturnIndices_USDollars.mat'),'MSCI_Market_M_vol');
save(strcat(newpath,'Barclays_MSCI_Market_M_vol_ReturnIndices_USDollars.mat'),'Barclays_MSCI_Market_M_vol');
save(strcat(newpath,'BR_MSCI_Market_M_vol_ReturnIndices_USDollars.mat'),'BR_MSCI_Market_M_vol');

save(strcat(newpath,'MSCI_Market_M_sr_ReturnIndices_USDollars.mat'),'MSCI_Market_M_sr');
save(strcat(newpath,'Barclays_MSCI_Market_M_sr_ReturnIndices_USDollars.mat'),'Barclays_MSCI_Market_M_sr');
save(strcat(newpath,'BR_MSCI_Market_M_sr_ReturnIndices_USDollars.mat'),'BR_MSCI_Market_M_sr');

save(strcat(newpath,'MSCI_Market_M_corr_ReturnIndices_USDollars.mat'),'MSCI_Market_M_corr');
save(strcat(newpath,'Barclays_MSCI_Market_M_corr_ReturnIndices_USDollars.mat'),'Barclays_MSCI_Market_M_corr');
save(strcat(newpath,'BR_MSCI_Market_M_corr_ReturnIndices_USDollars.mat'),'BR_MSCI_Market_M_corr');

% ============================================= %
% GRAPHS
% ============================================= %
%There are 50 countries in the sample
if show_graphs==1
    
    % MSCI Market return volatility
    figure('Name','Country by Country MSCI Market return volatility (in percentage points)');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_M_vol(2:end,1),100*MSCI_Market_M_vol(2:end,1+k),'b');
        title(MSCI_countries(k,1));
        datetick('x',11)     
    end

    figure('Name','Country by Country MSCI Market return volatility (in percentage points)');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_M_vol(2:end,1),100*MSCI_Market_M_vol(2:end,1+25+k),'b');
        title(MSCI_countries(25+k,1));
        datetick('x',11)     
    end

    % MSCI Market Sharpe ratio
    figure('Name','Country by Country MSCI Market Sharpe ratio');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_M_sr(2:end,1),MSCI_Market_M_sr(2:end,1+k),'b');
        title(MSCI_countries(k,1));
        datetick('x',11)     
    end

    figure('Name','Country by Country MSCI Market return volatility (in percentage points)');
    for k=1:25
        subplot(5,5,k);
        plot(MSCI_Market_M_sr(2:end,1),MSCI_Market_M_sr(2:end,1+25+k),'b');
        title(MSCI_countries(25+k,1));
        datetick('x',11)     
    end
    
    % MSCI Market Sharpe ratio
    figure('Name','Country by Country MSCI Market Sharpe ratio');
    for k=1:39
        subplot(5,8,k);
        plot(BR_MSCI_Market_M_sr(2:end,1),BR_MSCI_Market_M_sr(2:end,1+k),'b');
        title(BR_Countries(1+k,1));
        datetick('x',11)     
    end

    % MSCI Market Sharpe ratio
    figure('Name','Country by Country MSCI Market return volatility (in percentage points)');
    for k=1:39
        subplot(5,8,k);
        plot(BR_MSCI_Market_M_vol(2:end,1),100*BR_MSCI_Market_M_vol(2:end,1+k),'b');
        title(BR_Countries(1+k,1));
        datetick('x',11)     
    end


    % MSCI Market Correlation
    figure('Name','Country by Country MSCI Market Correlation');
    for k=1:39
        subplot(5,8,k);
        plot(BR_MSCI_Market_M_corr(2:end,1),BR_MSCI_Market_M_corr(2:end,1+k),'b');
        title(BR_Countries(1+k,1));
        datetick('x',11)     
    end

end
