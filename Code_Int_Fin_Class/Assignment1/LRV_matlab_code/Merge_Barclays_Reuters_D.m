% ==================================================== %
% MERGE REUTERS AND BARCLAYS DATA
% ==================================================== %
% Program : 
% 1 ) Merge Reuters and Barclays daily data sets
% 2 ) Basic graphs,
% 3 ) Save data in Matlab format


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
% LOAD REUTERS DAILY SERIES 
% ============================================= %
% NB: These are end-of-the month series
% NB: Start in 12/31/1996
load(strcat(newpath,'Reuters_FX_Fwd_D.mat'));                      % FX_Fwd_sample
Reuters_FX_Fwd_D=FX_Fwd_sample;
load(strcat(newpath,'Reuters_FX_Fwd_EO_D.mat'));                   % FX_Fwd_EO_sample
Reuters_FX_Fwd_EO_D=FX_Fwd_EO_sample;
load(strcat(newpath,'Reuters_FX_Fwd_EB_D.mat'));                   % FX_Fwd_EB_sample
Reuters_FX_Fwd_EB_D=FX_Fwd_EB_sample;
load(strcat(newpath,'Reuters_FX_Spot_D.mat'));                      % FX_Spot_sample
Reuters_FX_Spot_D=FX_Spot_sample;
load(strcat(newpath,'Reuters_FX_Spot_EO_D.mat'));                   % FX_Spot_EO_sample
Reuters_FX_Spot_EO_D=FX_Spot_EO_sample;
load(strcat(newpath,'Reuters_FX_Spot_EB_D.mat'));                   % FX_Spot_EB_sample
Reuters_FX_Spot_EB_D=FX_Spot_EB_sample;
load(strcat(newpath,'Reuters_Countries_D.mat'));                    % List_names
List_names_Reuters=List_names;

% ============================================= %
% LOAD BARCLAYS DAILY SERIES 
% ============================================= %
% NB: These are beginning-of-the month series
load(strcat(newpath,'Barclays_FX_Fwd_D.mat'));        % FX_Fwd
load(strcat(newpath,'Barclays_FX_Fwd_EO_D.mat'));     % FX_Fwd_EO
load(strcat(newpath,'Barclays_FX_Fwd_EB_D.mat'));     % FX_Fwd_EB
load(strcat(newpath,'Barclays_FX_Spot_D.mat'));       % FX_Spot
load(strcat(newpath,'Barclays_FX_Spot_EO_D.mat'));    % FX_Spot_EO
load(strcat(newpath,'Barclays_FX_Spot_EB_D.mat'));    % FX_Spot_EB
load(strcat(newpath,'Barclays_Countries.mat'));       % List_names
List_names_Barclays=List_names;

% End them the same day
end_BR=min(Barclays_FX_Spot_D(end,1),Reuters_FX_Spot_D(end,1));
end_B=find(Barclays_FX_Spot_D(:,1)==end_BR);
end_R=find(Reuters_FX_Spot_D(:,1)==end_BR);

Barclays_FX_Spot_D=Barclays_FX_Spot_D(1:end_B,:);
Barclays_FX_Spot_EO_D=Barclays_FX_Spot_EO_D(1:end_B,:);
Barclays_FX_Spot_EB_D=Barclays_FX_Spot_EB_D(1:end_B,:);

Barclays_FX_Fwd_D=Barclays_FX_Fwd_D(1:end_B,:);
Barclays_FX_Fwd_EO_D=Barclays_FX_Fwd_EO_D(1:end_B,:);
Barclays_FX_Fwd_EB_D=Barclays_FX_Fwd_EB_D(1:end_B,:);

Reuters_FX_Spot_D=Reuters_FX_Spot_D(1:end_R,:);
Reuters_FX_Spot_EO_D=Reuters_FX_Spot_EO_D(1:end_R,:);
Reuters_FX_Spot_EB_D=Reuters_FX_Spot_EB_D(1:end_R,:);

Reuters_FX_Fwd_D=Reuters_FX_Fwd_D(1:end_R,:);
Reuters_FX_Fwd_EO_D=Reuters_FX_Fwd_EO_D(1:end_R,:);
Reuters_FX_Fwd_EB_D=Reuters_FX_Fwd_EB_D(1:end_R,:);

% ============================================= %
% MERGE DAILY SERIES 
% ============================================= %
% NB: Use Barclays data until 12/31/1996 and then switch to Reuters data

% ========
% Declare variables
% ========
BR_Spot_D=NaN*zeros(size(Barclays_FX_Spot_D,1),40);
BR_Spot_EB_D=NaN*zeros(size(Barclays_FX_Spot_EB_D,1),40);
BR_Spot_EO_D=NaN*zeros(size(Barclays_FX_Spot_EO_D,1),40);

BR_Fwd_D=NaN*zeros(size(Barclays_FX_Fwd_D,1),40);
BR_Fwd_EB_D=NaN*zeros(size(Barclays_FX_Fwd_EB_D,1),40);
BR_Fwd_EO_D=NaN*zeros(size(Barclays_FX_Fwd_EO_D,1),40);

% ========
% Copy country codes from Barclays
% ========
BR_Spot_D(1,2:size(Barclays_FX_Spot_D,2))=Barclays_FX_Spot_D(1,2:size(Barclays_FX_Spot_D,2)); 
BR_Spot_EB_D(1,2:size(Barclays_FX_Spot_EB_D,2))=Barclays_FX_Spot_EB_D(1,2:size(Barclays_FX_Spot_EB_D,2)); 
BR_Spot_EO_D(1,2:size(Barclays_FX_Spot_EO_D,2))=Barclays_FX_Spot_EO_D(1,2:size(Barclays_FX_Spot_EO_D,2)); 

BR_Fwd_D(1,2:size(Barclays_FX_Spot_D,2))=Barclays_FX_Fwd_D(1,2:size(Barclays_FX_Spot_D,2)); 
BR_Fwd_EB_D(1,2:size(Barclays_FX_Spot_EB_D,2))=Barclays_FX_Fwd_EB_D(1,2:size(Barclays_FX_Spot_EB_D,2)); 
BR_Fwd_EO_D(1,2:size(Barclays_FX_Spot_EO_D,2))=Barclays_FX_Fwd_EO_D(1,2:size(Barclays_FX_Spot_EO_D,2)); 

% ========
% Copy Barclays data until 01/01/1997
% ========
% Find 12/31/1996
end_Barclays=find(Barclays_FX_Spot_D(:,1)==datenum('01/01/1997'));

% Dates and data
BR_Spot_D(2:end_Barclays,1:size(Barclays_FX_Spot_D,2)) =Barclays_FX_Spot_D(2:end_Barclays,1:size(Barclays_FX_Spot_D,2));
BR_Spot_EB_D(2:end_Barclays,1:size(Barclays_FX_Spot_EB_D,2)) =Barclays_FX_Spot_EB_D(2:end_Barclays,1:size(Barclays_FX_Spot_EB_D,2));
BR_Spot_EO_D(2:end_Barclays,1:size(Barclays_FX_Spot_EO_D,2)) =Barclays_FX_Spot_EO_D(2:end_Barclays,1:size(Barclays_FX_Spot_EO_D,2));

BR_Fwd_D(2:end_Barclays,1:size(Barclays_FX_Spot_D,2)) =Barclays_FX_Fwd_D(2:end_Barclays,1:size(Barclays_FX_Spot_D,2));
BR_Fwd_EB_D(2:end_Barclays,1:size(Barclays_FX_Spot_EB_D,2)) =Barclays_FX_Fwd_EB_D(2:end_Barclays,1:size(Barclays_FX_Spot_EB_D,2));
BR_Fwd_EO_D(2:end_Barclays,1:size(Barclays_FX_Spot_EO_D,2)) =Barclays_FX_Fwd_EO_D(2:end_Barclays,1:size(Barclays_FX_Spot_EO_D,2));

% ========
% Copy Reuters dates
% ========

BR_Spot_D(end_Barclays:end,1)=Reuters_FX_Spot_D(3:end,1);
BR_Spot_EB_D(end_Barclays:end,1)=Reuters_FX_Spot_EB_D(3:end,1);
BR_Spot_EO_D(end_Barclays:end,1)=Reuters_FX_Spot_EO_D(3:end,1);

BR_Fwd_D(end_Barclays:end,1)=Reuters_FX_Fwd_D(3:end,1);
BR_Fwd_EB_D(end_Barclays:end,1)=Reuters_FX_Fwd_EB_D(3:end,1);
BR_Fwd_EO_D(end_Barclays:end,1)=Reuters_FX_Fwd_EO_D(3:end,1);

% ========
% Copy Reuters data for Barclays countries
% ========
temp_issue = NaN*zeros(size(Reuters_FX_Spot_D,2),size(Barclays_FX_Spot_D,2));
n=1;
for t=3:size(Reuters_FX_Spot_D,2)
    % For each series in the Barclays data set
    for j=2:size(Barclays_FX_Spot_D,2)
        % Find the corresponding series in Reuters
        col=find(Reuters_FX_Spot_D(1,:)==BR_Spot_D(1,j));
        if isempty(col)==0
            % Use Reuters data when available
            BR_Spot_D(end_Barclays:end,j)=Reuters_FX_Spot_D(3:end,col);
            BR_Spot_EB_D(end_Barclays:end,j)=Reuters_FX_Spot_EB_D(3:end,col);
            BR_Spot_EO_D(end_Barclays:end,j)=Reuters_FX_Spot_EO_D(3:end,col);

            BR_Fwd_D(end_Barclays:end,j)=Reuters_FX_Fwd_D(3:end,col);
            BR_Fwd_EB_D(end_Barclays:end,j)=Reuters_FX_Fwd_EB_D(3:end,col);
            BR_Fwd_EO_D(end_Barclays:end,j)=Reuters_FX_Fwd_EO_D(3:end,col);

        else
            % Use Barclays data elsewhere 
            temp_issue(n,1)=j;
            temp_issue(n,2)=datenum(Barclays_FX_Spot_D(t,1));
            n=n+1;
            BR_Spot_D(end_Barclays:end,j)=Barclays_FX_Spot_D(end_Barclays:end,j);
            BR_Spot_EB_D(end_Barclays:end,j)=Barclays_FX_Spot_EB_D(end_Barclays:end,j);
            BR_Spot_EO_D(end_Barclays:end,j)=Barclays_FX_Spot_EO_D(end_Barclays:end,j);

            BR_Fwd_D(end_Barclays:end,j)=Barclays_FX_Fwd_D(end_Barclays:end,j);
            BR_Fwd_EB_D(end_Barclays:end,j)=Barclays_FX_Fwd_EB_D(end_Barclays:end,j);
            BR_Fwd_EO_D(end_Barclays:end,j)=Barclays_FX_Fwd_EO_D(end_Barclays:end,j);

        end
    end
end

% ========
% Add countries from Reuters data set
% ========

k=1;
for j=2:size(Reuters_FX_Spot_D,2)
    % Test if country already in dataset
    col=find(BR_Spot_D(1,:)==Reuters_FX_Spot_D(1,j));
    if isempty(col)==1
        % Copy country code
        BR_Spot_D(1,size(Barclays_FX_Spot_D,2)+k)=Reuters_FX_Spot_D(1,j);
        BR_Spot_EB_D(1,size(Barclays_FX_Spot_EB_D,2)+k)=Reuters_FX_Spot_EB_D(1,j);
        BR_Spot_EO_D(1,size(Barclays_FX_Spot_EO_D,2)+k)=Reuters_FX_Spot_EO_D(1,j);

        BR_Fwd_D(1,size(Barclays_FX_Spot_D,2)+k)=Reuters_FX_Fwd_D(1,j);
        BR_Fwd_EB_D(1,size(Barclays_FX_Spot_EB_D,2)+k)=Reuters_FX_Fwd_EB_D(1,j);
        BR_Fwd_EO_D(1,size(Barclays_FX_Spot_EO_D,2)+k)=Reuters_FX_Fwd_EO_D(1,j);

        % Copy Reuters data
        BR_Spot_D(end_Barclays:end,size(Barclays_FX_Spot_D,2)+k)=Reuters_FX_Spot_D(3:end,j);
        BR_Spot_EB_D(end_Barclays:end,size(Barclays_FX_Spot_EB_D,2)+k)=Reuters_FX_Spot_EB_D(3:end,j);
        BR_Spot_EO_D(end_Barclays:end,size(Barclays_FX_Spot_EO_D,2)+k)=Reuters_FX_Spot_EO_D(3:end,j);

        BR_Fwd_D(end_Barclays:end,size(Barclays_FX_Spot_D,2)+k)=Reuters_FX_Fwd_D(3:end,j);
        BR_Fwd_EB_D(end_Barclays:end,size(Barclays_FX_Spot_EB_D,2)+k)=Reuters_FX_Fwd_EB_D(3:end,j);
        BR_Fwd_EO_D(end_Barclays:end,size(Barclays_FX_Spot_EO_D,2)+k)=Reuters_FX_Fwd_EO_D(3:end,j);

        k=k+1;
    end
end

% ============================================= %
% FIND COUNTRIES' NAMES
% ============================================= %
[IMF_codes, IMF_names]=xlsread('IMF_codes.xls');
List_names_BR=cell(size(BR_Spot_D,2)-1,1);

for i=2:size(BR_Spot_D,2)
    row=find(IMF_codes(:,1)==BR_Spot_D(1,i));
    List_names_BR(i,1)=IMF_names(row,1);
end

% ============================================= %
% Extend Samples to End-of-Month
% ============================================= %
BR_Spot_D    = Extend_EndofMonth(BR_Spot_D);
BR_Spot_EO_D = Extend_EndofMonth(BR_Spot_EO_D);
BR_Spot_EB_D = Extend_EndofMonth(BR_Spot_EB_D);
BR_Fwd_D     = Extend_EndofMonth(BR_Fwd_D);
BR_Fwd_EO_D  = Extend_EndofMonth(BR_Fwd_EO_D);
BR_Fwd_EB_D  = Extend_EndofMonth(BR_Fwd_EB_D);


% ============================================= %
% SWITCH FREQUENCY TO MONTHLY
% ============================================= %
% Transform all series into end-of-the month series
NM=split(between(datetime(BR_Spot_D(2,1),'ConvertFrom','datenum'),datetime(BR_Spot_D(end,1),'ConvertFrom','datenum'),'Months'),'Months');
% NM=months(BR_Spot_D(2,1),BR_Spot_D(end,1));
BR_Spot_M=NaN*zeros(NM,size(BR_Spot_D,2));
BR_Spot_EO_M=NaN*zeros(NM,size(BR_Spot_EO_D,2));
BR_Spot_EB_M=NaN*zeros(NM,size(BR_Spot_EB_D,2));
BR_Fwd_M=NaN*zeros(NM,size(BR_Fwd_D,2));
BR_Fwd_EO_M=NaN*zeros(NM,size(BR_Fwd_D,2));
BR_Fwd_EB_M=NaN*zeros(NM,size(BR_Fwd_D,2));

% Codes
BR_Spot_M(1,:)=BR_Spot_D(1,:);
BR_Spot_EO_M(1,:)=BR_Spot_EO_D(1,:);
BR_Spot_EB_M(1,:)=BR_Spot_EB_D(1,:);
BR_Fwd_M(1,:)=BR_Fwd_D(1,:);
BR_Fwd_EO_M(1,:)=BR_Fwd_D(1,:);
BR_Fwd_EB_M(1,:)=BR_Fwd_D(1,:);

% Data
k=2;
for t=2:size(BR_Spot_D,1)-1
    if month(datetime(BR_Spot_D(t,1),'ConvertFrom','datenum'))~=month(datetime(BR_Spot_D(t+1,1),'ConvertFrom','datenum')) % find end-of-month
        [N, S]=weekday(BR_Spot_D(t,1));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        BR_Spot_M(k,:)=BR_Spot_D(t+j,:);
        BR_Spot_EO_M(k,:)=BR_Spot_EO_D(t+j,:);
        BR_Spot_EB_M(k,:)=BR_Spot_EB_D(t+j,:);
        BR_Fwd_M(k,:)=BR_Fwd_D(t+j,:);
        BR_Fwd_EO_M(k,:)=BR_Fwd_EO_D(t+j,:);
        BR_Fwd_EB_M(k,:)=BR_Fwd_EB_D(t+j,:);
        k=k+1;
    end
end

% ============================================= %
% BUILD MONTHLY SERIES OF EXCHANGE RATES VOLATILITY
% ============================================= %

% Build daily spot change
BR_Spot_D_chge=NaN*zeros(size(BR_Spot_D));
BR_Spot_D_chge(:,1)=BR_Spot_D(:,1);                                                 % Dates
BR_Spot_D_chge(1,:)=BR_Spot_D(1,:);                                                 % IMF codes
BR_Spot_D_chge(3:end,2:end)=BR_Spot_D(3:end,2:end)./BR_Spot_D(2:end-1,2:end)-1;     % Spot change

% Build monthly spot change volatility
BR_Spot_M_vol=NaN*zeros(size(BR_Spot_M,1),size(BR_Spot_D,2));
BR_Spot_M_vol(1,:)=BR_Spot_D_chge(1,:);                                                 % IMF codes
BR_Spot_M_vol(:,1)=BR_Spot_M(:,1);                                                      % Dates
% Volatility
for t=2:size(BR_Spot_M_vol,1)
    %     datetime(BR_Spot_M_vol(t,1),'ConvertFrom','datenum')
    rows_temp=find(month(datetime(BR_Spot_D_chge(:,1),'ConvertFrom','datenum'))==month(datetime(BR_Spot_M_vol(t,1),'ConvertFrom','datenum')) & ...
        year(datetime(BR_Spot_D_chge(:,1),'ConvertFrom','datenum'))==year(datetime(BR_Spot_M_vol(t,1),'ConvertFrom','datenum')));
    for k=2:size(BR_Spot_M_vol,2)
        BR_Spot_M_vol(t,k)=nanstd(BR_Spot_D_chge(rows_temp,k));
    end
end

% Check
disp(' ');
disp('Exchange rates volatility (in %): ');
disp(100*nanmean(BR_Spot_M_vol(2:end,2:end)));

% Save
save(strcat(newpath,'BR_Spot_M_vol.mat'),'BR_Spot_M_vol');


% ============================================= %
% GRAPHS
% ============================================= %
%There are 39 countries in the sample
show_graphs=1;

if show_graphs==1
    
    % FX Spot change
    figure('Name','Country by Country FX Spot Change  (in percentage points)');
    for k=1:size(BR_Spot_M,2)-1
        subplot(5,8,k);
        plot(BR_Spot_M(3:end,1),100*(BR_Spot_M(3:end,1+k)./BR_Spot_M(2:end-1,1+k)-1),'b');
        title(List_names_BR(1+k,1));
        datetick('x',11);
        axis tight
    end
    
    % Spread on FX Spot
    figure('Name','Country by Country Spread on FX Spot  (in percentage points)');
    for k=1:size(BR_Spot_M,2)-1
        subplot(5,8,k);
        plot(BR_Spot_M(:,1),100*(BR_Spot_EO_M(:,1+k)./BR_Spot_EB_M(:,1+k)-1),'b');
        title(List_names_BR(1+k,1));
        datetick('x',11);
        axis tight
    end

    % One-Month Discount
    figure('Name','Country by Country One-Month Discount (in percentage points)');
    for k=1:size(BR_Spot_M,2)-1
        subplot(5,8,k);
        plot(BR_Fwd_M(:,1),100*(BR_Fwd_M(:,1+k)./BR_Spot_M(:,1+k)-1),'b');
        title(List_names_BR(1+k,1));
        datetick('x',11);
        axis tight
    end


    % Spread on FX Forward One-Month
    figure('Name','Country by Country Spread on FX Forward One-Month  (in percentage points)');
    for k=1:size(BR_Spot_M,2)-1
        subplot(5,8,k);
        plot(BR_Fwd_M(2:end,1,1),100*(BR_Fwd_EO_M(2:end,1+k)-BR_Fwd_EB_M(2:end,1+k))./BR_Fwd_EB_M(2:end,1+k),'b');
        title(List_names_BR(1+k,1));
        datetick('x',11);
        axis tight;
    end

    
    % Volatility of changes in spot exchange rates
    figure('Name','Country by Country Volatility of changes in spot exchange rates  (in percentage points)');
    for k=1:size(BR_Spot_M_vol,2)-1
        subplot(5,8,k);
        plot(BR_Spot_M_vol(2:end,1),100*BR_Spot_M_vol(2:end,1+k),'b');
        title(List_names_BR(1+k,1));
        datetick('x',11);
        axis tight
    end
    
end



% ============================================= %
% SAVE .MAT
% ============================================= %
BR_Fwd_dM=BR_Fwd_M;
BR_Fwd_EO_dM=BR_Fwd_EO_M;
BR_Fwd_EB_dM=BR_Fwd_EB_M;
BR_Spot_dM=BR_Spot_M;
BR_Spot_EO_dM=BR_Spot_EO_M;
BR_Spot_EB_dM=BR_Spot_EB_M;

% Save monthly series as CSV to clean in Stata
csvwrite(strcat(newpath,'BR_Fwd_dM.csv'),BR_Fwd_M);
csvwrite(strcat(newpath,'BR_Fwd_EO_dM.csv'),BR_Fwd_EO_M);
csvwrite(strcat(newpath,'BR_Fwd_EB_dM.csv'),BR_Fwd_EB_M);
csvwrite(strcat(newpath,'BR_Spot_dM.csv'),BR_Spot_M);
csvwrite(strcat(newpath,'BR_Spot_EO_dM.csv'),BR_Spot_EO_M);
csvwrite(strcat(newpath,'BR_Spot_EB_dM.csv'),BR_Spot_EB_M);
csvwrite(strcat(newpath,'List_names_BR.csv'),List_names_BR);

% Save monthly series as matlab table
save(strcat(newpath,'BR_Fwd_dM.mat'),'BR_Fwd_M');
save(strcat(newpath,'BR_Fwd_EO_dM.mat'),'BR_Fwd_EO_M');
save(strcat(newpath,'BR_Fwd_EB_dM.mat'),'BR_Fwd_EB_M');
save(strcat(newpath,'BR_Spot_dM.mat'),'BR_Spot_M');
save(strcat(newpath,'BR_Spot_EO_dM.mat'),'BR_Spot_EO_M');
save(strcat(newpath,'BR_Spot_EB_dM.mat'),'BR_Spot_EB_M');
save(strcat(newpath,'List_names_BR.mat'),'List_names_BR');

% Save daily series
save(strcat(newpath,'BR_Fwd_D.mat'),'BR_Fwd_D');
save(strcat(newpath,'BR_Fwd_EO_D.mat'),'BR_Fwd_EO_D');
save(strcat(newpath,'BR_Fwd_EB_D.mat'),'BR_Fwd_EB_D');
save(strcat(newpath,'BR_Spot_D.mat'),'BR_Spot_D');
save(strcat(newpath,'BR_Spot_EO_D.mat'),'BR_Spot_EO_D');
save(strcat(newpath,'BR_Spot_EB_D.mat'),'BR_Spot_EB_D');
save(strcat(newpath,'List_names_BR.mat'),'List_names_BR');

