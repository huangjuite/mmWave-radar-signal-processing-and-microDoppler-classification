function process(capture_files, file_name)

    addpath(genpath('.'))

    params = get_params_value();
    frame_start = 1;
    data_each_frame = params.samples*params.loop*params.Tx;

    %% file folders
    disp(capture_files);
    data = readDCA1000(capture_files, params.samples);
    data_length = length(data);
    Frame_num = data_length/data_each_frame;
    frame_end = Frame_num;
    disp(Frame_num);

    %% process
    velocity_map(data, frame_start, frame_end, params, file_name);
    
end