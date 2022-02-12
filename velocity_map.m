%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used for processing the raw data collectd by TI awr1843
% radar
% Author : Xiangyu Gao (xygao@uw.edu), University of Washingyton
% Input: raw I-Q radar data
% Output: range-angle (RA) image, 3D point clouds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% specify data name and load data as variable data_frames
%seq_name = 'pms1000_30fs.mat';
%seq_dir = strcat('./template data/', seq_name);
%load(seq_dir); % load data as variable data_frames

function tmp = velocity_map(data_frames,frame_start,frame_end, params, name)
    % constant parameters
    c = params.c; % Speed of light in air (m/s)
    fc = params.fc; % Center frequency (Hz)
    lambda = params.lambda;
    Rx = params.Rx;
    Tx = params.Tx;

    % configuration parameters
    Fs = params.Fs;
    sweepSlope = params.sweepSlope;
    samples = params.samples;
    loop = params.loop;

    Tc = params.Tc; % us 
    fft_Rang = params.fft_Rang;
    fft_Vel = params.fft_Vel;
    fft_Ang = params.fft_Ang;
    num_crop = params.num_crop;
    max_value = params.max_value; % normalization the maximum of data WITH 1843

    % Creat grid table
    rng_grid = params.rng_grid;
    agl_grid = params.agl_grid;
    vel_grid = params.vel_grid;

    % Algorithm parameters
    data_each_frame = samples*loop*Tx;
    Is_Windowed = 1;% 1==> Windowing before doing range and angle fft
    Is_plot_rangeDop = 1;
    
    saved_fig_folder_name = strcat('/mnt/nas_crdataset2/rodnet/speed_data/',name,'/vis/');
    saved_mat_folder_name = strcat('/mnt/nas_crdataset2/rodnet/speed_data/',name,'/mat/');
    if ~exist(saved_fig_folder_name, 'dir') % check the folder exist
        mkdir(saved_fig_folder_name);
        sp_folder = strcat(saved_fig_folder_name, 'speed');
        mkdir(sp_folder);
    end
    if ~exist(saved_mat_folder_name, 'dir') % check the folder exist
        mkdir(saved_mat_folder_name);
    end
    
    for i = frame_start:frame_end
        % read the data of each frame, and then arrange for each chirps
        data_frame = data_frames(:, (i-1)*data_each_frame+1:i*data_each_frame);
        data_chirp = [];
        for cj = 1:Tx*loop
            temp_data = data_frame(:, (cj-1)*samples+1:cj*samples);
            data_chirp(:,:,cj) = temp_data;
        end
        
        % separate the odd-index chirps and even-index chirps for TDM-MIMO with 2 TXs
        chirp_odd = data_chirp(:,:,1:2:end);
        chirp_even = data_chirp(:,:,2:2:end);

        % permutation with the format [samples, Rx, chirp]
        chirp_odd = permute(chirp_odd, [2,1,3]);
        chirp_even = permute(chirp_even, [2,1,3]);
        
        % Range FFT for odd chirps
        [Rangedata_odd] = fft_range(chirp_odd,fft_Rang,Is_Windowed);

        % Range FFT for even chirps
        [Rangedata_even] = fft_range(chirp_even,fft_Rang,Is_Windowed);

        % Doppler FFT
        Dopplerdata_odd = fft_doppler(Rangedata_odd, fft_Vel, 0);
        Dopplerdata_even = fft_doppler(Rangedata_even, fft_Vel, 0);
        Doppler_merge = [Dopplerdata_odd, Dopplerdata_even];
        Dopdata = fft_angle(Doppler_merge, fft_Ang, Is_Windowed);
        Dopdata_crop = Dopdata(num_crop+1:fft_Rang-num_crop, :, :);
        mat_name = strcat(saved_mat_folder_name,'frame_',num2str(i-1,'%06d'),'.mat');
        save(mat_name, 'Dopdata_crop');
        disp(mat_name);
        
        save_SP = 0;
        if save_SP
            thresh = 2e5;
            [M, sp] = max(Dopdata_crop,[],3);
            mag = abs(M);
            mag(mag>thresh) = thresh;
            mag = mag./thresh;
            sp=(sp-128)./128.*mag;
            [axh] = plot_speed(sp,rng_grid(num_crop+1:fft_Rang-num_crop),agl_grid);
            saved_fig_file_name = strcat(saved_fig_folder_name,'speed','/frame_',num2str(i-1,'%06d'),'.png');
            saveas(axh,saved_fig_file_name,'png');
        end
        
        save_RA = 0;
        if save_RA
            Rangedata_merge = [Rangedata_odd, Rangedata_even];
            % Angle FFT
            Angdata = fft_angle(Rangedata_merge,fft_Ang,Is_Windowed);
            Angdata_crop = Angdata(num_crop + 1:fft_Rang - num_crop, :, :);
            Angdata_crop = Normalize(Angdata_crop, max_value);

            % Plot range-angle (RA) image
            [axh] = plot_rangeAng(Angdata_crop,rng_grid(num_crop+1:fft_Rang-num_crop),agl_grid);
            saved_fig_file_name = strcat(saved_fig_folder_name,'pos','/frame_',num2str(i-1,'%06d'),'.png');
            saveas(axh,saved_fig_file_name,'png');        
        end
        
    end
end
