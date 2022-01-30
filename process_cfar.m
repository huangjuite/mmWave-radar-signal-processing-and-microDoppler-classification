%% parameters setup
clc
clearvars
close 

params = get_params_value();
frame_start = 1;
% set_frame_number = 900;
% frame_end = set_frame_number;
data_each_frame = params.samples*params.loop*params.Tx;
rod_sequences = ["2019_09_29_onrd005", "2019_09_29_onrd006", "2019_09_29_onrd011", "2019_09_29_onrd013"];

%% file directory
base_dir = '/mnt/nas_crdataset';
dirs = dir(base_dir);
dir_names = [dirs.name];
%% organize directory
letterExp = '\d+_\d+_\d+';
names = {};
for i = 1:length(dirs)
    test = dirs(i);
    name = test.name;
    only_dates = regexp(name, letterExp);
    if only_dates == 1
        names(end+1) = {name};
    end
end
%% read the data file
% first_seq = names(1);
% first_seq = '2019_09_29';
% % test_seq = '2019_04_09_pms1000';
% test_seq = '2019_09_29_onrd001';
% rad_folder = 'rad_reo_zerf_h';
% offset_name = 'offset_num.txt';
% offset_path = fullfile(base_dir, first_seq, test_seq, offset_name);
% offset_file = fopen(offset_path, 'r');
% formatSpec = '%f';
% offset_num = fscanf(offset_file, formatSpec);
% file_path = fullfile(base_dir, first_seq, test_seq, rad_folder);
% data = readDCA1000(string(file_path), params.samples);
% data_length = length(data);
% Frame_num = data_length/data_each_frame;
% frame_start = offset_num;
% frame_end = Frame_num;


for i = 1:length(names)
    path_to_seqs = fullfile(base_dir, names(i));
    seqs = dir(string(path_to_seqs));
    for j = 1:length(seqs)
        if any(strcmp(rod_sequences, string(seqs(j).name)))
            first_seq = names(i);
%             first_seq = '2019_09_29';
            % test_seq = '2019_04_09_pms1000';
%             test_seq = '2019_09_29_onrd001';
            test_seq = string(seqs(j).name);
            disp(test_seq);
            rad_folder = 'rad_reo_zerf_h';
            rad_folder_alt = 'rad_reo_zerf';
            offset_name = 'offset_num.txt';
            offset_path = fullfile(base_dir, first_seq, test_seq, offset_name);
            offset_file = fopen(offset_path, 'r');
            formatSpec = '%f';
            offset_num = fscanf(offset_file, formatSpec);
            file_path = fullfile(base_dir, first_seq, test_seq, rad_folder);
            if ~exist(file_path, 'file')
                file_path = fullfile(base_dir, first_seq, test_seq, rad_folder_alt);
            end
            data = readDCA1000(string(file_path), params.samples);
            data_length = length(data);
            Frame_num = data_length/data_each_frame;
            frame_start = offset_num + 1;
            frame_end = Frame_num;
            save_det_base_dir = '/home/ray/Documents/results/cfar';
            save_det_file_name = strcat(test_seq, '.txt');
            save_det_dir = fullfile(save_det_base_dir, save_det_file_name);
            generate_ra_3dfft_function(params, data, frame_start, frame_end, data_each_frame, offset_num, save_det_dir);
        end
    end
end

%% test cfar

