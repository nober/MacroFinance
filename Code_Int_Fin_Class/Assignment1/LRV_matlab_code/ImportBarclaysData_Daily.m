% ==================================================== %
% IMPORT BARCLAYS DAILY DATA
% ==================================================== %
% Program : 
% 1 ) Import daily data on spot and forward exchange rates,
% 2 ) Check units and errors
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
% Import BARCLAYS FORWARD RATES 
% ============================================= %
% Source: Datastream

%////////////////
% Import one-month forward exchange rates
%////////////////

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.

FX_Fwd_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet1');% 1983-1993
FX_Fwd_EB_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet2');
FX_Fwd_EO_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet3');

FX_Fwd_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet4');% 1993-2003
FX_Fwd_EB_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet5');
FX_Fwd_EO_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet6');

FX_Fwd_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet7');% 2003-2008
FX_Fwd_EB_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet8');
FX_Fwd_EO_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet9');

FX_Fwd_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet10');% 2008-now
FX_Fwd_EB_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet11');
FX_Fwd_EO_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_FW1F_D.xlsm'),'Sheet12');

% Aggregate
FX_Fwd_temp=[FX_Fwd_temp1;FX_Fwd_temp2(2:end,:);FX_Fwd_temp3(2:end,:);FX_Fwd_temp4(2:end,:)];
FX_Fwd_EB_temp=[FX_Fwd_EB_temp1;FX_Fwd_EB_temp2(2:end,:);FX_Fwd_EB_temp3(2:end,:);FX_Fwd_EB_temp4(2:end,:)];
FX_Fwd_EO_temp=[FX_Fwd_EO_temp1;FX_Fwd_EO_temp2(2:end,:);FX_Fwd_EO_temp3(2:end,:);FX_Fwd_EO_temp4(2:end,:)];

% Matlab dates
FX_Fwd_temp(:,1)=FX_Fwd_temp(:,1)+693960;
FX_Fwd_EB_temp(:,1)=FX_Fwd_EB_temp(:,1)+693960;
FX_Fwd_EO_temp(:,1)=FX_Fwd_EO_temp(:,1)+693960;

% Insert IMF codes in the first lines:
IMF_codes_Fwd=[NaN 112 136 124 132 146 134 138 158 532 199 156 576 548 193 196 144 142 128 163];
FX_Fwd=[IMF_codes_Fwd;FX_Fwd_temp];
FX_Fwd_EB=[IMF_codes_Fwd;FX_Fwd_EB_temp];
FX_Fwd_EO=[IMF_codes_Fwd;FX_Fwd_EO_temp];




% ============================================= %
% Import BARCLAYS SPOT RATES 
% ============================================= %
% Source: Datastream

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.

FX_Spot_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet1');% 1983-1993
FX_Spot_EB_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet2');
FX_Spot_EO_temp1=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet3');

FX_Spot_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet4');% 1993-2003
FX_Spot_EB_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet5');
FX_Spot_EO_temp2=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet6');

FX_Spot_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet7');% 2003-2009
FX_Spot_EB_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet8');
FX_Spot_EO_temp3=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet9');

FX_Spot_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet10');% 2009-
FX_Spot_EB_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet11');
FX_Spot_EO_temp4=xlsread(strcat(newpath,'DataRequests_Barclays_SP_D.xlsm'),'Sheet12');

% Aggregate
FX_Spot_temp=[FX_Spot_temp1;FX_Spot_temp2(2:end,:);FX_Spot_temp3(2:end,:);FX_Spot_temp4(2:end,:)];
FX_Spot_EB_temp=[FX_Spot_EB_temp1;FX_Spot_EB_temp2(2:end,:);FX_Spot_EB_temp3(2:end,:);FX_Spot_EB_temp4(2:end,:)];
FX_Spot_EO_temp=[FX_Spot_EO_temp1;FX_Spot_EO_temp2(2:end,:);FX_Spot_EO_temp3(2:end,:);FX_Spot_EO_temp4(2:end,:)];

% Matlab dates
FX_Spot_temp(:,1)=FX_Spot_temp(:,1)+693960;
FX_Spot_EB_temp(:,1)=FX_Spot_EB_temp(:,1)+693960;
FX_Spot_EO_temp(:,1)=FX_Spot_EO_temp(:,1)+693960;

% Insert IMF codes in the first lines:
FX_Spot=[IMF_codes_Fwd;FX_Spot_temp];
FX_Spot_EB=[IMF_codes_Fwd;FX_Spot_EB_temp];
FX_Spot_EO=[IMF_codes_Fwd;FX_Spot_EO_temp];


% Countries' list
List_names=cell(size(IMF_codes_Fwd,2)-1,1);
[IMF_codes, IMF_names]=xlsread('IMF_codes.xls');
for i=2:size(FX_Spot,2)
    row=find(IMF_codes(:,1)==FX_Spot(1,i));
    List_names(i,1)=IMF_names(row,1);
end


% ============================================= %
% EXCHANGE RATE UNITS
% ============================================= %
% FX Forward and spot data are in units of foreign currency per USD (Ex: 1 USD = 5.19 FF), 
% except for  UK (112)
% Write all forward and spot data in foreign currency per USD
colUK=find(FX_Spot(1,:)==112);
FX_Spot(2:end,colUK)=ones(size(FX_Spot,1)-1,1)./FX_Spot(2:end,colUK);
% Switch the bid and offered rate (so that the spread remains positive)
FX_Spot_EO_UK=FX_Spot_EO(2:end,colUK);
FX_Spot_EB_UK=FX_Spot_EB(2:end,colUK);
FX_Spot_EO(2:end,colUK)=ones(size(FX_Spot_EB,1)-1,1)./FX_Spot_EB_UK;
FX_Spot_EB(2:end,colUK)=ones(size(FX_Spot_EB,1)-1,1)./FX_Spot_EO_UK;

for k=1:size(FX_Fwd,3)
    FX_Fwd(2:end,colUK,k)=ones(size(FX_Fwd,1)-1,1)./FX_Fwd(2:end,colUK,k);
    % Switch the bid and offered rate (so that the spread remains positive)
    FX_Fwd_EO_UK=FX_Fwd_EO(2:end,colUK,k);
    FX_Fwd_EB_UK=FX_Fwd_EB(2:end,colUK,k);
    FX_Fwd_EO(2:end,colUK,k)=ones(size(FX_Fwd_EB,1)-1,1)./FX_Fwd_EB_UK;
    FX_Fwd_EB(2:end,colUK,k)=ones(size(FX_Fwd_EB,1)-1,1)./FX_Fwd_EO_UK;
end


% ============================================= %
% CORRECTIONS
% ============================================= %


%//////////
% USE REUTERS FORWARD RATES AFTER 2016
%//////////

load(strcat(newpath,'Reuters_FX_Fwd_D.mat'));                      % FX_Fwd_sample
Reuters_FX_Fwd_D=FX_Fwd_sample(:,:);        
load(strcat(newpath,'Reuters_FX_Fwd_EO_D.mat'));                   % FX_Fwd_EO_sample
Reuters_FX_Fwd_EO_D=FX_Fwd_EO_sample(:,:);  
load(strcat(newpath,'Reuters_FX_Fwd_EB_D.mat'));                   % FX_Fwd_EB_sample
Reuters_FX_Fwd_EB_D=FX_Fwd_EB_sample(:,:);  

for i=2:size(IMF_codes_Fwd,2)
    
    imf_code = IMF_codes_Fwd(1,i);
    
    % Find the right series using its IMF code
    col_c_Barclays=find(FX_Fwd(1,:,1)==imf_code);

    col_c_Reuters=find(Reuters_FX_Fwd_D(1,:,1)==imf_code);

    if ~isempty(col_c_Reuters)
        start_repl_fwd_Barclays=find(FX_Fwd(:,1,1)==datenum('1/1/2016'));
        start_repl_fwd_Reuters=find(Reuters_FX_Fwd_D(:,1,1)==datenum('1/1/2016'));

        FX_Fwd(start_repl_fwd_Barclays:end,col_c_Barclays) = Reuters_FX_Fwd_D(start_repl_fwd_Reuters:end,col_c_Reuters); 

        FX_Fwd_EO(start_repl_fwd_Barclays:end,col_c_Barclays) = Reuters_FX_Fwd_EO_D(start_repl_fwd_Reuters:end,col_c_Reuters); 

        FX_Fwd_EB(start_repl_fwd_Barclays:end,col_c_Barclays) = Reuters_FX_Fwd_EB_D(start_repl_fwd_Reuters:end,col_c_Reuters); 
        
    else
        disp(imf_code);
        % For Sweden, there's no WMR Reuters series in the database ---
        % Let's add it
        FX_Fwd(start_repl_fwd_Barclays:end,col_c_Barclays) = NaN; 

        FX_Fwd_EO(start_repl_fwd_Barclays:end,col_c_Barclays) = NaN; 

        FX_Fwd_EB(start_repl_fwd_Barclays:end,col_c_Barclays) = NaN; 
    end
    
end



%/////////
% Belgium
%/////////
% Series are stale starting in 12/19/1989 for future contracts and 1/1/1990 for spot rates
endBG=find(FX_Spot(:,1)==datenum('1/1/1990'));
% First look for the IMF code of Belgium
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'BELGIUM')==1
      code_imf=IMF_codes(j,1);
   end       
end
% Find the right series using its IMF code
col_BG=find(FX_Spot(1,:)==code_imf);
% Replace values with NaN
FX_Spot(endBG:end,col_BG)=NaN;
FX_Spot_EO(endBG:end,col_BG)=NaN;
FX_Spot_EB(endBG:end,col_BG)=NaN;
% Same for forward rates
endBG=find(FX_Fwd(:,1)==datenum('12/19/1989'));

FX_Fwd(endBG:end,col_BG)=NaN;
FX_Fwd_EO(endBG:end,col_BG)=NaN;
FX_Fwd_EB(endBG:end,col_BG)=NaN;


%/////////
% Australia
%/////////
% Missing data for Fwd 1M on 10/1/2001 and FWd 3M on 12/1/1996
% NB: values exist for the bid and ask rates
% First look for the IMF code of Australia
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'AUSTRALIA')==1
      code_imf=IMF_codes(j,1);
   end      
end
% Find the right series using its IMF code
col_AU=find(FX_Spot(1,:)==code_imf);
% Replace values with NaN
outlier_au=find(FX_Fwd(:,1,1)==datenum('10/1/2001'));
FX_Fwd(outlier_au,col_AU,1)=NaN; 


%/////////
% Norway
%/////////
% Strange negative value on forward discount 

% First look for the IMF code of Norway
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'NORWAY')==1
      code_imf=IMF_codes(j,1);
   end    
end
% Find the right series using its IMF code
col_NW=find(FX_Fwd(1,:,1)==code_imf);
% Find the right series 
line_NW=find(FX_Fwd(:,col_NW)==min(FX_Fwd(:,col_NW)));

% Replace value
FX_Fwd(line_NW,col_NW)=NaN;


%/////////
% New-Zealand
%/////////
% Strange large value on forward discount 

% First look for the IMF code of New-Zealand
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'NEW ZEALAND')==1
      code_imf=IMF_codes(j,1);
   end       
end
% Find the right series using its IMF code
col_NZ=find(FX_Fwd(1,:)==code_imf);
% Find the max
line_NZ=find(FX_Fwd(2:end,col_NZ)==max(FX_Fwd(2:end,col_NZ)));

% Replace value with NaN
FX_Fwd(line_NZ+1,col_NZ)=NaN;
FX_Fwd_EB(line_NZ+1,col_NZ)=NaN;
FX_Fwd_EO(line_NZ+1,col_NZ)=NaN;



%/////////
% South Africa
%/////////
% Strange large value on forward discount 

% % First look for the IMF code of South Africa

% Find the right series using its IMF code
col_ZAF     = find(FX_Fwd(1,:)==199);
start_weird = find(FX_Fwd(:,1) == datenum('31-Jul-1985'));
end_weird = find(FX_Fwd(:,1) == datenum('30-Aug-1985'));

FX_Fwd(start_weird+1:end_weird,col_ZAF)=NaN;                                     
FX_Fwd_EO(start_weird+1:end_weird,col_ZAF)=NaN;                                  
FX_Fwd_EB(start_weird+1:end_weird,col_ZAF)=NaN;                                  


%/////////
% Hong Kong
%/////////
% Strange large value on forward discount at the start of the series

% First look for the IMF code of Hong Kong
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'CHINA HONG KONG')==1
      code_imf=IMF_codes(j,1);
   end       
end
% Find the right series using its IMF code
col_HK=find(FX_Fwd(1,:)==code_imf);
% Find the right series using its IMF code
line_HK=find(FX_Fwd(2:end,col_HK)==max(FX_Fwd(2:end,col_HK)));

% Replace value with NaN
FX_Fwd(line_HK(1,1)+1:line_HK(1,1)+7,col_HK)=NaN;
FX_Fwd_EB(line_HK(1,1)+1:line_HK(1,1)+7,col_HK)=NaN;
FX_Fwd_EO(line_HK(1,1)+1:line_HK(1,1)+7,col_HK)=NaN;



%/////////
% Euro area countries
%/////////
% Delete spot and forward values for Germany, France, Italy, Belgium and Netherlands
starteuro_fwd=find(FX_Fwd(:,1)==datenum('1/1/1999'));
starteuro_spot=find(FX_Spot(:,1)==datenum('1/1/1999'));

for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'GERMANY')==1;code_imf=IMF_codes(j,1);end      
end
% Find the right series using its IMF code
col_c=find(FX_Spot(1,:)==code_imf);
% Replace national currencies with NaN after 1/1/1999
FX_Spot(starteuro_spot:end,col_c)=NaN;
FX_Spot_EO(starteuro_spot:end,col_c)=NaN;
FX_Spot_EB(starteuro_spot:end,col_c)=NaN;

FX_Fwd(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EO(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EB(starteuro_fwd:end,col_c)=NaN;

for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'FRANCE')==1;code_imf=IMF_codes(j,1);end      
end
% Find the right series using its IMF code
col_c=find(FX_Spot(1,:)==code_imf);
% Replace national currencies with NaN after 1/1/1999
FX_Spot(starteuro_spot:end,col_c)=NaN;
FX_Spot_EO(starteuro_spot:end,col_c)=NaN;
FX_Spot_EB(starteuro_spot:end,col_c)=NaN;

FX_Fwd(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EO(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EB(starteuro_fwd:end,col_c)=NaN;


for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'ITALY')==1;code_imf=IMF_codes(j,1);end       
end
% Find the right series using its IMF code
col_c=find(FX_Spot(1,:)==code_imf);
% Replace national currencies with NaN after 1/1/1999
FX_Spot(starteuro_spot:end,col_c)=NaN;
FX_Spot_EO(starteuro_spot:end,col_c)=NaN;
FX_Spot_EB(starteuro_spot:end,col_c)=NaN;

FX_Fwd(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EO(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EB(starteuro_fwd:end,col_c)=NaN;


for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'BELGIUM')==1;code_imf=IMF_codes(j,1);end       
end
% Find the right series using its IMF code
col_c=find(FX_Spot(1,:)==code_imf);
% Replace national currencies with NaN after 1/1/1999
FX_Spot(starteuro_spot:end,col_c)=NaN;
FX_Spot_EO(starteuro_spot:end,col_c)=NaN;
FX_Spot_EB(starteuro_spot:end,col_c)=NaN;

FX_Fwd(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EO(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EB(starteuro_fwd:end,col_c)=NaN;


for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'NETHERLANDS')==1;code_imf=IMF_codes(j,1);end       
end
% Find the right series using its IMF code
col_c=find(FX_Spot(1,:)==code_imf);
% Replace national currencies with NaN after 1/1/1999
FX_Spot(starteuro_spot:end,col_c)=NaN;
FX_Spot_EO(starteuro_spot:end,col_c)=NaN;
FX_Spot_EB(starteuro_spot:end,col_c)=NaN;

FX_Fwd(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EO(starteuro_fwd:end,col_c)=NaN;
FX_Fwd_EB(starteuro_fwd:end,col_c)=NaN;





% ============================================= %
% GRAPHS
% ============================================= %
%There are 19 countries in the sample
show_graphs=1;

if show_graphs==1
    
    % FX Spot change
    figure('Name','Country by Country FX Spot Change  (in percentage points)');
    for k=1:size(FX_Spot,2)-1
        subplot(4,5,k);
        plot(FX_Spot(3:end,1),100*(FX_Spot(3:end,1+k)./FX_Spot(2:end-1,1+k)-1),'b');
        title(List_names(1+k,1));
        datetick('x',11)     
    end
 
    % FX Spot and FX Forward 
    figure('Name','Country by Country FX Spot and Forward');
    for k=1:size(FX_Spot,2)-1
        subplot(4,5,k);
        plot(FX_Fwd(2:end,1),FX_Fwd(2:end,1+k),'b');hold on;
        plot(FX_Spot(2:end,1),FX_Spot(2:end,1+k),'r');hold off;
        title(List_names(1+k,1));
        datetick('x',11)
    end
    legend('Forward','Spot');


    % One-Month Discount
    figure('Name','Country by Country One-Month Discount (in percentage points)');
    for k=1:size(FX_Spot,2)-1
        subplot(4,5,k);
        plot(FX_Fwd(2:end,1),100*(FX_Fwd(2:end,1+k)./FX_Spot(2:end,1+k)-1),'b');
        title(List_names(1+k,1));
        datetick('x',10)     
    end


    % Spread on FX Spot
    figure('Name','Country by Country Spread on FX Spot  (in percentage points)');
    for k=1:size(FX_Spot,2)-1
        subplot(4,5,k);
        plot(FX_Spot_EO(2:end,1),100*(FX_Spot_EO(2:end,1+k)-FX_Spot_EB(2:end,1+k))./FX_Spot_EB(2:end,1+k),'b');
        title(List_names(1+k,1));
        datetick('x',11)     
    end

    % Spread on FX Forward One-Month
    figure('Name','Country by Country Spread on FX Forward One-Month  (in percentage points)');
    for k=1:size(FX_Spot,2)-1
        subplot(4,5,k);
        plot(FX_Fwd_EO(2:end,1),100*(FX_Fwd_EO(2:end,1+k)-FX_Fwd_EB(2:end,1+k))./FX_Fwd_EB(2:end,1+k),'b');
        title(List_names(1+k,1));
        datetick('x',11)     
    end


end

% Summary Statistics:
FX_chge=NaN*zeros(size(FX_Spot,1),size(FX_Spot,2)-1);
for k=1:size(FX_Spot,2)-1
    FX_chge(3:end,k)=(FX_Spot(3:end,1+k)./FX_Spot(2:end-1,1+k)-1);
end
disp('Maximum change in spot rates');
max(FX_chge,[],1)
disp('Minimum change in spot rates');
min(FX_chge,[],1)

FX_fwddisc=NaN*zeros(size(FX_Spot,1),size(FX_Spot,2)-1);
for k=1:size(FX_Spot,2)-1
    FX_fwddisc(:,k)=FX_Fwd(:,1+k)./FX_Spot(:,1+k)-1;
end
disp('Maximum forward discount');
max(FX_fwddisc,[],1)
disp('Minimum forward discount');
min(FX_fwddisc,[],1)

Barclays_FX_Fwd_D      =  FX_Fwd;
Barclays_FX_Fwd_EO_D   =  FX_Fwd_EO;
Barclays_FX_Fwd_EB_D   =  FX_Fwd_EB;
Barclays_FX_Spot_D     =  FX_Spot;
Barclays_FX_Spot_EO_D  =  FX_Spot_EO;
Barclays_FX_Spot_EB_D  =  FX_Spot_EB;

% ============================================= %
% Extend Samples to End-of-Month
% ============================================= %
Barclays_FX_Spot_D       = Extend_EndofMonth(Barclays_FX_Spot_D);
Barclays_FX_Spot_EO_D    = Extend_EndofMonth(Barclays_FX_Spot_EO_D);
Barclays_FX_Spot_EB_D    = Extend_EndofMonth(Barclays_FX_Spot_EB_D);
Barclays_FX_Fwd_D        = Extend_EndofMonth(Barclays_FX_Fwd_D);
Barclays_FX_Fwd_EO_D     = Extend_EndofMonth(Barclays_FX_Fwd_EO_D);
Barclays_FX_Fwd_EB_D     = Extend_EndofMonth(Barclays_FX_Fwd_EB_D);


% ============================================= %
% SAVE .MAT
% ============================================= %
save(strcat(newpath,'Barclays_FX_Fwd_D.mat'),'Barclays_FX_Fwd_D');
save(strcat(newpath,'Barclays_FX_Fwd_EO_D.mat'),'Barclays_FX_Fwd_EO_D');
save(strcat(newpath,'Barclays_FX_Fwd_EB_D.mat'),'Barclays_FX_Fwd_EB_D');
save(strcat(newpath,'Barclays_FX_Spot_D.mat'),'Barclays_FX_Spot_D');
save(strcat(newpath,'Barclays_FX_Spot_EO_D.mat'),'Barclays_FX_Spot_EO_D');
save(strcat(newpath,'Barclays_FX_Spot_EB_D.mat'),'Barclays_FX_Spot_EB_D');
save(strcat(newpath,'Barclays_Countries.mat'),'List_names');




% ============================================= %
% SWITCH FREQUENCY TO MONTHLY
% ============================================= %
% Transform all series into end-of-the month series
NM=split(between(datetime(Barclays_FX_Spot_D(2,1),'ConvertFrom','datenum'),datetime(Barclays_FX_Spot_D(end,1),'ConvertFrom','datenum'), 'Months'), 'Months');
Barclays_Spot_M     = NaN*zeros(NM,size(Barclays_FX_Spot_D,2));
Barclays_Spot_EO_M  = NaN*zeros(NM,size(Barclays_FX_Spot_EO_D,2));
Barclays_Spot_EB_M  = NaN*zeros(NM,size(Barclays_FX_Spot_EB_D,2));
Barclays_Fwd_M      = NaN*zeros(NM,size(Barclays_FX_Fwd_D,2));
Barclays_Fwd_EO_M   = NaN*zeros(NM,size(Barclays_FX_Fwd_D,2));
Barclays_Fwd_EB_M   = NaN*zeros(NM,size(Barclays_FX_Fwd_D,2));

% Codes
Barclays_Spot_M(1,:)      = Barclays_FX_Spot_D(1,:);
Barclays_Spot_EO_M(1,:)   = Barclays_FX_Spot_EO_D(1,:);
Barclays_Spot_EB_M(1,:)   = Barclays_FX_Spot_EB_D(1,:);
Barclays_Fwd_M(1,:,:)     = Barclays_FX_Fwd_D(1,:,:);
Barclays_Fwd_EO_M(1,:,:)  = Barclays_FX_Fwd_EO_D(1,:,:);
Barclays_Fwd_EB_M(1,:,:)  = Barclays_FX_Fwd_EB_D(1,:,:);

% Data
k=2;
for t=2:size(Barclays_FX_Spot_D,1)-1
    datetime(Barclays_FX_Spot_D(t+1,1),'ConvertFrom','datenum');
    if month(datetime(Barclays_FX_Spot_D(t,1),'ConvertFrom','datenum'))~=month(datetime(Barclays_FX_Spot_D(t+1,1),'ConvertFrom','datenum')) % find end-of-month
        [N, S]=weekday(datetime(Barclays_FX_Spot_D(t,1),'ConvertFrom','datenum'));
        j=0;
        switch N
            case 1 % Sunday
                j=-2; % use Friday (two days earlier)
             case 7 % Saturday
                j=-1; % use Friday (one day earlier)
            case {2,3,4,5,6}
                j=0;
        end
        Barclays_Spot_M(k,:)       = Barclays_FX_Spot_D(t+j,:);
        Barclays_Spot_EO_M(k,:)    = Barclays_FX_Spot_EO_D(t+j,:);
        Barclays_Spot_EB_M(k,:)    = Barclays_FX_Spot_EB_D(t+j,:);
        Barclays_Fwd_M(k,:)      = Barclays_FX_Fwd_D(t+j,:);
        Barclays_Fwd_EO_M(k,:)   = Barclays_FX_Fwd_EO_D(t+j,:);
        Barclays_Fwd_EB_M(k,:)   = Barclays_FX_Fwd_EB_D(t+j,:);
        k=k+1;
    end
end


% ============================================= %
% BUILD MONTHLY SERIES OF EXCHANGE RATES VOLATILITY
% ============================================= %

% Build daily spot change
Barclays_Spot_D_chge=NaN*zeros(size(Barclays_FX_Spot_D));
Barclays_Spot_D_chge(:,1)=Barclays_FX_Spot_D(:,1);                                                          % Dates
Barclays_Spot_D_chge(1,:)=Barclays_FX_Spot_D(1,:);                                                          % IMF codes
Barclays_Spot_D_chge(3:end,2:end)=Barclays_FX_Spot_D(3:end,2:end)./Barclays_FX_Spot_D(2:end-1,2:end)-1;     % Spot change

% Build monthly spot change volatility
Barclays_Spot_M_vol=NaN*zeros(size(Barclays_Spot_M,1),size(Barclays_FX_Spot_D,2));
Barclays_Spot_M_vol(1,:)=Barclays_Spot_D_chge(1,:);                                                 % IMF codes
Barclays_Spot_M_vol(:,1)=Barclays_Spot_M(:,1);                                                      % Dates
% Volatility
% datetime(Barclays_Spot_M_vol(t,1),'ConvertFrom','datenum');
for t=3:size(Barclays_Spot_M_vol,1)
    rows_temp=find(month(datetime(Barclays_Spot_D_chge(:,1),'ConvertFrom','datenum'))==month(datetime(Barclays_Spot_M_vol(t,1),'ConvertFrom','datenum')) & ...
        year(datetime(Barclays_Spot_D_chge(:,1),'ConvertFrom','datenum'))==year(datetime(Barclays_Spot_M_vol(t,1),'ConvertFrom','datenum')));
    for k=2:size(Barclays_Spot_M_vol,2)
        if sum(isnan(Barclays_Spot_D_chge(rows_temp,k)))<size(Barclays_Spot_D_chge(rows_temp,k),1)
            Barclays_Spot_M_vol(t,k)=nanstd(Barclays_Spot_D_chge(rows_temp,k));
        else
            Barclays_Spot_M_vol(t,k)=NaN;
        end
    end
end

% Check
disp(' ');
disp('Annualized (x sqrt(12)) exchange rates volatility (in %): ');
disp(sqrt(12)*100*nanmean(Barclays_Spot_M_vol(2:end,2:end)));

% Save
save(strcat(newpath,'Barclays_Spot_M_vol.mat'),'Barclays_Spot_M_vol');

% ============================================= %
% SAVE .MAT
% ============================================= %

save(strcat(newpath,'Barclays_Fwd_dM.mat'),'Barclays_Fwd_M');
save(strcat(newpath,'Barclays_Fwd_EO_dM.mat'),'Barclays_Fwd_EO_M');
save(strcat(newpath,'Barclays_Fwd_EB_dM.mat'),'Barclays_Fwd_EB_M');
save(strcat(newpath,'Barclays_Spot_dM.mat'),'Barclays_Spot_M');
save(strcat(newpath,'Barclays_Spot_EO_dM.mat'),'Barclays_Spot_EO_M');
save(strcat(newpath,'Barclays_Spot_EB_dM.mat'),'Barclays_Spot_EB_M');
save(strcat(newpath,'List_names_Barclays.mat'),'List_names');
Barclays_Fwd_dM=Barclays_Fwd_M;
Barclays_Fwd_EO_dM=Barclays_Fwd_EO_M;
Barclays_Fwd_EB_dM=Barclays_Fwd_EB_M;
Barclays_Spot_dM=Barclays_Spot_M;
Barclays_Spot_EO_dM=Barclays_Spot_EO_M;
Barclays_Spot_EB_dM=Barclays_Spot_EB_M;


