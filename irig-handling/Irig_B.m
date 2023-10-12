%% open .lvm to import data
data = lvm_file_import('st_1_test___006.lvm',2);

freq = 10240;

%% time axis
pps_data = data.Segment1.data(:, 8);
irig_data = data.Segment1.data(:, 9);
pps = process_pulse(pps_data, freq);
time_dict = IRIG2time_v2(irig_data, freq, pps);

% IRIG-B gives us UTC time (Coordinated Universal Time), correct the time to mountain time
time_dict.hour = time_dict.hour-6;

%% select leak and no leak vibrational data to process
% leak: select start time and find the corresponding signal index
start_hour = 12; % time range is explained in file: Tests Explanation_HBC.txt
start_minute = 54; %
start_second = 0; %
buff = find((time_dict.hour == start_hour) & (time_dict.minute == start_minute) & (time_dict.second == start_second));
measured_signal_index = time_dict.index (buff); % the start index in the measured signal corresponding to the time point
length = 6*60; %floor(size(pps_data,1)/freq)-1; % in s, length of time signal to analysis; whole range is: floor(size(pps_data,1)/freq)-1

time_step = 1/freq;
data_points = length*freq;
time_points_st1_L = time_step:time_step:data_points*time_step;
index_range = measured_signal_index : measured_signal_index+data_points-1;
data_selected_st1_L_Li = data.Segment1.data(index_range, i);
data_selected_st1_L_Lj = data.Segment1.data(index_range, j);
data_selected_st1_L_Lk = data.Segment1.data(index_range, k);
