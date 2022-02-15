% ==================================================== %
% IMPORT JST Annual DATA
% ==================================================== %
% Program : 
% 1 ) Importannual data on market, interest rates
% 2 ) Check units and errors
% 3 ) Save data in Matlab format
% 4 ) Build annual series of currency returns


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

number_portfolios=3;


% ============================================= %
% Options
% ============================================= %
filename='JSTdatasetR5.xlsx';  %  Return indices in local currency

                            
% ============================================= %
% MSCI STOCK INDICES
% ============================================= %
% MSCI price indices for market, growth and value portfolios for each country

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before importing to Matlab

[temp,txt]=xlsread(strcat(newpath,filename),'Data');
s=size(temp);


T=148;
N=18;

country_index = 1;
str_index     = 17;
FX_index      = 23;
code_index    = 4;
US_index      = 18;

peg_index     = 34;

data_R     = [];
data_dates = [];
data_FX    = []; %local currency per USD
data_code    = [];
data_peg    = [];

for country_index=1:N

data_dates = [ data_dates temp(T*(country_index-1)+1:T*(country_index-1)+T,1) ];
data_R     = [ data_R temp(T*(country_index-1)+1:T*(country_index-1)+T,str_index) ];
data_FX    = [ data_FX temp(T*(country_index-1)+1:T*(country_index-1)+T,FX_index) ];
data_code  = [ data_code temp(T*(country_index-1)+1:T*(country_index-1)+T,code_index) ];
data_peg   = [ data_peg temp(T*(country_index-1)+1:T*(country_index-1)+T,peg_index) ];

end

FX_ret                     =   NaN(T,N-1);
FX_xret                    =   NaN(T,N-1);
FX_spot_chge               =   NaN(T,N-1);
FX_log_xret                =   NaN(T,N-1);
FX_Dsct                    =   NaN(T,N-1);

FX_ret(2:end,:)           =  (1+data_R(2:end,1:end-1)/100).*( (data_FX(1:end-1,1:end-1) ./data_FX(2:end,1:end-1)));
FX_xret(2:end,:)          =  (1+data_R(2:end,1:end-1)/100).*( (data_FX(1:end-1,1:end-1) ./data_FX(2:end,1:end-1)))-(1+data_R(2:end,US_index)/100);
FX_spot_chge(2:end,:)     =  (data_FX(1:end-1,1:end-1) ./data_FX(2:end,1:end-1));
FX_xret(2:end,:)          =  (1+data_R(2:end,1:end-1)/100).*( (data_FX(1:end-1,1:end-1) ./data_FX(2:end,1:end-1)))-(1+data_R(2:end,US_index)/100);
FX_log_xret(2:end,:)      =  log((1+data_R(2:end,1:end-1)/100)./(1+data_R(2:end,US_index)/100))-log( data_FX(2:end,1:end-1)./(data_FX(1:end-1,1:end-1)));
FX_Dsct(2:end,:)          =  log((1+data_R(2:end,1:end-1)/100)./(1+data_R(2:end,US_index)/100));

FX_R = data_R(:,1:end-1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ============================================= %
% BUILD PORTFOLIOS
% ============================================= %

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Get rid of forward discount if no data on exchange rate change
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
for t=1:size(FX_R,1)                                               % For each date
    for c=1:size(FX_R,2)                                           % For each country
       if  isnan(FX_spot_chge(t,c))==1 |  (data_peg(t,c)==1)| isnan(FX_log_xret(t,c))==1
           FX_R(t,c)  = NaN;
       end         
    end
end


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Sort countries according to the different forward discounts
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
FX_R_sorted   = zeros(size(FX_R));
Index_sorting = zeros(size(FX_R));

[FX_R_sorted(:,1:end),Index_sorting(:,1:end)]=sort(FX_R(:,1:end),2);




%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Reorder the countries according to the sorting above
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% NB: The interest rate differential between t and t+1 is actually known at t

% Changes in exchange rates
FX_spot_chge_sorted                                     =         zeros(size(FX_R));
% Interest rate differentials used to compute currency excess returns
FX_ret_sorted                                           =         zeros(size(FX_R));
FX_xret_sorted                                          =         zeros(size(FX_R));
FX_logxret_sorted                                       =         zeros(size(FX_R));
FX_Dsct_sorted                                          =         zeros(size(FX_R));

for t=1:size(FX_R,1)                        % For each date
    for c=1:size(FX_R,2)                    % For each country

        FX_spot_chge_sorted(t,c)                           =         FX_spot_chge(t,Index_sorting(t,c)); 
        FX_ret_sorted(t,c)                                 =         FX_ret(t,Index_sorting(t,c));
        FX_xret_sorted(t,c)                                =         FX_xret(t,Index_sorting(t,c));
        FX_logxret_sorted(t,c)                             =         FX_log_xret(t,Index_sorting(t,c));
        FX_Dsct_sorted(t,c)                                =         FX_Dsct(t,Index_sorting(t,c));
        Track_countries(t,c)                               =         Index_sorting(t,c);
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Count the numbers of countries available at every date
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Count_countries     = zeros(size(FX_R,1),2);
Count_countries(:,1)= data_dates(:,1);                                   % Copy dates
for t=1:size(FX_R,1)                                               % For each date
    for c=2:size(FX_R,2)                                           % For each country
        Count_countries(t,2)                              =          Count_countries(t,2)+(not(isnan(FX_R_sorted(t,c))));
    end
end



%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Group the countries into portfolios
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% The changes in exchange rates are equally weighted

portfolios_Spotchg_group  =     zeros(size(FX_R,1),1+number_portfolios);
portfolios_Dsct_group     =     zeros(size(FX_R,1),1+number_portfolios);
portfolios_logxret_group  =     zeros(size(FX_R,1),1+number_portfolios);
portfolios_xret_group     =     zeros(size(FX_R,1),1+number_portfolios);
count_group               =     zeros(size(FX_R,1),number_portfolios);
Track_portfolios          =     zeros(size(FX_R));

portfolios_Spotchg_group(:,1)   =     data_dates(:,1);    % Copy dates
portfolios_Dsct_group(:,1)      =     data_dates(:,1);    % Copy dates
portfolios_logxret_group(:,1)   =     data_dates(:,1);    % Copy dates
portfolios_xret_group(:,1)      =     data_dates(:,1);    % Copy dates
Count_Returns                   =     Count_countries(:,2);

% First date row = NaN
%portfolios_Spotchg_group(1,2:end)   = NaN;
%portfolios_Dsct_group(1,2:end)      = NaN;
%portfolios_logxret_group(1,2:end)   = NaN;
%portfolios_xret_group(1,2:end)      = NaN;
%count_group(1,2:end)                = NaN;
%Track_portfolios(1,2:end)           = NaN;

for t=2:size(FX_R,1)                   % For each date

    for n=1:number_portfolios                  % For each portfolio

        if n==number_portfolios                % Special case: last portfolio
            for m=1+(n-1)*floor(Count_Returns(t)*(1/number_portfolios)):n*floor(Count_Returns(t)*(1/number_portfolios))+rem(Count_Returns(t),number_portfolios)                   
                if m<=Count_Returns(t)
                    % Compute the average change in FX (equal weights)
                    portfolios_logxret_group(t,1+n)                    =   portfolios_logxret_group(t,1+n)+FX_logxret_sorted(t,1+m);
                    portfolios_xret_group(t,1+n)                       =   portfolios_xret_group(t,1+n)+FX_ret_sorted(t,1+m);
                    portfolios_Spotchg_group(t,1+n)                    =   portfolios_Spotchg_group(t,1+n)+FX_spot_chge_sorted(t,1+m);
                    portfolios_Dsct_group(t,1+n)                       =   portfolios_Dsct_group(t,1+n)+FX_Dsct_sorted(t,1+m); 
                    if n<2
                      %  portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretab_sorted(t,1+m);                  
                      %  portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_retab_sorted(t,1+m);                  
                    else
                      %  portfolios_logxretba_group(t,1+n)              =   portfolios_logxretba_group(t,1+n)+FX_logxretba_sorted(t,1+m);
                      %  portfolios_xretba_group(t,1+n)                 =   portfolios_xretba_group(t,1+n)+FX_retba_sorted(t,1+m);
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
                    portfolios_xret_group(t,1+n)                       =   portfolios_xret_group(t,1+n)+FX_ret_sorted(t,1+m);
                    portfolios_Spotchg_group(t,1+n)                    =   portfolios_Spotchg_group(t,1+n)+FX_spot_chge_sorted(t,1+m);
                    portfolios_Dsct_group(t,1+n)                       =   portfolios_Dsct_group(t,1+n)+FX_Dsct_sorted(t,1+m); 
                  
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
           
       else
            portfolios_Spotchg_group(t,1+n)                      =   NaN;
            portfolios_Dsct_group(t,1+n)                         =   NaN;
            portfolios_logxret_group(t,1+n)                      =   NaN;
            portfolios_xret_group(t,1+n)                         =   NaN;
            
        end
    end


end
    


%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Compute Excess Returns
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

portfolios_Spotchg_with_dates       =  portfolios_Spotchg_group(:,:);
portfolios_Dsct_with_dates          =  portfolios_Dsct_group(:,:);
portfolios_logxret_with_dates       =  portfolios_logxret_group(:,:);
portfolios_xret_with_dates          =  portfolios_xret_group(:,:);

% Compute excess returns using FX changes and interest rate differentials
portfolios_FXXR_with_dates          =  zeros(size(portfolios_Spotchg_with_dates));
portfolios_FXXR_with_dates(:,1)     =  portfolios_Spotchg_with_dates(:,1); % dates
portfolios_FXXR_with_dates(:,2:end) = -portfolios_Spotchg_with_dates(:,2:end)+portfolios_Dsct_with_dates(:,2:end);

