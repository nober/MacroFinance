% ==================================================== %
% IMPORT REUTERS DAILY DATA
% ==================================================== %
% Program : 
% 1 ) Import daily data on spot and forward exchange rates,
% 2 ) Select subsample of countries,
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
% Import REUTERS FORWARD RATES UNTIL 12/31/2008
% ============================================= %
% Source: Datastream

% Import one-month forward exchange rates
% Daily data starting 12/31/1996

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.

temp=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_until_31_12_2008.xlsm'),'Sheet1');
s   =size(temp);
FX_Fwd_temp1   =zeros(s(1),s(2));
FX_Fwd_EB_temp1=zeros(s(1),s(2));
FX_Fwd_EO_temp1=zeros(s(1),s(2));

FX_Fwd_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_until_31_12_2008.xlsm'),'Sheet1');       % one-month
FX_Fwd_EB_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_until_31_12_2008.xlsm'),'Sheet2');
FX_Fwd_EO_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_until_31_12_2008.xlsm'),'Sheet3');

% Matlab dates
FX_Fwd_temp1(:,1)=FX_Fwd_temp1(:,1)+693960;
FX_Fwd_EB_temp1(:,1)=FX_Fwd_EB_temp1(:,1)+693960;
FX_Fwd_EO_temp1(:,1)=FX_Fwd_EO_temp1(:,1)+693960;



% ============================================= %
% Import REUTERS FORWARD RATES SINCE 12/31/2008
% ============================================= %
% Source: Datastream

% Import one-month forward exchange rates
% Daily data starting 12/31/1996 

% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.
temp=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_since_31_12_2008.xlsm'),'Sheet1');
s=size(temp);
FX_Fwd_temp2    =zeros(s(1),s(2));
FX_Fwd_EB_temp2=zeros(s(1),s(2));
FX_Fwd_EO_temp2=zeros(s(1),s(2));

FX_Fwd_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_since_31_12_2008.xlsm'),'Sheet1');       % one-month
FX_Fwd_EB_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_since_31_12_2008.xlsm'),'Sheet2');
FX_Fwd_EO_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_FR_D_since_31_12_2008.xlsm'),'Sheet3');

% Matlab dates
FX_Fwd_temp2(:,1)=FX_Fwd_temp2(:,1)+693960;
FX_Fwd_EB_temp2(:,1)=FX_Fwd_EB_temp2(:,1)+693960;
FX_Fwd_EO_temp2(:,1)=FX_Fwd_EO_temp2(:,1)+693960;


% Insert IMF codes in the first lines:
IMF_codes_Fwd=[NaN 466 122	193	124	156	146	935	134	128	163	184	172	132	112	174	532	536	178	136	158	443	273	548	138	142	186	528	199	944	534	964	576	578	196	542	566	182	456];
FX_Fwd=zeros(size(FX_Fwd_temp1,1)+size(FX_Fwd_temp2,1),size(FX_Fwd_temp1,2));
FX_Fwd_EB=zeros(size(FX_Fwd_EB_temp1,1)+size(FX_Fwd_EB_temp2,1),size(FX_Fwd_EB_temp1,2));
FX_Fwd_EO=zeros(size(FX_Fwd_EO_temp1,1)+size(FX_Fwd_EO_temp2,1),size(FX_Fwd_EO_temp1,2));

FX_Fwd(:,:)=[IMF_codes_Fwd;FX_Fwd_temp1(:,:);FX_Fwd_temp2(2:end,:)];
FX_Fwd_EB(:,:)=[IMF_codes_Fwd;FX_Fwd_EB_temp1(:,:);FX_Fwd_EB_temp2(2:end,:)];
FX_Fwd_EO(:,:)=[IMF_codes_Fwd;FX_Fwd_EO_temp1(:,:);FX_Fwd_EO_temp2(2:end,:)];



% ============================================= %
% Import REUTERS SPOT RATES 
% ============================================= %
% Source: DataRequestsstream
% For Matlab 7 to be able to recognize the first column of dates, its
% format needs to be set to "Number (with 0 decimals)" in Excel before
% importing to Matlab.

temp=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_until_12_31_2008.xlsm'),'Sheet1');
s=size(temp);
Dates1=temp(:,1,1)+693960;
FX_Spot_temp1=zeros(s(1),s(2));
FX_Spot_EB_temp1=zeros(s(1),s(2));
FX_Spot_EO_temp1=zeros(s(1),s(2));
FX_Spot_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_until_12_31_2008.xlsm'),'Sheet1');
FX_Spot_EB_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_until_12_31_2008.xlsm'),'Sheet2');
FX_Spot_EO_temp1(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_until_12_31_2008.xlsm'),'Sheet3');

temp=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_since_12_31_2008.xlsm'),'Sheet1');
s=size(temp);
Dates2=temp(:,1,1)+693960;
FX_Spot_temp2=zeros(s(1),s(2));
FX_Spot_EB_temp2=zeros(s(1),s(2));
FX_Spot_EO_temp2=zeros(s(1),s(2));
FX_Spot_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_since_12_31_2008.xlsm'),'Sheet1');
FX_Spot_EB_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_since_12_31_2008.xlsm'),'Sheet2');
FX_Spot_EO_temp2(:,:)=xlsread(strcat(newpath,'DataRequests_Reuters_SP_D_since_12_31_2008.xlsm'),'Sheet3');

Dates           = [Dates1;Dates2(2:end,:)];
FX_Spot_temp    = [FX_Spot_temp1;FX_Spot_temp2(2:end,:)];
FX_Spot_EB_temp = [FX_Spot_EB_temp1;FX_Spot_EB_temp2(2:end,:)];
FX_Spot_EO_temp = [FX_Spot_EO_temp1;FX_Spot_EO_temp2(2:end,:)];

% Matlab dates
FX_Spot_temp(:,1)=FX_Spot_temp(:,1)+693960;
FX_Spot_EB_temp(:,1)=FX_Spot_EB_temp(:,1)+693960;
FX_Spot_EO_temp(:,1)=FX_Spot_EO_temp(:,1)+693960;

% Currencies: ALBANIAN LEK TO US $ (WMR 914); ALGERIAN DINAR TO US $ (WMR 612 ); ARGENTINE PESO TO US $ (WMR 213)
% US $ TO AUSTRALIAN $ (WMR 193 ); AUSTRIAN SCHIL.TO US $ (WMR 122);	BAHRAINI DINAR TO US $ (WMR 419);
% BANGLADESH TAKA TO US $ (WMR 513); BELGIAN FRANC TO US $ (WMR 124); BERMUDA $ TO US $ (WMR 66666); 
% BOLIVIAN BOLIVIANO TO US $ (WMR 218);	US $ TO BOTSWANA PULA (WMR 616); BRAZILIAN REAL TO US $ (WMR 223)
% BRUNEI $ TO US $ (WMR 516); BULGARIAN LEV TO US $ (WMR 918); BURUNDI FRANC TO US $ (WMR 618);
% CANADIAN $ TO US $ (WMR 156);	CHILEAN PESO TO US $ (WMR 228);	CHINESE YUAN TO US $ (WMR 924);
% COLOMBIAN PESO TO US $ (WMR 233);	COTE D'IVRE CFA.FR. TO US $ (WMR 662); CROATIAN KUNA TO US $ (WMR 960);
% CYPRUS £ TO US $ (WMR 423); CZECH KORUNA TO US $ (WMR 935); DANISH KRONE TO US $ (WMR 128); US $ TO ECU/EURO (WMR 163);
% ECUADOR SUCRE TO US $ (WMR 248); EGYPTIAN £ TO US $ (WMR 469); ESTONIAN KROON TO US $ (WMR 939); FINNISH MARKKA TO US $ (WMR 172);
% FIJIAN $ TO US $ (WMR 819); FRENCH FRANC TO US $ (WMR 132); GAMBIAN DALASI TO US $ (WMR 648); GERMAN MARK TO US $ (WMR 134);
% GHANAIAN CEDI TO US $ (WMR 652); GREEK DRACHMA TO US $ (WMR 174);	GUINEA FRANC TO US $ (WMR 656);	HONG KONG $ TO US $ (WMR 532);
% HUNGARIAN FORINT TO US $ (WMR 944); ICELANDIC KRONA TO US $ (WMR 176); INDIAN RUPEE TO US $ (WMR 534);
% INDONESIAN RUPIAH TO US $ (WMR 536); US $ TO IRISH PUNT (WMR 178); ISRAELI SHEKEL TO US $ (WMR 436); ITALIAN LIRA TO US $ (WMR 136);
% JAPANESE YEN TO US $ (WMR 158); JORDANIAN DINAR TO US $ (WMR 439); KAZAKHSTAN TENGE TO US $ (WMR 916); 
% KENYAN SHILLING TO US $ (WMR 664); KUWAITI DINAR TO US $ (WMR 443); LATVIAN LAT TO US $ (WMR 941); LEBANESE £ TO US $ (WMR 446);
% LITHUANIAN LITA TO US $ (WMR 946); LUXEMBOURG FRANC TO US $ (WMR 137); MALAWIAN KWACHA TO US $ (WMR 676);
% MALAYSIAN RINGGIT TO US $ (WMR 548); MALTESE LIRA TO US $ (WMR 181); MAURITANIAN OUGUYIA TO US $ (WMR 682);
% MEXICAN PESO TO US $ (WMR 273); MOROCCAN DIRHAM TO US $ (WMR 686); MOZAMBIQUE METICAL TO US $ (WMR 688);
% NETH. GUILDER TO US $ (WMR 138); US $ TO NEW ZEALAND $ (WMR 196); NIGERIAN NAIRA TO US $ (WMR 694);
% NORWEGIAN KRONE TO US $ (WMR 142); OMAN RIAL TO US $ (WMR 449); PAKISTAN RUPEE TO US $ (WMR 564); 
% NEW GUINEA KINA TO US $ (WMR 853); PARAGUAY GUARANI TO US $ (WMR 288); PERUVIAN NUEVO SOL TO US $ (WMR 293);
% PHILIPPINE PESO TO US $ (WMR 566); POLISH ZLOTY TO US $ (WMR 964); PORTUGUESE ESCUDO TO US $ (WMR 182);
% QATARI RIAL TO US $ (WMR 453); NEW ROMANIAN LEU TO US $ (WMR 968); CIS ROUBLE (MARKET) TO US $ (WMR 922);
% SAUDI RIYAL TO US $ (WMR 486); SINGAPORE $ TO US $ (WMR 576); SLOVENIAN TOLAR TO US $ (WMR 961); 
% SOUTH AFRICA RAND TO US $ (WMR 199); SOUTH KOREAN WON TO US $ (WMR 542); SPANISH PESETA TO US $ (WMR 184);
% SDR TO US $ (WMR); SRI LANKAN RUPEE TO US $ (WMR 524); SWEDISH KRONA TO US $ (WMR 144); SWISS FRANC TO US $ (WMR 146);
% TAIWAN NEW $ TO US $ (WMR 528); THAI BAHT TO US $ (WMR 578); TUNISIAN DINAR TO US $ (WMR 744); 
% NEW TURKISH LIRA TO US $ (WMR 186); UAE DIRHAM TO US $ (WMR 466); UGANDA NEW SHILLING TO US $ (WMR 746);
% UKRAINE HRYVNIA TO US $ (WMR 926); URUGUAYAN PESO TO US $ (WMR 298); VANUATU VATU TO US $ (WMR 846);
% VENEZUELAN BOLIVAR TO US $ (WMR 299); VIETNAMESE DONG TO US $ (WMR 582); ZAMBIAN KWACHA TO US $ (WMR 754);
% ZIMBABWE $ TO US $ (WMR 698); US $ TO UK £ (WMR 112).

% Insert IMF codes in the first line:
IMF_codes_spot_Reuters=[NaN 914 612 213 193 122 419 513 124 66666 218 616 223 516 918 618 156 228 924 ...
    233 662 960 423 935 128 163 248 469 939 172 819 132 648 134 652 174 656 532 944 176 534 ...
    536 178 436 136 158 439 916 664 443 941 446 946 137 676 548 181 682 273 686 688 138 196 694 ...
    142 449 564 853 288 293 566 964 182 453 968 922 456 576 961 199 542 184 NaN 524 144 146 528 578 744 ...
    186 466 746 926 298 846 299 582 754 698 112];   
FX_Spot=[IMF_codes_spot_Reuters;FX_Spot_temp];
FX_Spot_EB=[IMF_codes_spot_Reuters;FX_Spot_EB_temp];
FX_Spot_EO=[IMF_codes_spot_Reuters;FX_Spot_EO_temp];


% ============================================= %
% EXCHANGE RATE UNITS
% ============================================= %
% FX Forward and spot data are in units of foreign currency per USD (Ex: 1 USD = 5.19 FF), 
% except for Australian Dollar (193), Botswana (616), Euro (163), UK (112), New Zealand Dollar (196), Irish Punt (178) 
% Write all forward and spot data in foreign currency per USD
for i=2:size(FX_Spot,2)
    if FX_Spot(1,i)==193 || FX_Spot(1,i)==616 || FX_Spot(1,i)==163 || FX_Spot(1,i)==112 || FX_Spot(1,i)==196 || FX_Spot(1,i)==178
         FX_Spot(2:end,i)=ones(size(FX_Spot,1)-1,1)./FX_Spot(2:end,i);
         % Switch the bid and offered rate (so that the spread remains positive)
         FX_Spot_EO_temp=FX_Spot_EO(2:end,i);
         FX_Spot_EB_temp=FX_Spot_EB(2:end,i);
         FX_Spot_EB(2:end,i)=ones(size(FX_Spot_EO,1)-1,1)./FX_Spot_EO_temp;
         FX_Spot_EO(2:end,i)=ones(size(FX_Spot_EB,1)-1,1)./FX_Spot_EB_temp;
    end
end


for i=2:size(FX_Fwd,2)
    if FX_Fwd(1,i)==193 || FX_Fwd(1,i)==616 || FX_Fwd(1,i)==163 || FX_Fwd(1,i)==112 || FX_Fwd(1,i)==196 || FX_Fwd(1,i)==178
        
            FX_Fwd(2:end,i)=ones(size(FX_Fwd,1)-1,1)./FX_Fwd(2:end,i);
            FX_Fwd_EO_temp=FX_Fwd_EO(2:end,i);
            FX_Fwd_EB_temp=FX_Fwd_EB(2:end,i);
            % Switch the bid and offered rate (so that the spread remains positive)
            FX_Fwd_EB(2:end,i)=ones(size(FX_Fwd_EB,1)-1,1)./FX_Fwd_EO_temp;
            FX_Fwd_EO(2:end,i)=ones(size(FX_Fwd_EO,1)-1,1)./FX_Fwd_EB_temp;
        
    end
end

% ============================================= %
% EURO
% ============================================= %
delete_euro_countries=1;

if delete_euro_countries==1
    % After 12/31/1998, keep only euro data, write NaN for the euro countries
    euro_begin=datenum('01/29/1999');
    euro_line=find(FX_Spot(:,1)==euro_begin);
    % Euro area countries: Belgium (124), Germany (134), Greece (174), Spain (184), France (132), Ireland (178),
    % Italy (136), Luxembourg (137), Netherlands (138), Austria (122), Portugal (182), Finland (172)
    % Euro area (163)
    for i=2:size(FX_Spot,2)
        if FX_Spot(1,i)==124 || FX_Spot(1,i)==134 || FX_Spot(1,i)==184 || FX_Spot(1,i)==132 ||...
                FX_Spot(1,i)==178 || FX_Spot(1,i)==136 || FX_Spot(1,i)==137 || FX_Spot(1,i)==138 ||...
                FX_Spot(1,i)==122 || FX_Spot(1,i)==182 || FX_Spot(1,i)==172 
            for k=1:size(FX_Spot,1)
                if k>=euro_line
                    FX_Spot(k,i)=NaN;
                    FX_Spot_EB(k,i)=NaN;
                    FX_Spot_EO(k,i)=NaN;
                end
            end
        end
        if FX_Spot(1,i)==163
            for k=2:size(FX_Spot,1)
                if k<euro_line
                    FX_Spot(k,i)=NaN;
                    FX_Spot_EB(k,i)=NaN;
                    FX_Spot_EO(k,i)=NaN;
                end
            end
        end
    end

    greece_begin=datenum('01/31/2001');
    greece_line=find(FX_Spot(:,1)==euro_begin);
    greece_col=find(FX_Spot(1,:)==174);
    for k=1:size(FX_Spot,1)
        if k>=greece_line
            FX_Spot(k,greece_col)=NaN;
            FX_Spot_EB(k,greece_col)=NaN;
            FX_Spot_EO(k,greece_col)=NaN;
        end
    end
    
end


% ============================================= %
% SELECT COUNTRIES
% ============================================= %
FX_Spot_temp=zeros(size(FX_Spot,1),size(FX_Fwd,2));
FX_Spot_EO_temp=zeros(size(FX_Spot,1),size(FX_Fwd,2));
FX_Spot_EB_temp=zeros(size(FX_Spot,1),size(FX_Fwd,2));
FX_Spot_temp(:,1)=FX_Spot(:,1);
FX_Spot_EO_temp(:,1)=FX_Spot(:,1);
FX_Spot_EB_temp(:,1)=FX_Spot(:,1);

FX_Fwd_temp=zeros(size(FX_Fwd));
FX_Fwd_EO_temp=zeros(size(FX_Fwd));
FX_Fwd_EB_temp=zeros(size(FX_Fwd));
FX_Fwd_temp(:,1)=FX_Fwd(:,1);
FX_Fwd_EO_temp(:,1)=FX_Fwd(:,1);
FX_Fwd_EB_temp(:,1)=FX_Fwd(:,1);

j=2;
for i=2:size(FX_Fwd,2)
    
    % Keep only countries for which we have both forward and spot exchange rates
    col=find(FX_Spot(1,:)==FX_Fwd(1,i,1));
    
    % Get rid of the following countries:

    % United Arab Emirates (466), Saudi Arabia (456), Turkey (186), Taiwan (528), Malaysia (548)
    %list_weird_countries_codes=[466,456,186,528,548];
    % United Arab Emirates (466), Saudi Arabia (456), Turkey (186), Malaysia (548)
    %list_weird_countries_codes=[466,456,186,548];
    %  Saudi Arabia (456), Malaysia (548)
    %list_weird_countries_codes=[456,548];
    %  Turkey (186)
    %list_weird_countries_codes=186;
    
    list_weird_countries_codes=[];
    
    index_weird_countries=find(list_weird_countries_codes==FX_Fwd(1,i,1));

    if isempty(col)==0 && isempty(index_weird_countries)==1
        FX_Spot_temp(:,j)=FX_Spot(:,col);
        FX_Spot_EO_temp(:,j)=FX_Spot_EO(:,col);
        FX_Spot_EB_temp(:,j)=FX_Spot_EB(:,col);
        FX_Fwd_temp(:,j,:)=FX_Fwd(:,i,:);
        FX_Fwd_EO_temp(:,j)=FX_Fwd_EO(:,i);
        FX_Fwd_EB_temp(:,j)=FX_Fwd_EB(:,i);
        j=j+1;
    end
       
end

FX_Fwd_sample=FX_Fwd_temp(:,1:j-1);
FX_Fwd_EO_sample=FX_Fwd_EO_temp(:,1:j-1);
FX_Fwd_EB_sample=FX_Fwd_EB_temp(:,1:j-1);
FX_Spot_sample=FX_Spot_temp(:,1:j-1);
FX_Spot_EO_sample=FX_Spot_EO_temp(:,1:j-1);
FX_Spot_EB_sample=FX_Spot_EB_temp(:,1:j-1);

% ============================================= %
% FIND COUNTRIES' NAMES
% ============================================= %
[IMF_codes, IMF_names]=xlsread('IMF_codes.xls');
List_names=cell(size(FX_Spot_sample,2)-1,1);

for i=2:size(FX_Spot_sample,2)
    row=find(IMF_codes(:,1)==FX_Spot_sample(1,i));
    List_names(i,1)=IMF_names(row,1);
end


% ============================================= %
% OUTLIERS
% ============================================= %

% ---------        
% France
% ---------
% There is one outlier in the French series, on october 12th, 1998
% Look for the IMF code of France
for j=1:size(IMF_names,1)
   if strcmp(IMF_names(j,1),'FRANCE')==1
      code_imf=IMF_codes(j,1);
   end     
end
% Find the right series using its IMF code
c=find(FX_Spot_EB_sample(1,:)==code_imf);
% Find the date
cc=find(FX_Spot_EB_sample(:,1)==datenum('10/12/1998'));
% Replace the wrong value
FX_Spot_EB_sample(cc,c)=(FX_Spot_EB_sample(cc-1,c)+FX_Spot_EB_sample(cc+1,c))/2;


% ---------        
% Indonesia
% ---------
% Find the right series using its IMF code
col_IND     = find(FX_Fwd_sample(1,:)==536);
start_weird = find(FX_Fwd_sample(:,1) == datenum('29-Dec-2000'));
end_weird   = find(FX_Fwd_sample(:,1) == datenum('31-May-2007'));

FX_Fwd_sample(start_weird+1:end_weird,col_IND)=NaN;                          
FX_Fwd_EO_sample(start_weird+1:end_weird,col_IND)=NaN;                        
FX_Fwd_EB_sample(start_weird+1:end_weird,col_IND)=NaN;                        


% ---------        
% South Africa
% ---------
% Find the right series using its IMF code
col_ZAF     = find(FX_Fwd_sample(1,:)==199);
start_weird = find(FX_Fwd_sample(:,1) == datenum('31-Jul-1985'));
end_weird = find(FX_Fwd_sample(:,1) == datenum('30-Aug-1985'));

FX_Fwd_sample(start_weird+1:end_weird,col_ZAF)=NaN;                                     
FX_Fwd_EO_sample(start_weird+1:end_weird,col_ZAF)=NaN;                                  
FX_Fwd_EB_sample(start_weird+1:end_weird,col_ZAF)=NaN;                                  



% ---------        
% Turkey
% ---------
% Find the right series using its IMF code
col_TKY     = find(FX_Fwd_sample(1,:,1)==186);
start_weird = find(FX_Fwd_sample(:,1,1) == datenum('31-Oct-2000'));
end_weird = find(FX_Fwd_sample(:,1,1) == datenum('30-Nov-2001'));

FX_Fwd_sample(start_weird+1:end_weird,col_TKY)=NaN;                                     
FX_Fwd_EO_sample(start_weird+1:end_weird,col_TKY)=NaN;                                  
FX_Fwd_EB_sample(start_weird+1:end_weird,col_TKY)=NaN;                                  


% ---------        
% Malaysia
% ---------
% Find the right series using its IMF code
col_MAL     = find(FX_Fwd_sample(1,:,1)==548);
start_weird = find(FX_Fwd_sample(:,1,1) == datenum('31-Aug-1998'));
end_weird = find(FX_Fwd_sample(:,1,1) == datenum('30-Jun-2005'));

FX_Fwd_sample(start_weird+1:end_weird,col_MAL)=NaN;                                     
FX_Fwd_EO_sample(start_weird+1:end_weird,col_MAL)=NaN;                                  
FX_Fwd_EB_sample(start_weird+1:end_weird,col_MAL)=NaN;                                  


% ---------        
% United Arab Emirates (466)
% ---------
% Find the right series using its IMF code
col_UAE     = find(FX_Fwd_sample(1,:,1)==466);
start_weird = find(FX_Fwd_sample(:,1,1) == datenum('30-Jun-2006'));
end_weird = find(FX_Fwd_sample(:,1,1) == datenum('30-Nov-2006'));

FX_Fwd_sample(start_weird+1:end_weird,col_UAE)=NaN;                                     
FX_Fwd_EO_sample(start_weird+1:end_weird,col_UAE)=NaN;                                  
FX_Fwd_EB_sample(start_weird+1:end_weird,col_UAE)=NaN;                                 



% ============================================= %
% GRAPHS
% ============================================= %
%There are 45 countries in the sample
show_graphs=1;

if show_graphs==1
    
    % FX Spot change
    figure('Name','Country by Country FX Spot Change  (in percentage points)');
    for k=1:size(FX_Spot_sample,2)-1
        subplot(5,8,k);
        plot(FX_Spot_sample(3:end,1),100*(FX_Spot_sample(3:end,1+k)./FX_Spot_sample(2:end-1,1+k)-1),'b');
        title(List_names(1+k,1));
        datetick('x',11)     
    end

 
    % FX Spot and FX Forward One-Month
    figure('Name','Country by Country FX Spot and One-Month Forward');
    for k=1:size(FX_Spot_sample,2)-1
        subplot(5,8,k);
        plot(FX_Fwd_sample(2:end,1),FX_Fwd_sample(2:end,1+k),'b');hold on;
        plot(FX_Spot_sample(2:end,1),FX_Spot_sample(2:end,1+k),'r');hold off;
        title(List_names(1+k,1));
        datetick('x',11)    
    end

    
    % One-Month Discount
    figure('Name','Country by Country One-Month Discount (in percentage points)');
    for k=1:size(FX_Spot_sample,2)-1
        subplot(5,8,k);
        plot(FX_Fwd_sample(:,1),100*(FX_Fwd_sample(:,1+k)./FX_Spot_sample(:,1+k)-1),'b');
        title(List_names(1+k,1));
        datetick('x',10)     
    end
 
end


% Summary Statistics:
FX_chge=NaN*zeros(size(FX_Spot_sample,1),size(FX_Spot_sample,2)-1);
for k=1:size(FX_Spot_sample,2)-1
    FX_chge(3:end,k)=(FX_Spot_sample(3:end,1+k)./FX_Spot_sample(2:end-1,1+k)-1);
end
disp('Maximum change in spot rates');
max(FX_chge,[],1)
disp('Minimum change in spot rates');
min(FX_chge,[],1)

FX_fwddisc=NaN*zeros(size(FX_Spot_sample,1),size(FX_Spot_sample,2)-1);
for k=1:size(FX_Spot_sample,2)-1
    FX_fwddisc(:,k)=FX_Fwd_sample(:,1+k)./FX_Spot_sample(:,1+k)-1;
end
disp('Maximum forward discount');
max(FX_fwddisc,[],1)
disp('Minimum forward discount');
min(FX_fwddisc,[],1)


% ============================================= %
% SAVE .MAT
% ============================================= %
save(strcat(newpath,'Reuters_FX_Fwd_D.mat'),'FX_Fwd_sample');
save(strcat(newpath,'Reuters_FX_Fwd_EO_D.mat'),'FX_Fwd_EO_sample');
save(strcat(newpath,'Reuters_FX_Fwd_EB_D.mat'),'FX_Fwd_EB_sample');
save(strcat(newpath,'Reuters_FX_Spot_D.mat'),'FX_Spot_sample');
save(strcat(newpath,'Reuters_FX_Spot_EO_D.mat'),'FX_Spot_EO_sample');
save(strcat(newpath,'Reuters_FX_Spot_EB_D.mat'),'FX_Spot_EB_sample');
save(strcat(newpath,'Reuters_Countries_D.mat'),'List_names');

