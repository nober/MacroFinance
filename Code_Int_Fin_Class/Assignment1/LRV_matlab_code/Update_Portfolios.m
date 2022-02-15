% If you use the data requests and code below, 
% please cite "Common Risk Factors in Currency Markets" Hanno Lustig, Nikolai Roussanov, and Adrien Verdelhan, 
% Review of Financial Studies, November 2011, Vol. 24 (11), pp. 3731-3777


% To update the currency portfolios

% 1) Run the Datastream data requests

% DataRequests_Barclays_FW1F_D
% DataRequests_Barclays_SP_D
% DataRequests_Reuters_FR_D_since_31_12_2008
% DataRequests_Reuters_SP_D_since_12_31_2008
% DataRequests_MSCI_D
% DataRequests_MSCI_ReturnIndices_USDollars_D

% 2) Run the Matlab codes below to build portfolios of currency excess
% returns sorted by the level of short-term interest rates

ImportReutersData_Daily;
ImportBarclaysData_Daily;
Merge_Barclays_Reuters_D;
Import_USInterestrates_D;
Build_Portfolios_BarclaysData;
Build_Portfolios_BarclaysandReutersData;

% 3) Run the Matlab codes below to produce asset pricing estimations and
% graphs

ImportMSCIData_Daily;
Graph_AP_CarryPortfolios;
