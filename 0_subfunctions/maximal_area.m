%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%      save the results as "dcm" format
%%
%%              is coded by Sunhee Kim,  6th May, 2015.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all;

%�¢¢¢¢� add path �¢¢¢¢�
nowDir = cd;
addpath(genpath(nowDir))

%�¢¢¢¢� data folder �¢¢¢¢�
% data_folder_name = '02_KO_HEUNGYOUNG';
% data_folder_name = '03_KWAK_BYEONGDO';
% data_folder_name = '07_YANG_KEUMJU';
% data_folder_name = '10_YOON_SEONRYE';
data_folder_name = '13_CHO_KYUSIK';
dataDir    = sprintf('../../Data/Data5/%s',data_folder_name);

file_list = dir(dataDir);
addpath(dataDir);

%�¢¢¢¢� load results �¢¢¢¢�
load(sprintf('%s.mat',data_folder_name));

arrArea = zeros(1,nDims);
for frame = 1:nDims
    S = supraspinatus_smoothing3D_org(:,:,frame);
    arrArea(frame) = sum(S(:)>0);
end
figure, plot(arrArea)
nDims
[~,max_frame] = max(arrArea)