%% parameters setup
clc
clearvars
close 

params = get_params_value();
frame_start = 1;
% set_frame_number = 900;
% frame_end = set_frame_number;
data_each_frame = params.samples*params.loop*params.Tx;
% rod_sequences = ["2019_09_29_onrd005", "2019_09_29_onrd006", "2019_09_29_onrd011", "2019_09_29_onrd013"];
rod_sequences = ["2019_04_09_bms1000", "2019_04_09_bms1001", "2019_04_09_bms1002", "2019_04_09_cms1002", "2019_04_09_pms1000", "2019_04_09_pms1001", "2019_04_09_pms2000", "2019_04_09_pms3000", "2019_04_30_mlms000", "2019_04_30_mlms001", "2019_04_30_mlms002", "2019_04_30_pbms002", "2019_04_30_pbms003", "2019_04_30_pcms001", "2019_04_30_pm2s003", "2019_04_30_pm2s004", "2019_05_09_bm1s008", "2019_05_09_cm1s004", "2019_05_09_mlms003", "2019_05_09_pbms004", "2019_05_09_pcms002", "2019_05_23_pm1s012", "2019_05_23_pm1s013", "2019_05_23_pm1s014", "2019_05_23_pm1s015", "2019_05_23_pm2s011", "2019_05_29_bcms000", "2019_05_29_bm1s016", "2019_05_29_bm1s017", "2019_05_29_mlms006", "2019_05_29_pbms007", "2019_05_29_pcms005", "2019_05_29_pm2s015", "2019_05_29_pm3s000", "2019_09_29_onrd001", "2019_09_29_onrd002", "2019_09_29_onrd005", "2019_09_29_onrd006", "2019_09_29_onrd011", "2019_09_29_onrd013"];

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
            save_det_base_dir = '/home/ray/Documents/results/cfar2';
            vis_save_dir = fullfile(save_det_base_dir, test_seq);
            save_det_file_name = strcat(test_seq, '.txt');
            save_det_dir = fullfile(save_det_base_dir, save_det_file_name);
            generate_ra_3dfft_function(params, data, frame_start, frame_end, data_each_frame, offset_num, save_det_dir, vis_save_dir);
        end
    end
end

%% test cfar

