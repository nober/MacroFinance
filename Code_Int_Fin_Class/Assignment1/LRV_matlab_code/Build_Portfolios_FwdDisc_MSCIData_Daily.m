% ============================================= %
% Description
% ============================================= %

% Program : 
% 1 ) Import MSCI daily data on equity return, select subsample
% 2 ) Import daily data on spot and forward exchange rates, select subsample
% 3 ) Build portfolios of daily and monthly equity returns on the basis of the forward discount


% ============================================= %
% Clear
% ============================================= %
clc;
close all;
clear;


% ============================================= %
% Options
% ============================================= %
number_portfolios        = 6;   % Number of portfolios
hor_fwd_rate             = 1;   % Choose the forward rate used to sort currencies:
                                   % 1= one month; 2= two months; 3= three months;
                                   % 4= six; months; 5= one year.
option_ret               = 1;   % Choose the forward rate used to compute returns:
                                   % 1= one month; 2= two months; 3= three months;
                                   % 4= six; months; 5= one year.
msci_dollars             = 2;    % Choose equity returns
                                % 1 = excess returns for a US investor (no hedging of currency risk)
                                % 2 = keep in local currency (excess returns for a foreign investor)
                                % 3 = excess returns for a US investor (hedging of currency risk)
option_overlapping       = 1;    % If 1, compute daily changes in exchange rates.
                                 % If not 1, compute (e.g) one-month
                                 % overlapping excess returns [DO NOT USE]
                                
sample                   = 2; 
                                 % 1 = Barclays and Reuters;
                                 % 2 = Barclays;
                                 
if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end

date_begin=datenum('1/31/1983');     % Start building portfolios
load(strcat(newpath,'BR_Spot_D.mat'));                       %FX_Spot
date_end=BR_Spot_D(end,1);

estimation_date_begin=datenum('1/31/1983');      % Start estimation
estimation_date_end=date_end;          % End estimation


% ============================================= %
% Import data downloaded from Datastream    
% ============================================= %

% Import data downloaded from Datastream (See prgm Merge_Barclays_Reuters_Daily.m)    
% NB: in units of foreign currency per USD


switch sample
    case 1 % Barclays and Reuters
        load(strcat(newpath,'BR_Fwd_D.mat'));                        %FX_Fwd
        FX_Fwd=BR_Fwd_D;
        load(strcat(newpath,'BR_Spot_D.mat'));                       %FX_Spot
        FX_Spot=BR_Spot_D;
        load(strcat(newpath,'BR_Fwd_EB_D.mat'));                     %FX_Fwd Bid
        FX_Fwd_EB=BR_Fwd_EB_D;
        load(strcat(newpath,'BR_Spot_EB_D.mat'));                    %FX_Spot Bid
        FX_Spot_EB=BR_Spot_EB_D;
        load(strcat(newpath,'BR_Fwd_EO_D.mat'));                     %FX_Fwd Ask
        FX_Fwd_EO=BR_Fwd_EO_D;
        load(strcat(newpath,'BR_Spot_EO_D.mat'));                    %FX_Spot Ask
        FX_Spot_EO=BR_Spot_EO_D;
        load(strcat(newpath,'List_names_BR.mat'));                   %List_names
        load(strcat(newpath,'BR_MSCI_Market_D.mat'));                %MSCI
        MSCI=BR_MSCI_Market_D;
        date_begin_msci=date_begin;
        date_end_msci=date_end;
        
    case 2 % Barclays
        load(strcat(newpath,'Barclays_FX_Fwd_D.mat'));                        %FX_Fwd
        FX_Fwd=Barclays_FX_Fwd_D;
        load(strcat(newpath,'Barclays_FX_Spot_D.mat'));                       %FX_Spot
        FX_Spot=Barclays_FX_Spot_D;
        load(strcat(newpath,'Barclays_FX_Fwd_EB_D.mat'));                     %FX_Fwd Bid
        FX_Fwd_EB=Barclays_FX_Fwd_EB_D;
        load(strcat(newpath,'Barclays_FX_Spot_EB_D.mat'));                    %FX_Spot Bid
        FX_Spot_EB=Barclays_FX_Spot_EB_D;
        load(strcat(newpath,'Barclays_FX_Fwd_EO_D.mat'));                     %FX_Fwd Ask
        FX_Fwd_EO=Barclays_FX_Fwd_EO_D;
        load(strcat(newpath,'Barclays_FX_Spot_EO_D.mat'));                    %FX_Spot Ask
        FX_Spot_EO=Barclays_FX_Spot_EO_D;
        load(strcat(newpath,'List_names_Barclays.mat'));                   %List_names
        load(strcat(newpath,'Barclays_MSCI_Market_D.mat'));                %MSCI
        MSCI=Barclays_MSCI_Market_D;
        date_begin_msci=date_begin;
        date_end_msci=date_end;
end

% ============================================= %
% CONTRACT HORIZON
% ============================================= %
% 1= one month; 2= two months; 3= three months;
% 4= six; months; 5= one year.

switch option_ret
    case 1
        days=30;
    case 2
        days=60;
    case 3
        days=90;
    case 4
        days=180;
    case 5
        days=360;
end

Horizon=NaN*zeros(size(FX_Spot,1),2);
Horizon(:,1)=FX_Spot(:,1);
for t=2:size(FX_Spot,1)-30
    line_temp=find(FX_Spot(:,1)==FX_Spot(t,1)+days);
    if isempty(line_temp)==0
        Horizon(t,2)=line_temp-t;
    else
        line_temp=find(FX_Spot(:,1)==FX_Spot(t,1)+days+1);
        if isempty(line_temp)==0
            Horizon(t,2)=line_temp-t;
        else
            line_temp=find(FX_Spot(:,1)==FX_Spot(t,1)+days-1);
            if isempty(line_temp)==0
                Horizon(t,2)=line_temp-t;
            else
                line_temp=find(FX_Spot(:,1)==FX_Spot(t,1)+days+2);
                Horizon(t,2)=line_temp-t;
            end
        end
    end
end
    

% ============================================= %
% Import data downloaded from CRSP and Federal Reserve    
% ============================================= %

load(strcat(newpath,'FamaRF_M_updated.mat'));% First column = dates; Second column = 1-month; Third column = 3month


% ============================================= %
% SAMPLE
% ============================================= %

% ---------
% Countries
% ---------
if sample == 2
    % Get rid of the following countries:
    % Hong Kong (532), Malaysia (548), Singapore (576), South Africa (199)
    list_emerging_countries_codes=[532,548,576,199];

    for i=1:size(list_emerging_countries_codes,2)
        col=find(FX_Spot(1,:)==list_emerging_countries_codes(1,i));
        FX_Spot(2:end,col)=NaN; 
        FX_Spot_EO(2:end,col)=NaN; 
        FX_Spot_EB(2:end,col)=NaN; 
    end
end

% ---------        
% Time-window
% ---------
line_begin_spot=find(FX_Spot(:,1)==date_begin);
line_end_spot=find(FX_Spot(:,1)==date_end);
line_begin_fwd=find(FX_Fwd(:,1,1)==date_begin);
line_end_fwd=find(FX_Fwd(:,1,1)==date_end);

FX_spot_smple                        =            FX_Spot(line_begin_spot:line_end_spot,:);
FX_spot_EO_smple                     =            FX_Spot_EO(line_begin_spot:line_end_spot,:);
FX_spot_EB_smple                     =            FX_Spot_EB(line_begin_spot:line_end_spot,:);
FX_Fwd_smple                         =            FX_Fwd(line_begin_fwd:line_end_fwd,:,:);
FX_Fwd_EO_smple                      =            FX_Fwd_EO(line_begin_fwd:line_end_fwd,:,:);
FX_Fwd_EB_smple                      =            FX_Fwd_EB(line_begin_fwd:line_end_fwd,:,:);
Horizon_smple                        =            Horizon(line_begin_spot:line_end_spot,:);

line_begin_msci=find(MSCI(:,1)==date_begin_msci);
line_end_msci=find(MSCI(:,1)==date_end_msci);
MSCI_smple                           =            MSCI(line_begin_msci:line_end_msci,:);

line_begin_rf=find(FamaRF_M_updated(:,1,1)==date_begin);
line_end_rf=find(FamaRF_M_updated(:,1,1)==date_end);
FamaRF_smple                         =            FamaRF_M_updated(line_begin_rf:line_end_rf,:);


% ============================================= %
% BID-ASK SPREADS
% ============================================= %

% Spreads in spot rates
FX_spot_spread_smple                   =        zeros(size(FX_spot_EB_smple));
FX_spot_spread_smple(:,1)              =        FX_spot_EB_smple(:,1);      % Dates in the first column
FX_spot_spread_smple(:,2:end)          =        (FX_spot_EO_smple(:,2:end)./FX_spot_EB_smple(:,2:end))-1;    

% Spreads in forward rates
FX_Dsct_spread_smple                   =        zeros(size(FX_Fwd_EO_smple));
for k=1:size(FX_Fwd_smple,3)
    FX_Dsct_spread_smple(:,1,k)        =         FX_Fwd_EO_smple(:,1,k);    % Dates
    FX_Dsct_spread_smple(:,2:end,k)    =         (FX_Fwd_EO_smple(:,2:end,k)./FX_Fwd_EB_smple(:,2:end,k))-1; 
end

% ============================================= %
% EXCHANGE RATES CHANGES AND FORWARD DISCOUNTS
% ============================================= %
if option_overlapping==1
    hor=1; % For daily changes and returns
else
    hor=floor(nanmean(Horizon_smple(:,2)));
end

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Changes in spot exchange rate
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: the change in exchange rate between t-1 and t is dated t

FX_spot_chge_smple                     =        zeros(size(FX_spot_smple));
FX_spot_chge_smple(:,1)                =        FX_spot_smple(:,1);      % Dates in the first column
FX_spot_chge_smple(1+hor:end,2:end)    =        log(FX_spot_smple(1+hor:end,2:end)./FX_spot_smple(1:end-hor,2:end));    


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Excess returns taking into account bid and ask spreads
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: the excess return between t and t+1 is dated t+1

% Log excess return= log(F_mid(t)/S_mid(t+1));
FX_logxret_smple                           =        zeros(size(FX_spot_smple));
FX_logxret_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxret_smple(1+hor:end,2:end)          =        log(FX_Fwd_smple(1:end-hor,2:end,option_ret)./FX_spot_smple(1+hor:end,2:end));    

% Log excess return= log(F_ask(t)/S_bid(t+1));
FX_logxretab_smple                           =        zeros(size(FX_spot_smple));
FX_logxretab_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxretab_smple(1+hor:end,2:end)          =        log(FX_Fwd_EO_smple(1:end-hor,2:end,option_ret)./FX_spot_EB_smple(1+hor:end,2:end));    

% Log excess return= log(F_bid(t)/S_ask(t+1));
FX_logxretba_smple                           =        zeros(size(FX_spot_smple));
FX_logxretba_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxretba_smple(1+hor:end,2:end)          =        log(FX_Fwd_EB_smple(1:end-hor,2:end,option_ret)./FX_spot_EO_smple(1+hor:end,2:end));    

% Excess return= F_mid(t)/S_mid(t+1) -1;
FX_xret_smple                           =        zeros(size(FX_spot_smple));
FX_xret_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_xret_smple(1+hor:end,2:end)          =        FX_Fwd_smple(1:end-hor,2:end,option_ret)./FX_spot_smple(1+hor:end,2:end)-ones(size(FX_spot_smple(1+hor:end,2:end)));    

% Excess return= F_ask(t)/S_bid(t+1)-1;
FX_xretab_smple                           =        zeros(size(FX_spot_smple));
FX_xretab_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_xretab_smple(1+hor:end,2:end)          =        FX_Fwd_EO_smple(1:end-hor,2:end,option_ret)./FX_spot_EB_smple(1+hor:end,2:end)-ones(size(FX_spot_smple(1+hor:end,2:end)));

% Excess return= F_bid(t)/S_ask(t+1)-1;
FX_xretba_smple                           =        zeros(size(FX_spot_smple));
FX_xretba_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_xretba_smple(1+hor:end,2:end)          =        FX_Fwd_EB_smple(1:end-hor,2:end,option_ret)./FX_spot_EO_smple(1+hor:end,2:end)-ones(size(FX_spot_smple(1+hor:end,2:end)));   

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Forward Discount(t,n)=(Forward(t-1,n)/Spot(t-1))/n                  
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB 1: the interest rate differential between t-1 and t is here dated t (even if it is known at date t-1)
% NB 2: scaled by the horizon to give one-month returns;

FX_Dsct_smple=zeros(size(FX_Fwd_smple));

%1= one month; 
FX_Dsct_smple(:,1,1)=FX_Fwd_smple(:,1,1);    % Dates
FX_Dsct_smple(1,2:end,1)=NaN;                % First value
for k=1:size(FX_Fwd_smple,1)-hor
%     FX_Dsct_smple(k+1,2:end,1)      =         log((FX_Fwd_smple(k,2:end,1)./FX_spot_smple(k,2:end)));     % Values
    FX_Dsct_smple(k+hor,2:end,1)      =         log((FX_Fwd_smple(k,2:end,1)./FX_spot_smple(k,2:end)));     % Values
end
% 2= two months;
FX_Dsct_smple(:,1,2)=FX_Fwd_smple(:,1,1);    % Dates
FX_Dsct_smple(1,2:end,2)=NaN;                % First value
for k=1:size(FX_Fwd_smple,1)-1
    FX_Dsct_smple(k+1,2:end,2)      =         log((FX_Fwd_smple(k,2:end,2)./FX_spot_smple(k,2:end)))/2;     % Values
end
% 3= three months;
FX_Dsct_smple(:,1,3)=FX_Fwd_smple(:,1,1);    % Dates
FX_Dsct_smple(1,2:end,3)=NaN;                % First value
for k=1:size(FX_Fwd_smple,1)-1
    FX_Dsct_smple(k+1,2:end,3)      =          log((FX_Fwd_smple(k,2:end,3)./FX_spot_smple(k,2:end)))/3;     % Values
end
%4 = six months;
FX_Dsct_smple(:,1,4)=FX_Fwd_smple(:,1,1);    % Dates
FX_Dsct_smple(1,2:end,4)=NaN;                % First value
for k=1:size(FX_Fwd_smple,1)-1
    FX_Dsct_smple(k+1,2:end,4)      =          log((FX_Fwd_smple(k,2:end,4)./FX_spot_smple(k,2:end)))/6;     % Values
end
%5= one year;
FX_Dsct_smple(:,1,5)=FX_Fwd_smple(:,1,1);    % Dates
FX_Dsct_smple(1,2:end,5)=NaN;                % First value
for k=1:size(FX_Fwd_smple,1)-1
    FX_Dsct_smple(k+1,2:end,5)      =          log((FX_Fwd_smple(k,2:end,5)./FX_spot_smple(k,2:end)))/12;     % Values
end

% ============================================= %
% EQUITY RETURNS
% ============================================= %

%Convert one-month US risk-free rate to one-month return
% NB: rf(t) is for period t -> t+1
% NB: rf(t) is annual
for t=1:size(FamaRF_smple,1)
    FamaRF_smple(t,2)=(1+FamaRF_smple(t,2))^(1/12)-1;
end

switch msci_dollars
    
    case 1 % US investor
        % Convert to dollars
        % MSCI indices are in local currency
        % Spot exchange rates are in foreign currency per USD
        for j=2:size(MSCI_smple,2)
            MSCI_smple(:,j)=MSCI_smple(:,j)./FX_spot_smple(:,j);
        end
        MSCI_ret_smple(:,1)=MSCI_smple(:,1); % Dates
        for j=2:size(MSCI_smple,2)
            MSCI_ret_smple(2:end,j)=MSCI_smple(2:end,j)./MSCI_smple(1:end-1,j)-ones(size(MSCI_smple,1)-1,1);
        end
%         % Subtract US one-month risk-free rate
%         MSCI_ret_smple(2:end,2:end)=MSCI_ret_smple(2:end,2:end)-FamaRF_smple(1:end-1,2)*ones(1,size(MSCI_ret_smple(2:end,2:end),2));

    case 2 % Local investor 
        MSCI_ret_smple(:,1)=MSCI_smple(:,1); % Dates
        for j=2:size(MSCI_smple,2)
            MSCI_ret_smple(2:end,j)=MSCI_smple(2:end,j)./MSCI_smple(1:end-1,j)-ones(size(MSCI_smple,1)-1,1);
        end
        % Use forward discount: stock market return - foreign interest rate + US interest rate
        MSCI_ret_smple(2:end,2:end)=MSCI_ret_smple(2:end,2:end);
%         % Use forward discount: stock market return - foreign interest rate + US interest rate
%         MSCI_ret_smple(2:end,2:end)=MSCI_ret_smple(2:end,2:end)-FX_Dsct_smple(2:end,2:end,1);
%         % Subtract US one-month risk-free rate
%         MSCI_ret_smple(2:end,2:end)=MSCI_ret_smple(2:end,2:end)-FamaRF_smple(1:end-1,2)*ones(1,size(MSCI_ret_smple(2:end,2:end),2));

    case 3 % US investor hedging
        % Convert to dollars
        % MSCI indices are in local currency
        % Spot exchange rates are in foreign currency per USD
        MSCI_ret_smple(:,1)=MSCI_smple(:,1); % Dates
        for j=2:size(MSCI_smple,2)
            MSCI_ret_smple(2:end,j)=(MSCI_smple(2:end,j).*FX_spot_smple(1:end-1,j))...
                ./(MSCI_smple(1:end-1,j).*FX_Fwd_smple(1:end-1,j,1))-ones(size(MSCI_smple,1)-1,1);
        end
%         % Subtract US one-month risk-free rate
%         MSCI_ret_smple(2:end,2:end)=MSCI_ret_smple(2:end,2:end)-FamaRF_smple(1:end-1,2)*ones(1,size(MSCI_ret_smple(2:end,2:end),2));

end



% ============================================= %
% BUILD PORTFOLIOS
% ============================================= %

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Get rid of forward discount if no data on exchange rate change or no equity return
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
for h=1:size(FX_Dsct_smple,3)                                                   % For each horizon of the forward discount
    for t=1:size(FX_Dsct_smple,1)                                               % For each date
        for c=2:size(FX_Dsct_smple,2)                                           % For each country
           if  isnan(FX_spot_chge_smple(t,c))==1||isnan(MSCI_ret_smple(t,c))==1
               FX_Dsct_smple(t,c,h)=NaN;
           end         
        end
    end
end

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Sort countries according to the different forward discounts
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
FX_Dsct_smple_sorted=zeros(size(FX_Dsct_smple));
Index_sorting=zeros(size(FX_Dsct_smple));

for i=1:size(FX_Fwd_smple,3)
    FX_Dsct_smple_sorted(:,1,i)=FX_Dsct_smple(:,1,i);                                   % Dates
    Index_sorting(:,1,i)=FX_Dsct_smple(:,1,i);                                          % Dates  
   [FX_Dsct_smple_sorted(:,2:end,i),Index_sorting(:,2:end,i)]=sort(FX_Dsct_smple(:,2:end,i),2);
end



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Reorder the countries according to the sorting above
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: The interest rate differential between t and t+1 is actually known at t

% Changes in exchange rates
FX_spot_chge_sorted                                              =         zeros(size(FX_Dsct_smple));
FX_spot_spread_sorted                                            =         zeros(size(FX_Dsct_smple));
% Interest rate differentials used to compute currency excess returns
RET_Dsct_sorted                                                  =         zeros(size(FX_Dsct_smple));
RET_Dsct_spread_sorted                                           =         zeros(size(FX_Dsct_smple));
% Log currency excess returns (with and without bid/ask spread)
FX_logxret_sorted                                          =         zeros(size(FX_Dsct_smple));
FX_logxretab_sorted                                        =         zeros(size(FX_Dsct_smple));
FX_logxretba_sorted                                        =         zeros(size(FX_Dsct_smple));
% Currency excess returns (with and without bid/ask spread)
FX_xret_sorted                                          =         zeros(size(FX_Dsct_smple));
FX_xretab_sorted                                        =         zeros(size(FX_Dsct_smple));
FX_xretba_sorted                                        =         zeros(size(FX_Dsct_smple));
% Equity returns
MSCI_ret_sorted                                         =         zeros(size(FX_Dsct_smple));
% Track countries
Track_countries=zeros(size(FX_Dsct_smple));

for i=1:size(FX_Dsct_smple,3)                            % For each horizon of the forward discount used for the sorting
    FX_spot_chge_sorted(:,1,i)                                   =         FX_Dsct_smple(:,1,i);                            % Dates
    Track_countries(:,1,i)                                       =         FX_Dsct_smple(:,1,i);                            % Dates
    for t=2:size(FX_Dsct_smple,1)                        % For each date
        for c=2:size(FX_Dsct_smple,2)                    % For each country
            
            FX_spot_chge_sorted(t,c,i)                           =         FX_spot_chge_smple(t,1+Index_sorting(t,c,i));
            FX_spot_spread_sorted(t,c,i)                         =         FX_spot_spread_smple(t,1+Index_sorting(t,c,i));
            RET_Dsct_sorted(t,c,i)                               =         FX_Dsct_smple(t,1+Index_sorting(t,c,i),option_ret);
            RET_Dsct_spread_sorted(t,c,i)                        =         FX_Dsct_spread_smple(t,1+Index_sorting(t,c,i),option_ret);
            
            FX_logxret_sorted(t,c,i)                       =         FX_logxret_smple(t,1+Index_sorting(t,c,i));
            FX_logxretab_sorted(t,c,i)                     =         FX_logxretab_smple(t,1+Index_sorting(t,c,i));
            FX_logxretba_sorted(t,c,i)                     =         FX_logxretba_smple(t,1+Index_sorting(t,c,i));
            FX_xret_sorted(t,c,i)                          =         FX_xret_smple(t,1+Index_sorting(t,c,i));
            FX_xretab_sorted(t,c,i)                        =         FX_xretab_smple(t,1+Index_sorting(t,c,i));
            FX_xretba_sorted(t,c,i)                        =         FX_xretba_smple(t,1+Index_sorting(t,c,i));

            MSCI_ret_sorted(t,c,i)                         =         MSCI_ret_smple(t,1+Index_sorting(t,c,i));
            
            Track_countries(t,c,i)                                =         Index_sorting(t,c,i);
        end
    end
end
    

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Count the numbers of countries available at every date
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Count_countries=zeros(size(FX_Dsct_smple,1),size(FX_Dsct_smple,3)+1);
Count_countries(:,1)=FX_Dsct_smple(:,1,1);                                      % Copy dates
for i=1:size(FX_Dsct_smple,3)                                                   % For each horizon of the forward discount used for the sorting
    for t=1:size(FX_Dsct_smple,1)                                               % For each date
        for c=2:size(FX_Dsct_smple,2)                                           % For each country
            Count_countries(t,1+i)                              =          Count_countries(t,1+i)+(not(isnan(FX_Dsct_smple_sorted(t,c,i))));
        end
    end
end


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Group the countries into portfolios
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% The changes in exchange rates are equally weighted

portfolios_Spotchg_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_Dsct_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_logxret_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_logxretba_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_xret_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_xretba_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
portfolios_msci_group=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));
count_group=zeros(size(FX_Dsct_smple,1),number_portfolios,size(FX_Dsct_smple,3));
Track_portfolios=zeros(size(FX_Dsct_smple));
trades=zeros(size(FX_Dsct_smple,1),1+number_portfolios,size(FX_Dsct_smple,3));

for h=1:size(FX_Dsct_smple,3)                                  % For each horizon of the forward discount used for the sorting
    portfolios_Spotchg_group(:,1,h)=FX_spot_chge_smple(:,1);    % Copy dates
    portfolios_Dsct_group(:,1,h)=FX_spot_chge_smple(:,1);       % Copy dates
    portfolios_logxret_group(:,1,h)=FX_spot_chge_smple(:,1);    % Copy dates
    portfolios_logxretba_group(:,1,h)=FX_spot_chge_smple(:,1);  % Copy dates
    portfolios_xret_group(:,1,h)=FX_spot_chge_smple(:,1);       % Copy dates
    portfolios_xretba_group(:,1,h)=FX_spot_chge_smple(:,1);     % Copy dates
    portfolios_msci_group(:,1,h)=FX_spot_chge_smple(:,1);       % Copy dates
    Count_Returns=Count_countries(:,1+h);
    trades(:,1,h)=FX_spot_chge_smple(:,1);      % Copy dates
    
    % First date row = NaN
    portfolios_Spotchg_group(1,2:end,h)=NaN;
    portfolios_Dsct_group(1,2:end,h)=NaN;
    portfolios_logxret_group(1,2:end,h)=NaN;
    portfolios_logxretba_group(1,2:end,h)=NaN;
    portfolios_xret_group(1,2:end,h)=NaN;
    portfolios_xretba_group(1,2:end,h)=NaN;
    portfolios_msci_group(1,2:end,h)=NaN;
    count_group(1,2:end,h)=NaN;
    Track_portfolios(1,2:end,h)=NaN;
    
    for t=2:size(FX_Dsct_smple,1)                   % For each date
        
        for n=1:number_portfolios                  % For each portfolio
            
            if n==number_portfolios                % Special case: last portfolio
                for m=1+(n-1)*floor(Count_Returns(t)*(1/number_portfolios)):n*floor(Count_Returns(t)*(1/number_portfolios))+rem(Count_Returns(t),number_portfolios)                   
                    if m<=Count_Returns(t)
                        % Compute the average change in FX (equal weights)
                        portfolios_logxret_group(t,1+n,h)                    =   portfolios_logxret_group(t,1+n,h)+FX_logxret_sorted(t,1+m,h);
                        portfolios_xret_group(t,1+n,h)                       =   portfolios_xret_group(t,1+n,h)+FX_xret_sorted(t,1+m,h);
                        portfolios_Spotchg_group(t,1+n,h)                    =   portfolios_Spotchg_group(t,1+n,h)+FX_spot_chge_sorted(t,1+m,h);
                        portfolios_Dsct_group(t,1+n,h)                       =   portfolios_Dsct_group(t,1+n,h)+RET_Dsct_sorted(t,1+m,h); 
                        if n<2
                            portfolios_logxretba_group(t,1+n,h)              =   portfolios_logxretba_group(t,1+n,h)+FX_logxretab_sorted(t,1+m,h);                  
                            portfolios_xretba_group(t,1+n,h)                 =   portfolios_xretba_group(t,1+n,h)+FX_xretab_sorted(t,1+m,h);                  
                        else
                            portfolios_logxretba_group(t,1+n,h)              =   portfolios_logxretba_group(t,1+n,h)+FX_logxretba_sorted(t,1+m,h);
                            portfolios_xretba_group(t,1+n,h)                 =   portfolios_xretba_group(t,1+n,h)+FX_xretba_sorted(t,1+m,h);
                        end
                        count_group(t,n,h)                                   =   count_group(t,n,h)+1;
                        Track_portfolios(t,Track_countries(t,1+m,h),h)       =   n;
                        
                        portfolios_msci_group(t,1+n,h)                       =   portfolios_msci_group(t,1+n,h)+MSCI_ret_sorted(t,1+m,h);
                                                
                        % Test if the country changes portfolio
                        if Track_portfolios(t-1,Track_countries(t,1+m,h),h) ~=n
                            trades(t,1+n,h)=trades(t,1+n,h)+1;
                       end
                        
                    end
                end
            else                                    % All portfolios except the last one
                for m=1+(n-1)*floor(Count_Returns(t)*(1/number_portfolios)):n*floor(Count_Returns(t)*(1/number_portfolios))
                    if m<=Count_Returns(t)
                        % Compute the average change in FX (equal weights)
                        % Compute the average change in FX (equal weights)
                        portfolios_logxret_group(t,1+n,h)                    =   portfolios_logxret_group(t,1+n,h)+FX_logxret_sorted(t,1+m,h);
                        portfolios_xret_group(t,1+n,h)                       =   portfolios_xret_group(t,1+n,h)+FX_xret_sorted(t,1+m,h);
                        portfolios_Spotchg_group(t,1+n,h)                    =   portfolios_Spotchg_group(t,1+n,h)+FX_spot_chge_sorted(t,1+m,h);
                        portfolios_Dsct_group(t,1+n,h)                       =   portfolios_Dsct_group(t,1+n,h)+RET_Dsct_sorted(t,1+m,h); 
                        if n<2
                            portfolios_logxretba_group(t,1+n,h)              =   portfolios_logxretba_group(t,1+n,h)+FX_logxretab_sorted(t,1+m,h);                  
                            portfolios_xretba_group(t,1+n,h)                 =   portfolios_xretba_group(t,1+n,h)+FX_xretab_sorted(t,1+m,h);                  
                        else
                            portfolios_logxretba_group(t,1+n,h)              =   portfolios_logxretba_group(t,1+n,h)+FX_logxretba_sorted(t,1+m,h);
                            portfolios_xretba_group(t,1+n,h)                 =   portfolios_xretba_group(t,1+n,h)+FX_xretba_sorted(t,1+m,h);
                        end
                        count_group(t,n,h)                                     =   count_group(t,n,h)+1;
                        Track_portfolios(t,Track_countries(t,1+m,h),h)         =   n;
                         
                        portfolios_msci_group(t,1+n,h)                       =   portfolios_msci_group(t,1+n,h)+MSCI_ret_sorted(t,1+m,h);

                        % Test if the country changes portfolio
                        if Track_portfolios(t-1,Track_countries(t,1+m,h),h) ~=n
                            trades(t,1+n,h)=trades(t,1+n,h)+1;
                        end
                        
                    end
                end
            end
            
            if count_group(t,n,h)>0
                portfolios_Spotchg_group(t,1+n,h)                      =   portfolios_Spotchg_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_Dsct_group(t,1+n,h)                         =   portfolios_Dsct_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_logxret_group(t,1+n,h)                      =   portfolios_logxret_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_xret_group(t,1+n,h)                         =   portfolios_xret_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_logxretba_group(t,1+n,h)                    =   portfolios_logxretba_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_xretba_group(t,1+n,h)                       =   portfolios_xretba_group(t,1+n,h)/count_group(t,n,h);  
                portfolios_msci_group(t,1+n,h)                         =   portfolios_msci_group(t,1+n,h)/count_group(t,n,h);  
            else
                portfolios_Spotchg_group(t,1+n,h)                      =   NaN;
                portfolios_Dsct_group(t,1+n,h)                         =   NaN;
                portfolios_logxret_group(t,1+n,h)                      =   NaN;
                portfolios_xret_group(t,1+n,h)                         =   NaN;
                portfolios_logxretba_group(t,1+n,h)                    =   NaN;
                portfolios_xretba_group(t,1+n,h)                       =   NaN;
                portfolios_msci_group(t,1+n,h)                         =   NaN;  
            end
        end
        
        
    end
    
end

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Trade frequency
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Number of trades depending on the forward contract used to sort countries
trades_allportfolios=zeros(size(trades,1),size(trades,3));
trades_allportfolios(:,1)=trades(:,1); % Dates
for k=1:size(trades,3)
    trades_allportfolios(:,1+k)=sum(trades(:,2:end,k),2);
end
disp('');
disp('Number of trades for portfolios sorted on 1-m, 2-m, 3-m, 6-m and 12-m forward rates:');
disp(int2str(sum(trades_allportfolios(:,2:end))));
disp('Idem, per month:');
disp(num2str(sum(trades_allportfolios(:,2:end))/size(trades,1),'%10.2f'));


disp(' ');
disp('Spread (annualized, in %) between the last and first portfolio');
disp('depending on the forward contract used to sort countries');
spread_lastfirst=zeros(size(portfolios_Spotchg_group,1),size(portfolios_Spotchg_group,3));
for k=1:size(portfolios_Spotchg_group,3)
 spread_lastfirst(:,k)=(-portfolios_Spotchg_group(:,end,k)+portfolios_Dsct_group(:,end,k))-(-portfolios_Spotchg_group(:,2,k)+portfolios_Dsct_group(:,2,k));
end
disp(num2str(nanmean(spread_lastfirst)*100*12,'%10.2f'));
disp('Same spread, but using bid/ask quotes to compute excess returns');
disp('(worst case scenario)');
for k=1:size(portfolios_Spotchg_group,3)
 spread_lastfirst(:,k)=portfolios_logxretba_group(:,end,k)-portfolios_logxretba_group(:,2,k);
end
disp(num2str(nanmean(spread_lastfirst)*100*12,'%10.2f'));
disp('Sharpe ratio in this case');
disp(num2str(nanmean(spread_lastfirst)*100*12/(nanstd(spread_lastfirst)*100*sqrt(12)),'%10.2f'));


disp(' ');
bidaskspreadfwd=zeros(size(FX_Dsct_spread_smple,3),size(FX_Dsct_spread_smple,2)-1);
for k=1:size(portfolios_Spotchg_group,3)
    bidaskspreadfwd(k,:)=nanmean(FX_Dsct_spread_smple(:,2:end,k));
end
disp('Mean Bid/Ask spread of forward contracts (in %, 19 currencies,  1-m, 2-m, 3-m, 6-m and 12-m)');
disp(num2str(100*nanmean(bidaskspreadfwd,2)','%10.2f'));
disp('Std Bid/Ask spread of forward contracts (in %, 19 currencies,  1-m, 2-m, 3-m, 6-m and 12-m)');
disp(num2str(100*nanstd(bidaskspreadfwd,0,2)','%10.2f'));



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Compute Excess Returns
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Pick horizon of the forward rate used to sort currencies
portfolios_Spotchg_with_dates       =  portfolios_Spotchg_group(:,:,hor_fwd_rate);
portfolios_Dsct_with_dates          =  portfolios_Dsct_group(:,:,hor_fwd_rate);
portfolios_logxretba_with_dates     =  portfolios_logxretba_group(:,:,hor_fwd_rate);
portfolios_logxret_with_dates       =  portfolios_logxret_group(:,:,hor_fwd_rate);
portfolios_xretba_with_dates        =  portfolios_xretba_group(:,:,hor_fwd_rate);
portfolios_xret_with_dates          =  portfolios_xret_group(:,:,hor_fwd_rate);
portfolios_msci_with_dates          =  portfolios_msci_group(:,:,hor_fwd_rate);

% Compute excess returns using FX changes and interest rate differentials
portfolios_FXXR_with_dates          =  zeros(size(portfolios_Spotchg_with_dates));
portfolios_FXXR_with_dates(:,1)     =  portfolios_Spotchg_with_dates(:,1); % dates
portfolios_FXXR_with_dates(:,2:end) = -portfolios_Spotchg_with_dates(:,2:end)+portfolios_Dsct_with_dates(:,2:end);


% ============================================= %
% REPORT SUMMARY STATISTICS (annualized = x12)
% ============================================= %

disp(' ');
disp('Equity excess returns (annualized, in %) on each portfolio');
disp('depending on the forward contract used to sort countries');
for k=1:size(portfolios_msci_group,3)
  disp(num2str(nanmean(portfolios_msci_group(:,2:end,k))*100*12,'%10.2f'));
end


disp(' ');
disp('Excess returns (annualized, in %, using ask/bid quotes) on each portfolio');
disp('depending on the forward contract used to sort countries');
for k=1:size(portfolios_xretba_group,3)
  disp(num2str(nanmean(portfolios_xretba_group(:,2:end,k))*100*12,'%10.2f'));
end

disp(' ');
disp('Log excess returns (annualized, in %, using ask/bid quotes) on each portfolio');
disp('depending on the forward contract used to sort countries');
for k=1:size(portfolios_logxretba_group,3)
  disp(num2str(nanmean(portfolios_logxretba_group(:,2:end,k))*100*12,'%10.2f'));
end

disp(' ');
disp('Excess returns (annualized, in %, without ask/bid quotes) on each portfolio');
disp('depending on the forward contract used to sort countries');
for k=1:size(portfolios_xret_group,3)
  disp(num2str(nanmean(portfolios_xret_group(:,2:end,k))*100*12,'%10.2f'));
end

disp(' ');
disp('Excess returns (annualized, in %, without ask/bid quotes, using FX changes and interest rate differentials) on each portfolio');
disp('depending on the forward contract used to sort countries');
for k=1:size(portfolios_Dsct_group,3)
  disp(num2str(nanmean((-portfolios_Spotchg_group(:,2:end,k)+portfolios_Dsct_group(:,2:end,k)))*100*12,'%10.2f'));
end



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Annualize 
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
T=size(portfolios_FXXR_with_dates,1);
TT = floor(T/12);
portfolios_FXXR_with_dates_ann          = zeros(TT,size(portfolios_FXXR_with_dates,2));
portfolios_logxretba_with_dates_ann     = zeros(TT,size(portfolios_logxretba_with_dates,2));
portfolios_logxret_with_dates_ann       = zeros(TT,size(portfolios_logxret_with_dates,2));
portfolios_xretba_with_dates_ann        = zeros(TT,size(portfolios_xretba_with_dates,2));
portfolios_xret_with_dates_ann          = zeros(TT,size(portfolios_xret_with_dates,2));
portfolios_Dsct_with_dates_ann          = zeros(TT,size(portfolios_Dsct_with_dates,2));
portfolios_Spotchg_with_dates_ann       = zeros(TT,size(portfolios_Spotchg_with_dates,2));
portfolios_msci_with_dates_ann          = zeros(TT,size(portfolios_msci_with_dates,2));
for tt = 1:TT
    
    aa = portfolios_FXXR_with_dates;
    for j=1:12
        portfolios_FXXR_with_dates_ann(tt,2:end) = portfolios_FXXR_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_FXXR_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);
    
    aa = portfolios_Dsct_with_dates;
    for j=1:12
        portfolios_Dsct_with_dates_ann(tt,2:end) = portfolios_Dsct_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_Dsct_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);
    
    aa = portfolios_Spotchg_with_dates;
    for j=1:12
        portfolios_Spotchg_with_dates_ann(tt,2:end) = portfolios_Spotchg_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_Spotchg_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    aa = portfolios_logxretba_with_dates;
    for j=1:12
        portfolios_logxretba_with_dates_ann(tt,2:end) = portfolios_logxretba_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_logxretba_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    aa = portfolios_logxret_with_dates;
    for j=1:12
        portfolios_logxret_with_dates_ann(tt,2:end) = portfolios_logxret_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_logxret_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    aa = portfolios_xretba_with_dates;
    for j=1:12
        portfolios_xretba_with_dates_ann(tt,2:end) = portfolios_xretba_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_xretba_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    aa = portfolios_xret_with_dates;
    for j=1:12
        portfolios_xret_with_dates_ann(tt,2:end) = portfolios_xret_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_xret_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    aa = portfolios_msci_with_dates;
    for j=1:12
        portfolios_msci_with_dates_ann(tt,2:end) = portfolios_msci_with_dates_ann(tt,2:end)+aa(j+12*(tt-1),2:end);
    end
    portfolios_msci_with_dates_ann(tt,1)=aa(12+12*(tt-1),1);

    
end


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Summary Statistics on Annual Series
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Equity Returns
meanNp_MsciRet=nanmean(portfolios_msci_with_dates_ann(:,2:end));           % Time-Series average 
stdNp_MsciRet=nanstd(portfolios_msci_with_dates_ann(:,2:end));             % Time-Series dispersion 
figure('Name','Equity Returns');
    subplot(3,1,1);bar(meanNp_MsciRet,'b');title('Mean Equity Returns (Annualized)')
    subplot(3,1,2);bar(stdNp_MsciRet,'r');title('Stdev of Equity Returns (Annualized)')
    subplot(3,1,3);bar(meanNp_MsciRet./stdNp_MsciRet,'g');title('Mean/Stdev (Annualized)')

    
% Changes in exchange rates
meanNp_Spotchg=nanmean(portfolios_Spotchg_with_dates_ann(:,2:end));           % Time-Series average 
stdNp_Spotchg=nanstd(portfolios_Spotchg_with_dates_ann(:,2:end));             % Time-Series dispersion 
figure('Name','Changes in Exchange Rates');
    subplot(3,1,1);bar(meanNp_Spotchg,'b');title('Mean Changes in Exchange Rates (Annualized)')
    subplot(3,1,2);bar(stdNp_Spotchg,'r');title('Stdev of Changes in Exchange Rates (Annualized)')
    subplot(3,1,3);bar(meanNp_Spotchg./stdNp_Spotchg,'g');title('Mean/Stdev (Annualized)')

% Interest rates differentials
meanNp_Dsct=nanmean(portfolios_Dsct_with_dates_ann(:,2:end));           % Time-Series average 
stdNp_Dsct=nanstd(portfolios_Dsct_with_dates_ann(:,2:end));             % Time-Series dispersion 
figure('Name','Interest rates differentials');
    subplot(3,1,1);bar(meanNp_Dsct,'b');title('Mean Interest rates differentials (Annualized)')
    subplot(3,1,2);bar(stdNp_Dsct,'r');title('Stdev of Interest rates differentials (Annualized)')
    subplot(3,1,3);bar(meanNp_Dsct./stdNp_Dsct,'g');title('Mean/Stdev (Annualized)')

% Excess returns
meanNp_ret=nanmean(portfolios_xret_with_dates_ann(:,2:end));           % Time-Series average excess returns
stdNp_ret=nanstd(portfolios_xret_with_dates_ann(:,2:end));             % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns');
    subplot(3,1,1);bar(meanNp_ret,'b');title('Mean Excess Returns (Annualized)')
    subplot(3,1,2);bar(stdNp_ret,'r');title('Stdev of Excess Returns (Annualized)')
    subplot(3,1,3);bar(meanNp_ret./stdNp_ret,'g');title('Sharpe Ratio (Annualized)')

% Excess returns (with Bid/Ask Spreads)
meanNp_retba=nanmean(portfolios_xretba_with_dates_ann(:,2:end));           % Time-Series average excess returns
stdNp_retba=nanstd(portfolios_xretba_with_dates_ann(:,2:end));             % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns (with Bid/Ask Spreads)');
    subplot(3,1,1);bar(meanNp_retba,'b');title('Mean Excess Returns (Annualized)')
    subplot(3,1,2);bar(stdNp_retba,'r');title('Stdev of Excess Returns (Annualized)')
    subplot(3,1,3);bar(meanNp_retba./stdNp_retba,'g');title('Sharpe Ratio (Annualized)')

% Tables for paper (Annual series)
disp(' ');
disp('Tables for paper (Annual series, all available data)');
Results_all=[100*meanNp_Spotchg;100*stdNp_Spotchg;100*meanNp_Dsct;100*stdNp_Dsct;100*meanNp_ret;100*stdNp_ret;...
    meanNp_ret./stdNp_ret;...
    100*meanNp_retba;100*stdNp_retba;meanNp_retba./stdNp_retba];
latex(Results_all,'%6.2f');
disp(' ');

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Select Time-Windows:
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
k=find(portfolios_FXXR_with_dates(:,1)==estimation_date_begin);
n=find(portfolios_FXXR_with_dates(:,1)==estimation_date_end);

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Summary Statistics on Monthly Series
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Numbermonths  =  12;

% Equity Returns
meanNp_MsciRet=nanmean(portfolios_msci_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average 
stdNp_MsciRet=nanstd(portfolios_msci_with_dates(k:n,2:end))*sqrt(Numbermonths);             % Time-Series dispersion 
figure('Name','Equity Returns');
    subplot(3,1,1);bar(meanNp_MsciRet,'b');title('Mean Equity Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_MsciRet,'r');title('Stdev of Equity Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_MsciRet./stdNp_MsciRet,'g');title('Mean/Stdev (Annualized)')


% Changes in exchange rates
meanNp_Spotchg=nanmean(portfolios_Spotchg_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average 
stdNp_Spotchg=nanstd(portfolios_Spotchg_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion 
figure('Name','Changes in Exchange Rates');
    subplot(3,1,1);bar(meanNp_Spotchg,'b');title('Mean Changes in Exchange Rates (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_Spotchg,'r');title('Stdev of Changes in Exchange Rates (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_Spotchg./stdNp_Spotchg,'g');title('Mean/Stdev (Annualized)')

% Interest rates differentials
meanNp_Dsct=nanmean(portfolios_Dsct_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average 
stdNp_Dsct=nanstd(portfolios_Dsct_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion 
figure('Name','Interest rates differentials');
    subplot(3,1,1);bar(meanNp_Dsct,'b');title('Mean Interest rates differentials (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_Dsct,'r');title('Stdev of Interest rates differentials (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_Dsct./stdNp_Dsct,'g');title('Mean/Stdev (Annualized)')

% Excess returns
meanNp_ret=nanmean(portfolios_xret_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average excess returns
stdNp_ret=nanstd(portfolios_xret_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns');
    subplot(3,1,1);bar(meanNp_ret,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_ret,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_ret./stdNp_ret,'g');title('Sharpe Ratio (Annualized)')

% Excess returns (with Bid/Ask Spreads)
meanNp_retba=nanmean(portfolios_xretba_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average excess returns
stdNp_retba=nanstd(portfolios_xretba_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns (with Bid/Ask Spreads)');
    subplot(3,1,1);bar(meanNp_retba,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_retba,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_retba./stdNp_retba,'g');title('Sharpe Ratio (Annualized)')

% Time-Series
figure('Name','Time-Series of Currency Excess Returns by Portfolios');
 plot(portfolios_xretba_with_dates(k:n,1),portfolios_xretba_with_dates(k:n,2:end));
 legend('Portfolio 1','Portfolio 2','Portfolio 3','Portfolio 4','Portfolio 5');
 datetick;
 axis tight;

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Long-Short Strategies
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Excess returns
lgsh=NaN*zeros(size(portfolios_xret_with_dates(k:n,1),1),size(portfolios_xret_with_dates,2)-2);
for j=1:size(portfolios_xret_with_dates,2)-2
    lgsh(:,j)=portfolios_xret_with_dates(k:n,2+j)-portfolios_xret_with_dates(k:n,2);
end

meanNp_ret_lgsh=nanmean(lgsh)*Numbermonths;                 % Time-Series average excess returns
stdNp_ret_lgsh=nanstd(lgsh)*sqrt(Numbermonths);             % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns: Long-Short Strategies');
    subplot(3,1,1);bar(meanNp_ret_lgsh,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_ret_lgsh,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_ret_lgsh./stdNp_ret_lgsh,'g');title('Sharpe Ratio (Annualized)')

% Excess returns (with Bid/Ask Spreads)
lgsh=NaN*zeros(size(portfolios_xretba_with_dates(k:n,1),1),size(portfolios_xretba_with_dates,2)-2);
for j=1:size(portfolios_xretba_with_dates,2)-2
    lgsh(:,j)=portfolios_xretba_with_dates(k:n,2+j)-portfolios_xretba_with_dates(k:n,2);
end

meanNp_retba_lgsh=nanmean(lgsh)*Numbermonths;                   % Time-Series average excess returns
stdNp_retba_lgsh=nanstd(lgsh)*sqrt(Numbermonths);               % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns (with Bid/Ask Spreads): Long-Short Strategies');
    subplot(3,1,1);bar(meanNp_retba_lgsh,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_retba_lgsh,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_retba_lgsh./stdNp_retba_lgsh,'g');title('Sharpe Ratio (Annualized)')

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Tables for paper (Quarterly series)
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
disp(' ');
disp('Tables for paper (Quarterly series, annualized, estimation period)');
Results_all=[100*meanNp_Spotchg;100*stdNp_Spotchg;100*meanNp_Dsct;100*stdNp_Dsct;100*meanNp_ret;100*stdNp_ret;...
    meanNp_ret./stdNp_ret;...
    100*meanNp_retba;100*stdNp_retba;meanNp_retba./stdNp_retba];
latex(Results_all,'%6.2f');
disp(' ');
Results_all=[Results_all;9999 100*meanNp_ret_lgsh;9999 100*stdNp_ret_lgsh;9999 meanNp_ret_lgsh./stdNp_ret_lgsh;...
    9999 100*meanNp_retba_lgsh; 9999 100*stdNp_retba_lgsh; 9999 meanNp_retba_lgsh./stdNp_retba_lgsh];
latex(Results_all,'%6.2f');
disp(' ');


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Tables for paper Equity (Quarterly series)
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
disp(' ');
disp('Tables for paper Equity (Quarterly series, annualized, estimation period)');
Results_all=[100*meanNp_MsciRet;100*stdNp_MsciRet; meanNp_MsciRet./stdNp_MsciRet];
latex(Results_all,'%6.2f');
disp(' ');

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Monthly volatility series
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Transform into end-of-the month series

NM                    = months(portfolios_msci_with_dates(1,1),portfolios_msci_with_dates(end,1));
portfolios_vol_dM     = NaN*zeros(NM,size(portfolios_Spotchg_with_dates,2)+1);
% Data
k=2; % Start at 2 because the daily sample starts ends of january
for t=2:size(portfolios_msci_with_dates,1)-1
    if month(portfolios_msci_with_dates(t,1))~=month(portfolios_msci_with_dates(t+1,1)) % find end-of-month
        [N, S]=weekday(portfolios_msci_with_dates(t,1));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        portfolios_vol_dM(k,1)=portfolios_msci_with_dates(t+j,1);
        k=k+1;
    end
end

% Build monthly spot change volatility
for t=2:size(portfolios_vol_dM,1)
    rows_temp=find(month(portfolios_msci_with_dates(:,1))==month(portfolios_vol_dM(t,1)) & ...
        year(portfolios_msci_with_dates(:,1))==year(portfolios_vol_dM(t,1)));
    % For each portfolio
    for k=2:size(portfolios_msci_with_dates,2)
        portfolios_vol_dM(t,k)=nanstd(portfolios_msci_with_dates(rows_temp,k));
    end
    % For HML
    portfolios_vol_dM(t,end)=nanstd(portfolios_msci_with_dates(rows_temp,end)-portfolios_msci_with_dates(rows_temp,2));
end

% Check
disp(' ');
disp('MSCI changes volatility (in %): ');
disp(100*nanmean(portfolios_vol_dM(:,2:end)));

% Average volatility (no portfolio building exercise here)
average_vol_dM            = NaN*zeros(size(portfolios_vol_dM,1),2);
average_vol_dM(:,1)       = portfolios_vol_dM(:,1);
% Build monthly average change volatility
for t=2:size(average_vol_dM,1)
    rows_temp=find(month(MSCI_ret_smple(:,1))==month(average_vol_dM(t,1)) & ...
        year(MSCI_ret_smple(:,1))==year(average_vol_dM(t,1)));
    average_vol_dM(t,2)=nanmean(nanstd(MSCI_ret_smple(rows_temp,2:end)),2);
end

figure;
plot(average_vol_dM(:,1),average_vol_dM(:,2),'r');hold on;
plot(portfolios_vol_dM(:,1),mean(portfolios_vol_dM(:,2:end-1),2),'b');hold off;
datetick;
legend('No portfolio','Average across portfolios');
title('Volatility Measures');

% ============================================= %
% SAVE PORTFOLIOS
% ============================================= %
if option_overlapping==1
    switch sample
        case 1 % Barclays and Reuters
            switch msci_dollars
                case 1
                    % 1 = excess returns for a US investor (no hedging of currency risk)
                    portfolios_EXRUSD_MSCI_D      = portfolios_msci_with_dates;
                    save('portfolios_EXRUSD_MSCI_D.mat','portfolios_EXRUSD_MSCI_D');
                    portfolios_RUSDvol_MSCI_dM      = portfolios_vol_dM;
                    save(strcat(newpath,'portfolios_RUSDvol_MSCI_dM.mat'),'portfolios_RUSDvol_MSCI_dM');
                    average_RUSDvol_MSCI_dM         = average_vol_dM;
                    save(strcat(newpath,'average_RUSDvol_MSCI_dM.mat'),'average_RUSDvol_MSCI_dM');
                case 2
                    % keep in local currency (excess returns for a foreign investor)
                    portfolios_EXRloc_MSCI_D      = portfolios_msci_with_dates;
                    save('portfolios_EXRloc_MSCI_D.mat','portfolios_EXRloc_MSCI_D');
                    portfolios_Rlocvol_MSCI_dM    = portfolios_vol_dM;
                    save(strcat(newpath,'portfolios_Rlocvol_MSCI_dM.mat'),'portfolios_Rlocvol_MSCI_dM');
                    average_Rlocvol_MSCI_dM      = average_vol_dM;
                    save(strcat(newpath,'average_Rlocvol_MSCI_dM.mat'),'average_Rlocvol_MSCI_dM');
            end
        case 2 % Barclays
            switch msci_dollars
                case 1
                    % 1 = excess returns for a US investor (no hedging of currency risk)
                    portfolios_EXRUSD_MSCI_Barclays_D      = portfolios_msci_with_dates;
                    save('portfolios_EXRUSD_MSCI_Barclays_D.mat','portfolios_EXRUSD_MSCI_Barclays_D');
                    portfolios_RUSDvol_MSCI_Barclays_dM      = portfolios_vol_dM;
                    save(strcat(newpath,'portfolios_RUSDvol_MSCI_Barclays_dM.mat'),'portfolios_RUSDvol_MSCI_Barclays_dM');
                    average_RUSDvol_MSCI_Barclays_dM      = average_vol_dM;
                    save(strcat(newpath,'average_RUSDvol_MSCI_Barclays_dM.mat'),'average_RUSDvol_MSCI_Barclays_dM');
                case 2
                    % keep in local currency (excess returns for a foreign investor)
                    portfolios_EXRloc_MSCI_Barclays_D      = portfolios_msci_with_dates;
                    save('portfolios_EXRloc_MSCI_Barclays_D.mat','portfolios_EXRloc_MSCI_Barclays_D');
                    portfolios_Rlocvol_MSCI_Barclays_dM      = portfolios_vol_dM;
                    save(strcat(newpath,'portfolios_Rlocvol_MSCI_Barclays_dM.mat'),'portfolios_Rlocvol_MSCI_Barclays_dM');
                    average_Rlocvol_MSCI_Barclays_dM      = average_vol_dM;
                    save(strcat(newpath,'average_Rlocvol_MSCI_Barclays_dM.mat'),'average_Rlocvol_MSCI_Barclays_dM');
            end
    end
end


    