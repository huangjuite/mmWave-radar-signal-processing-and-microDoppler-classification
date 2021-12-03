%% parameters
clc
clearvars
close all

params = get_params_value();
frame_start = 1;
% set_frame_number = 900;
% frame_end = set_frame_number;
data_each_frame = params.samples*params.loop*params.Tx;

%% file folders
folder_location = 'data/';
capture_files = ["2019_09_18_onrd004", "2019_05_28_pcms004", "2019_05_28_pm2s012", ...
    "2019_05_28_cm1s013", "2019_05_28_pbms006'", "2019_05_28_mlms005", "2019_09_18_onrd009",...
    "2019_05_28_pm2s014", "2019_10_13_onrd048", "2019_09_29_onrd012"];

%% read
for index = 1:length(capture_files)
    % generate file name and folder
    file_name = capture_files(index);
    file_location = strcat(folder_location,file_name,'/rad_reo_zerf/');
    
    
    %% read the data file
    data = readDCA1000(file_location, params.samples);
    data_length = length(data);
    Frame_num = data_length/data_each_frame;
    frame_end = Frame_num;
    
    % check whether Frame number is an integer
%     if Frame_num == set_frame_number
%         frame_end = Frame_num;
%     elseif abs(Frame_num - set_frame_number) < 30
%         fprintf('Error! Frame is not complete')
%         frame_start = set_frame_number - fix(Frame_num) + 1;
%         % zero fill the data
%         num_zerochirp_fill = set_frame_number*data_each_frame - data_length;
%         data_frames = [zeros(4,num_zerochirp_fill), data];
%     elseif abs(Frame_num - set_frame_number) >= 30 && Frame_num == fix(Frame_num)
%         frame_end = Frame_num;
%     else
%     end
    
    %% process
    velocity_map(data, frame_start, frame_end, params, file_name);
    
end