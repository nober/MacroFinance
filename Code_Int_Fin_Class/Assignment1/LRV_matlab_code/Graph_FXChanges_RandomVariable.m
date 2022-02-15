% Graph for MBA presentation

% ============================================= %
% Clear
% ============================================= %
clc;
close all;
clear;

% ============================================= %
% Options
% ============================================= %

choose_frequency           = 2;
                          %1 = daily
                          %2 = monthly
                          
switch choose_frequency
    case 1
        date_begin                = datenum('1/29/2010');     
%         date_end                  = datenum('12/31/2010');       
%         date_end                  = datenum('6/28/2019');       
%         date_end                  = datenum('4/30/2020');       
%         date_end                  = datenum('7/31/2020');       
%         date_end                  = datenum('10/30/2020');       
        date_end                  = datenum('7/30/2021');       
    case 2
        date_begin                = datenum('11/30/1983');     
%         date_end                  = datenum('3/31/2015');       
%         date_end                  = datenum('6/28/2019');       
%         date_end                  = datenum('4/30/2020');       
%         date_end                  = datenum('7/31/2020');       
%         date_end                  = datenum('10/30/2020');       
        date_end                  = datenum('7/30/2021');       
end
                         
                          
% ============================================= %
% IMPORT DATA
% ============================================= %

if ismac
    newpath   =  strcat(pwd,'/ToUpdate/');
else
    newpath   =  strcat(pwd,'\ToUpdate\');
end


% ===============================
% Load currency data
% ===============================

switch choose_frequency
    case 1
        load(strcat(newpath,'BR_Fwd_D.mat'));                        %FX_Fwd
        FX_Fwd=BR_Fwd_D;
        load(strcat(newpath,'BR_Spot_D.mat'));                       %FX_Spot
        FX_Spot=BR_Spot_D;
    case 2
        load(strcat(newpath,'BR_Fwd_dM.mat'));                        %FX_Fwd
        FX_Fwd      = BR_Fwd_M;
        load(strcat(newpath,'BR_Spot_dM.mat'));                       %FX_Spot
        FX_Spot     = BR_Spot_M;
end


line_begin_spot                      = find(FX_Spot(:,1)==date_begin);
line_end_spot                        = find(FX_Spot(:,1)==date_end);
line_begin_fwd                       = find(FX_Fwd(:,1,1)==date_begin);
line_end_fwd                         = find(FX_Fwd(:,1,1)==date_end);

FX_spot_smple                        = FX_Spot(line_begin_spot:line_end_spot,:);
FX_Fwd_smple                         = FX_Fwd(line_begin_fwd:line_end_fwd,:,1);  % Keep only one-month forward   
        
FX_spot_chge_smple                   = zeros(size(FX_spot_smple));
FX_spot_chge_smple(:,1)              = FX_spot_smple(:,1);      % Dates in the first column
FX_spot_chge_smple(1,2:end)          = log(FX_Spot(line_begin_spot,2:end)./FX_Spot(line_begin_spot-1,2:end));   % initial value   
FX_spot_chge_smple(2:end,2:end)      = log(FX_spot_smple(2:end,2:end)./FX_spot_smple(1:end-1,2:end));    
Dates_curr_smple                     = FX_spot_chge_smple(:,1);

col_UK = find(FX_Spot(1,:)==112);
col_JP = find(FX_Spot(1,:)==158);
col_SW = find(FX_Spot(1,:)==146);
col_CN = find(FX_Spot(1,:)==156);

% ===============================
% Random numbers
% ===============================
rnd_mean = nanmean(FX_spot_chge_smple(:,col_UK));
rnd_std  = nanstd(FX_spot_chge_smple(:,col_UK));
rnd_size = size(FX_spot_chge_smple(:,col_UK),1);
RND      = random('Normal',rnd_mean,rnd_std,1,rnd_size);


% ============================================= %
% GRAPH DATA
% ============================================= %


switch choose_frequency
    case 1
        ylim_min = -0.03;  ylim_max = 0.03;
    case 2
        ylim_min = -0.2;  ylim_max = 0.2;
end

figure;
subplot(3,1,1); plot(FX_spot_chge_smple(:,1),FX_spot_chge_smple(:,col_UK),'r'); datetick; xlim([FX_spot_chge_smple(1,1)-50 FX_spot_chge_smple(end,1)+50]); ylim([ylim_min ylim_max]);grid on;%ylim([-0.15 0.15]);
subplot(3,1,2); plot(FX_spot_chge_smple(:,1),FX_spot_chge_smple(:,col_JP),'b'); datetick; xlim([FX_spot_chge_smple(1,1)-50  FX_spot_chge_smple(end,1)+50]); ylim([ylim_min ylim_max]);grid on;%ylim([-0.15 0.15]);
subplot(3,1,3); plot(FX_spot_chge_smple(:,1),RND,'k'); datetick; xlim([FX_spot_chge_smple(1,1)-50  FX_spot_chge_smple(end,1)+50]); ylim([ylim_min ylim_max]);grid on;%ylim([-0.15 0.15]);
switch choose_frequency
    case 1
        print('-depsc2','FXChge_UK_JP_D.eps');
    case 2
        print('-depsc2','FXChge_UK_JP_M.eps');
end
