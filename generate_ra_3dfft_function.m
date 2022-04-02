function ra = generate_ra_3dfft_function(params, data_frames, frame_start, frame_end, data_each_frame, offset, save_det_dir, vis_save_dir)
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
Is_Windowed = 1;% 1==> Windowing before doing range and angle fft
Is_plot_rangeDop = 0;
% save_det_dir = '/home/ray/Documents/results/sample_data.txt';
save_plot_dir = '/home/ray/Documents/results/sample_data.png';
det = [];

for i = frame_start:frame_end
    disp(i)
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
    Dopdata_sum = squeeze(mean(abs(Dopplerdata_odd), 2));
    
    % Plot range-Doppler image
    if Is_plot_rangeDop
%         plot_rangeDop(Dopdata_sum,rng_grid,vel_grid);
    end
    
    % CFAR detector on Range-Velocity to detect targets 
    % Output format: [doppler index, range index(start from index 1), ...
    % cell power]
    Pfa = 1e-4; % probability of false alarm
    [Resl_indx] = cfar_RV(Dopdata_sum, fft_Rang, num_crop, Pfa);
    detout = peakGrouping(Resl_indx);
    
    % doppler compensation on Rangedata_even using the max-intensity peak
    % on each range bin
    for ri = num_crop+1:fft_Rang-num_crop
        find_idx = find(detout(2, :) == ri);
        if isempty(find_idx)
            continue
        else
            % pick the first larger velocity
            pick_idx = find_idx(1);
            % phase compensation for virtual elements
            pha_comp_term = exp(-1i * pi * (detout(1,pick_idx)-fft_Vel/2-1) / fft_Vel);
            Rangedata_even(ri, :, :) = Rangedata_even(ri, :, :) * pha_comp_term;
        end
    end
    
    Rangedata_merge = [Rangedata_odd, Rangedata_even];
    
    % Angle FFT
    Angdata = fft_angle(Rangedata_merge,fft_Ang,Is_Windowed);
    Angdata_crop = Angdata(num_crop + 1:fft_Rang - num_crop, :, :);
    [Angdata_crop] = Normalize(Angdata_crop, max_value);
    
    % Angle estimation for detected point clouds
    Dopplerdata_merge = permute([Dopplerdata_odd, Dopplerdata_even], [2, 1, 3]);
    [Resel_agl, ~, rng_excd_list] = angle_estim_dets(detout, Dopplerdata_merge, fft_Vel, ...
        fft_Ang, Rx, Tx, num_crop);
    
    % Transform bin index to range/velocity/angle
    Resel_agl_deg = agl_grid(1, Resel_agl)';
    Resel_vel = vel_grid(detout(1,:), 1);
    Resel_rng = rng_grid(detout(2,:), 1);
        
    % save_det data format below
    % [range bin, velocity bin, angle bin, power, range(m), velocity (m/s), angle(degree)]
    save_det_data = [detout(2,:)', detout(1,:)', Resel_agl', detout(3,:)', ...
        Resel_rng, Resel_vel, Resel_agl_deg];
    
    indexs = ones(size(detout(1,:)', 1), 1);
    indexs = indexs * (i - offset - 1);
    save_det_data2 = [indexs, detout(1,:)', detout(2,:)', Resel_agl', detout(3,:)'];
    % filter out the points with range_bin within the crop region
    if ~isempty(rng_excd_list)
        save_det_data(rng_excd_list, :) = [];
        save_det_data2(rng_excd_list, :) = [];
    end
    
    % Point obtained clouds
%     plot_pointclouds(save_det_data);
    
    if i == frame_start
        det = save_det_data2;
    else
        det = cat(1, det, save_det_data2);
    end
    
    % Plot range-angle (RA) image
    [axh] = plot_rangeAng(Angdata_crop,rng_grid(num_crop+1:fft_Rang-num_crop),agl_grid, save_det_data);
    if ~exist(vis_save_dir, 'dir')
        mkdir(vis_save_dir)
    end
    image_save_path = strcat(vis_save_dir,'/frame_',num2str(i-1,'%06d'),'.png');
    saveas(axh,image_save_path,'png');
    
end
writematrix(det, save_det_dir, 'Delimiter',' ');

end