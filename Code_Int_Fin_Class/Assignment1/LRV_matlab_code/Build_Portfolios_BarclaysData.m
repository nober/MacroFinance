% ============================================= %
% Description
% ============================================= %

% Program : 
% 1 ) Import Barclays monthly data on spot and forward exchange rates, select subsample
% 2 ) Build portfolios of monthly currency excess returns on the basis of the forward discount


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
newpath = '/Users/whn2105/Documents/MacroFinance/Data_Int_Fin_Class/rawdata/fx/';

% ============================================= %
% Options
% ============================================= %
number_portfolios        = 5;   % Number of portfolios
                                
date_begin               = datenum('1/31/1983');    % Start building portfolios
load(strcat(newpath,'BR_Spot_dM.mat'));             % FX_Spot
date_end                 = BR_Spot_M(end-1,1);      % Take the end of the previous month as end-date
estimation_date_begin    = datenum('11/30/1983');   % Start estimation
estimation_date_end      = date_end;                % End estimation


% ============================================= %
% Import data downloaded from Datastream (Barclays)    
% ============================================= %

% Import data downloaded from Datastream (Barclays, original frequency = daily)    
% NB: in units of foreign currency per USD
% NB: timing = end of the month

load(strcat(newpath,'Barclays_Fwd_dM.mat'));                        %FX_Fwd
load(strcat(newpath,'Barclays_Spot_dM.mat'));                       %FX_Spot
load(strcat(newpath,'Barclays_Fwd_EB_dM.mat'));                     %FX_Fwd Bid
load(strcat(newpath,'Barclays_Spot_EB_dM.mat'));                    %FX_Spot Bid
load(strcat(newpath,'Barclays_Fwd_EO_dM.mat'));                     %FX_Fwd Ask
load(strcat(newpath,'Barclays_Spot_EO_dM.mat'));                    %FX_Spot Ask
load(strcat(newpath,'Barclays_Countries.mat'));                     %List_names
FX_Spot    =    Barclays_Spot_M;
FX_Spot_EO =    Barclays_Spot_EO_M;
FX_Spot_EB =    Barclays_Spot_EB_M;
FX_Fwd     =    Barclays_Fwd_M;
FX_Fwd_EO  =    Barclays_Fwd_EO_M;
FX_Fwd_EB  =    Barclays_Fwd_EB_M;



% ============================================= %
% SAMPLE
% ============================================= %

% ---------
% Countries
% ---------
% Get rid of the following countries:
% Hong Kong (532), Malaysia (548), Singapore (576), South Africa (199)
list_emerging_countries_codes=[532,548,576,199];

for i=1:size(list_emerging_countries_codes,2)
    col=find(FX_Spot(1,:)==list_emerging_countries_codes(1,i));
    FX_Spot(2:end,col)    = NaN; 
    FX_Spot_EO(2:end,col) = NaN; 
    FX_Spot_EB(2:end,col) = NaN; 
end

% ---------
% Time-window
% ---------

line_begin_spot     =   find(FX_Spot(:,1)==date_begin);
line_end_spot       =   find(FX_Spot(:,1)==date_end);
line_begin_fwd      =   find(FX_Fwd(:,1,1)==date_begin);
line_end_fwd        =   find(FX_Fwd(:,1,1)==date_end);

FX_spot_smple       =   FX_Spot(line_begin_spot:line_end_spot,:);
FX_spot_EO_smple    =   FX_Spot_EO(line_begin_spot:line_end_spot,:);
FX_spot_EB_smple    =   FX_Spot_EB(line_begin_spot:line_end_spot,:);
FX_Fwd_smple        =   FX_Fwd(line_begin_fwd:line_end_fwd,:);
FX_Fwd_EO_smple     =   FX_Fwd_EO(line_begin_fwd:line_end_fwd,:);
FX_Fwd_EB_smple     =   FX_Fwd_EB(line_begin_fwd:line_end_fwd,:);


% ============================================= %
% BID-ASK SPREADS
% ============================================= %

% Spreads in spot rates
FX_spot_spread_smple                   =        zeros(size(FX_spot_EB_smple));
FX_spot_spread_smple(:,1)              =        FX_spot_EB_smple(:,1);      % Dates in the first column
FX_spot_spread_smple(:,2:end)          =        (FX_spot_EO_smple(:,2:end)./FX_spot_EB_smple(:,2:end))-1;    

% Spreads in forward rates
FX_Dsct_spread_smple                   =        zeros(size(FX_Fwd_EO_smple));
FX_Dsct_spread_smple(:,1)              =         FX_Fwd_EO_smple(:,1);    % Dates
FX_Dsct_spread_smple(:,2:end)          =         (FX_Fwd_EO_smple(:,2:end)./FX_Fwd_EB_smple(:,2:end))-1; 



% ============================================= %
% EXCHANGE RATES CHANGES AND FORWARD DISCOUNTS
% ============================================= %

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Changes in spot exchange rate
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: the change in exchange rate between t-1 and t is dated t

FX_spot_chge_smple                     =        zeros(size(FX_spot_smple));
FX_spot_chge_smple(:,1)                =        FX_spot_smple(:,1);      % Dates in the first column
FX_spot_chge_smple(2:end,2:end)        =        log(FX_spot_smple(2:end,2:end)./FX_spot_smple(1:end-1,2:end));    


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Excess returns taking into account bid and ask spreads
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: the excess return between t and t+1 is dated t+1

% Log excess return= log(F_mid(t)/S_mid(t+1));
FX_logxret_smple                           =        zeros(size(FX_spot_smple));
FX_logxret_smple(:,1)                      =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxret_smple(2:end,2:end)              =        log(FX_Fwd_smple(1:end-1,2:end)./FX_spot_smple(2:end,2:end));    

% Log excess return= log(F_ask(t)/S_bid(t+1));
FX_logxretab_smple                         =        zeros(size(FX_spot_smple));
FX_logxretab_smple(:,1)                    =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxretab_smple(2:end,2:end)            =        log(FX_Fwd_EO_smple(1:end-1,2:end)./FX_spot_EB_smple(2:end,2:end));    

% Log excess return= log(F_bid(t)/S_ask(t+1));
FX_logxretba_smple                         =        zeros(size(FX_spot_smple));
FX_logxretba_smple(:,1)                    =        FX_spot_smple(:,1);      % Dates in the first column
FX_logxretba_smple(2:end,2:end)            =        log(FX_Fwd_EB_smple(1:end-1,2:end)./FX_spot_EO_smple(2:end,2:end));    

% Excess return= F_mid(t)/S_mid(t+1) -1;
FX_xret_smple                              =        zeros(size(FX_spot_smple));
FX_xret_smple(:,1)                         =        FX_spot_smple(:,1);      % Dates in the first column
FX_xret_smple(2:end,2:end)                 =        FX_Fwd_smple(1:end-1,2:end)./FX_spot_smple(2:end,2:end)-ones(size(FX_spot_smple(2:end,2:end)));    

% Excess return= F_ask(t)/S_bid(t+1)-1;
FX_xretab_smple                            =        zeros(size(FX_spot_smple));
FX_xretab_smple(:,1)                       =        FX_spot_smple(:,1);      % Dates in the first column
FX_xretab_smple(2:end,2:end)               =        FX_Fwd_EO_smple(1:end-1,2:end)./FX_spot_EB_smple(2:end,2:end)-ones(size(FX_spot_smple(2:end,2:end)));

% Excess return= F_bid(t)/S_ask(t+1)-1;
FX_xretba_smple                            =        zeros(size(FX_spot_smple));
FX_xretba_smple(:,1)                       =        FX_spot_smple(:,1);      % Dates in the first column
FX_xretba_smple(2:end,2:end)               =        FX_Fwd_EB_smple(1:end-1,2:end)./FX_spot_EO_smple(2:end,2:end)-ones(size(FX_spot_smple(2:end,2:end)));   

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Forward Discount(t,n)=(Forward(t-1,n)/Spot(t-1))/n                  
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB 1: the interest rate differential between t-1 and t is here dated t (even if it is known at date t-1)

FX_Dsct_smple=zeros(size(FX_Fwd_smple));

FX_Dsct_smple(:,1)                  =       FX_Fwd_smple(:,1);      % Dates
FX_Dsct_smple(1,2:end)              =       NaN;                    % First value
for k=1:size(FX_Fwd_smple,1)-1
    FX_Dsct_smple(k+1,2:end,1)      =       log((FX_Fwd_smple(k,2:end,1)./FX_spot_smple(k,2:end)));     % Values
end


% ============================================= %
% BUILD PORTFOLIOS
% ============================================= %

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Get rid of forward discount if no data on exchange rate change
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
for t=1:size(FX_Dsct_smple,1)                                               % For each date
    for c=2:size(FX_Dsct_smple,2)                                           % For each country
       if  isnan(FX_spot_chge_smple(t,c))==1
           FX_Dsct_smple(t,c)    = NaN;
       end         
    end
end


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Sort countries according to the different forward discounts
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
FX_Dsct_smple_sorted        = zeros(size(FX_Dsct_smple));
Index_sorting               = zeros(size(FX_Dsct_smple));

FX_Dsct_smple_sorted(:,1)   = FX_Dsct_smple(:,1);                                   % Dates
Index_sorting(:,1)          = FX_Dsct_smple(:,1);                                   % Dates  
[FX_Dsct_smple_sorted(:,2:end),Index_sorting(:,2:end)]=sort(FX_Dsct_smple(:,2:end),2);




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
FX_logxret_sorted                                                =         zeros(size(FX_Dsct_smple));
FX_logxretab_sorted                                              =         zeros(size(FX_Dsct_smple));
FX_logxretba_sorted                                              =         zeros(size(FX_Dsct_smple));
% Currency excess returns (with and without bid/ask spread)
FX_xret_sorted                                                   =         zeros(size(FX_Dsct_smple));
FX_xretab_sorted                                                 =         zeros(size(FX_Dsct_smple));
FX_xretba_sorted                                                 =         zeros(size(FX_Dsct_smple));
% Track countries
Track_countries                                                  =         zeros(size(FX_Dsct_smple));

FX_spot_chge_sorted(:,1)                             =         FX_Dsct_smple(:,1);                            % Dates
Track_countries(:,1)                                 =         FX_Dsct_smple(:,1);                            % Dates

for t=2:size(FX_Dsct_smple,1)                        % For each date
    for c=2:size(FX_Dsct_smple,2)                    % For each country

        FX_spot_chge_sorted(t,c)                     =         FX_spot_chge_smple(t,1+Index_sorting(t,c));
        FX_spot_spread_sorted(t,c)                   =         FX_spot_spread_smple(t,1+Index_sorting(t,c));
        RET_Dsct_sorted(t,c)                         =         FX_Dsct_smple(t,1+Index_sorting(t,c));
        RET_Dsct_spread_sorted(t,c)                  =         FX_Dsct_spread_smple(t,1+Index_sorting(t,c));

        FX_logxret_sorted(t,c)                       =         FX_logxret_smple(t,1+Index_sorting(t,c));
        FX_logxretab_sorted(t,c)                     =         FX_logxretab_smple(t,1+Index_sorting(t,c));
        FX_logxretba_sorted(t,c)                     =         FX_logxretba_smple(t,1+Index_sorting(t,c));
        FX_xret_sorted(t,c)                          =         FX_xret_smple(t,1+Index_sorting(t,c));
        FX_xretab_sorted(t,c)                        =         FX_xretab_smple(t,1+Index_sorting(t,c));
        FX_xretba_sorted(t,c)                        =         FX_xretba_smple(t,1+Index_sorting(t,c));

        Track_countries(t,c)                         =         Index_sorting(t,c);
    end
end

    

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Count the numbers of countries available at every date
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Count_countries     = zeros(size(FX_Dsct_smple,1),2);
Count_countries(:,1)= FX_Dsct_smple(:,1);                                   % Copy dates
for t=1:size(FX_Dsct_smple,1)                                               % For each date
    for c=2:size(FX_Dsct_smple,2)                                           % For each country
        Count_countries(t,2)                              =          Count_countries(t,2)+(not(isnan(FX_Dsct_smple_sorted(t,c))));
    end
end



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Group the countries into portfolios
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% The changes in exchange rates are equally weighted

portfolios_Spotchg_group  =     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
portfolios_Dsct_group     =     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
portfolios_logxret_group  =     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
portfolios_logxretba_group=     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
portfolios_xret_group     =     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
portfolios_xretba_group   =     zeros(size(FX_Dsct_smple,1),1+number_portfolios);
count_group               =     zeros(size(FX_Dsct_smple,1),number_portfolios);
Track_portfolios          =     zeros(size(FX_Dsct_smple));

portfolios_Spotchg_group(:,1)   =     FX_spot_chge_smple(:,1);    % Copy dates
portfolios_Dsct_group(:,1)      =     FX_spot_chge_smple(:,1);    % Copy dates
portfolios_logxret_group(:,1)   =     FX_spot_chge_smple(:,1);    % Copy dates
portfolios_logxretba_group(:,1) =     FX_spot_chge_smple(:,1);    % Copy dates
portfolios_xret_group(:,1)      =     FX_spot_chge_smple(:,1);    % Copy dates
portfolios_xretba_group(:,1)    =     FX_spot_chge_smple(:,1);    % Copy dates
Count_Returns                   =     Count_countries(:,2);

% First date row = NaN
portfolios_Spotchg_group(1,2:end)   = NaN;
portfolios_Dsct_group(1,2:end)      = NaN;
portfolios_logxret_group(1,2:end)   = NaN;
portfolios_logxretba_group(1,2:end) = NaN;
portfolios_xret_group(1,2:end)      = NaN;
portfolios_xretba_group(1,2:end)    = NaN;
count_group(1,2:end)                = NaN;
Track_portfolios(1,2:end)           = NaN;

for t=2:size(FX_Dsct_smple,1)                   % For each date

    for n=1:number_portfolios                  % For each portfolio

        if n==number_portfolios                % Special case: last portfolio
            for m=1+(n-1)*floor(Count_Returns(t)*(1/number_portfolios)):n*floor(Count_Returns(t)*(1/number_portfolios))+rem(Count_Returns(t),number_portfolios)                   
                if m<=Count_Returns(t)
                    % Compute the average change in FX (equal weights)
                    portfolios_logxret_group(t,1+n)                    =   portfolios_logxret_group(t,1+n)+FX_logxret_sorted(t,1+m);
                    portfolios_xret_group(t,1+n)                       =   portfolios_xret_group(t,1+n)+FX_xret_sorted(t,1+m);
                    portfolios_Spotchg_group(t,1+n)                    =   portfolios_Spotchg_group(t,1+n)+FX_spot_chge_sorted(t,1+m);
                    portfolios_Dsct_group(t,1+n)                       =   portfolios_Dsct_group(t,1+n)+RET_Dsct_sorted(t,1+m); 
                    if n<2
                        portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretab_sorted(t,1+m);                  
                        portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_xretab_sorted(t,1+m);                  
                    else
                        portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretba_sorted(t,1+m);
                        portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_xretba_sorted(t,1+m);
                    end
                    count_group(t,n)                                   =   count_group(t,n)+1;
                    Track_portfolios(t,Track_countries(t,1+m))         =   n;

                end
            end
        else                                    % All portfolios except the last one
            for m=1+(n-1)*floor(Count_Returns(t)*(1/number_portfolios)):n*floor(Count_Returns(t)*(1/number_portfolios))
                if m<=Count_Returns(t)
                    % Compute the average change in FX (equal weights)
                    portfolios_logxret_group(t,1+n)                    =   portfolios_logxret_group(t,1+n)+FX_logxret_sorted(t,1+m);
                    portfolios_xret_group(t,1+n)                       =   portfolios_xret_group(t,1+n)+FX_xret_sorted(t,1+m);
                    portfolios_Spotchg_group(t,1+n)                    =   portfolios_Spotchg_group(t,1+n)+FX_spot_chge_sorted(t,1+m);
                    portfolios_Dsct_group(t,1+n)                       =   portfolios_Dsct_group(t,1+n)+RET_Dsct_sorted(t,1+m); 
                    if n<2
                        portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretab_sorted(t,1+m);                  
                        portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_xretab_sorted(t,1+m);                  
                    else
                        portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretba_sorted(t,1+m);
                        portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_xretba_sorted(t,1+m);
                    end
                    count_group(t,n)                                   =   count_group(t,n)+1;
                    Track_portfolios(t,Track_countries(t,1+m))         =   n;

                end
            end
        end

        if count_group(t,n)>0
            portfolios_Spotchg_group(t,1+n)                      =   portfolios_Spotchg_group(t,1+n)/count_group(t,n);  
            portfolios_Dsct_group(t,1+n)                         =   portfolios_Dsct_group(t,1+n)/count_group(t,n);  
            portfolios_logxret_group(t,1+n)                      =   portfolios_logxret_group(t,1+n)/count_group(t,n);  
            portfolios_xret_group(t,1+n)                         =   portfolios_xret_group(t,1+n)/count_group(t,n);  
            portfolios_logxretba_group(t,1+n)                    =   portfolios_logxretba_group(t,1+n)/count_group(t,n);  
            portfolios_xretba_group(t,1+n)                       =   portfolios_xretba_group(t,1+n)/count_group(t,n);  
       else
            portfolios_Spotchg_group(t,1+n)                      =   NaN;
            portfolios_Dsct_group(t,1+n)                         =   NaN;
            portfolios_logxret_group(t,1+n)                      =   NaN;
            portfolios_xret_group(t,1+n)                         =   NaN;
            portfolios_logxretba_group(t,1+n)                    =   NaN;
            portfolios_xretba_group(t,1+n)                       =   NaN;
        end
    end


end
    


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Compute Excess Returns
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

portfolios_Spotchg_with_dates       =  portfolios_Spotchg_group(:,:);
portfolios_Dsct_with_dates          =  portfolios_Dsct_group(:,:);
portfolios_logxretba_with_dates     =  portfolios_logxretba_group(:,:);
portfolios_logxret_with_dates       =  portfolios_logxret_group(:,:);
portfolios_xretba_with_dates        =  portfolios_xretba_group(:,:);
portfolios_xret_with_dates          =  portfolios_xret_group(:,:);

% Compute excess returns using FX changes and interest rate differentials
portfolios_FXXR_with_dates          =  zeros(size(portfolios_Spotchg_with_dates));
portfolios_FXXR_with_dates(:,1)     =  portfolios_Spotchg_with_dates(:,1); % dates
portfolios_FXXR_with_dates(:,2:end) = -portfolios_Spotchg_with_dates(:,2:end)+portfolios_Dsct_with_dates(:,2:end);


% ============================================= %
% REPORT SUMMARY STATISTICS (annualized = x12)
% ============================================= %



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Select Time-Windows:
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
k=find(portfolios_FXXR_with_dates(:,1)==estimation_date_begin);
n=find(portfolios_FXXR_with_dates(:,1)==estimation_date_end);

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Summary Statistics on Monthly Series
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Numbermonths  =  12;

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
meanNp_ret=nanmean(portfolios_logxret_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average excess returns
stdNp_ret=nanstd(portfolios_logxret_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns');
    subplot(3,1,1);bar(meanNp_ret,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_ret,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_ret./stdNp_ret,'g');title('Sharpe Ratio (Annualized)')

% Excess returns (with Bid/Ask Spreads)
meanNp_retba=nanmean(portfolios_logxretba_with_dates(k:n,2:end))*Numbermonths;           % Time-Series average excess returns
stdNp_retba=nanstd(portfolios_logxretba_with_dates(k:n,2:end))*sqrt(Numbermonths);       % Time-Series dispersion of excess returns
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
lgsh=NaN*zeros(size(portfolios_logxret_with_dates(k:n,:),1),size(portfolios_logxret_with_dates,2)-2);
for j=1:size(portfolios_logxret_with_dates,2)-2
    lgsh(:,j)=portfolios_logxret_with_dates(k:n,2+j)-portfolios_logxret_with_dates(k:n,2);
end

meanNp_ret_lgsh=nanmean(lgsh)*Numbermonths;                 % Time-Series average excess returns
stdNp_ret_lgsh=nanstd(lgsh)*sqrt(Numbermonths);             % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns: Long-Short Strategies');
    subplot(3,1,1);bar(meanNp_ret_lgsh,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_ret_lgsh,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_ret_lgsh./stdNp_ret_lgsh,'g');title('Sharpe Ratio (Annualized)')

% Excess returns (with Bid/Ask Spreads)
lgsh=NaN*zeros(size(portfolios_logxretba_with_dates(k:n,:),1),size(portfolios_logxretba_with_dates,2)-2);
for j=1:size(portfolios_logxretba_with_dates,2)-2
    lgsh(:,j)=portfolios_logxretba_with_dates(k:n,2+j)-portfolios_logxretba_with_dates(k:n,2);
end

meanNp_retba_lgsh=nanmean(lgsh)*Numbermonths;                   % Time-Series average excess returns
stdNp_retba_lgsh=nanstd(lgsh)*sqrt(Numbermonths);               % Time-Series dispersion of excess returns
figure('Name','Portfolios of Currency Excess Returns (with Bid/Ask Spreads): Long-Short Strategies');
    subplot(3,1,1);bar(meanNp_retba_lgsh,'b');title('Mean Excess Returns (Annualized, x 12)')
    subplot(3,1,2);bar(stdNp_retba_lgsh,'r');title('Stdev of Excess Returns (Annualized, x sqrt(12))')
    subplot(3,1,3);bar(meanNp_retba_lgsh./stdNp_retba_lgsh,'g');title('Sharpe Ratio (Annualized)')

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Tables  (Quarterly series)
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
disp(' ');
disp('Tables (Quarterly series, annualized, estimation period)');
Results_all=[100*meanNp_Spotchg;100*stdNp_Spotchg;100*meanNp_Dsct;100*stdNp_Dsct;100*meanNp_ret;100*stdNp_ret;...
    meanNp_ret./stdNp_ret;...
    100*meanNp_retba;100*stdNp_retba;meanNp_retba./stdNp_retba];
latex(Results_all,'%6.2f');
disp(' ');
Results_all=[Results_all;9999 100*meanNp_ret_lgsh;9999 100*stdNp_ret_lgsh;9999 meanNp_ret_lgsh./stdNp_ret_lgsh;...
    9999 100*meanNp_retba_lgsh; 9999 100*stdNp_retba_lgsh; 9999 meanNp_retba_lgsh./stdNp_retba_lgsh];
latex(Results_all,'%6.2f');
disp(' ');


% ============================================= %
% SAVE PORTFOLIOS
% ============================================= %
portfolios_Spotchg_Barclays   = portfolios_Spotchg_with_dates;
portfolios_FXXR_Barclays      = portfolios_FXXR_with_dates;
portfolios_Dsct_Barclays      = portfolios_Dsct_with_dates;
portfolios_xret_Barclays      = portfolios_xret_with_dates;           % Excess return= F_mid(t)/S_mid(t+1)-1 
portfolios_xretba_Barclays    = portfolios_xretba_with_dates;         % Excess return= F_ask(t)/S_bid(t+1)-1 or excess return= F_bid(t)/S_ask(t+1)-1
portfolios_logxret_Barclays   = portfolios_logxret_with_dates;        % Log excess return= log(F_mid(t)/S_mid(t+1))
portfolios_logxretba_Barclays = portfolios_logxretba_with_dates;      % Log excess return= log(F_ask(t)/S_bid(t+1)) or Log excess return= log(F_bid(t)/S_ask(t+1));;

save(strcat(newpath,'portfolios_Spotchg_Barclays.mat'),'portfolios_Spotchg_Barclays');
save(strcat(newpath,'portfolios_FXXR_Barclays.mat'),'portfolios_FXXR_Barclays');
save(strcat(newpath,'portfolios_Dsct_Barclays.mat'),'portfolios_Dsct_Barclays');
save(strcat(newpath,'portfolios_xret_Barclays.mat'),'portfolios_xret_Barclays');
save(strcat(newpath,'portfolios_xretba_Barclays.mat'),'portfolios_xretba_Barclays');
save(strcat(newpath,'portfolios_logxret_Barclays.mat'),'portfolios_logxret_Barclays');
save(strcat(newpath,'portfolios_logxretba_Barclays.mat'),'portfolios_logxretba_Barclays');

