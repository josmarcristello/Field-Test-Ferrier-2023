clear;clc;close all;

% Reads NI data for the field tests (converted to .mat) %
folder = "\Dropbox\Projects\001 - CNRL - Pipewise\005 - Field Test\2023\data\Field Visit 1\Station 1\NI\";
root_drive = split(matlabroot, '\'); root_drive = root_drive(1); folder_path = root_drive + folder;

% Change the current folder to the folder of this m-file.
if cd ~= folder_path, cd(folder_path), end
    
test_files = get_files('*.mat');
num_files = size(test_files, 1);
for j = 1
    filename = test_files{j};
end

title_string = [filename];

%% Loading Current File %%
tic
data = load(filename);
data = data.data;
toc

num_channels = data.Segment1.num_channels;

%% Process Data

%time_interval   = data.Tinterval;
%num_data_points = data.Length;
%sampling_rate = num_data_points/(time_interval*num_data_points);
global time;
num_channels = data.Segment1.num_channels;

time = data.Segment1.data(:, 1);

if num_channels > 4
    signal_D1_X = data.Segment1.data(:, 2); % D1 - Accelerometer (X)		
    signal_D1_Y = data.Segment1.data(:, 3); % D1 - Accelerometer (Y)			
    signal_D1_Z = data.Segment1.data(:, 4); % D1 - Accelerometer (Z)		
    
    signal_D2_X = data.Segment1.data(:, 5); % D2 - Accelerometer (X)		
    signal_D2_Y = data.Segment1.data(:, 6); % D2 - Accelerometer (Y)		
    signal_D2_Z = data.Segment1.data(:, 7); % D2 - Accelerometer (Z)		
    
    signal_D1_Irig = data.Segment1.data(:, 8); % D1 - Irig-B
    signal_D2_PPS = data.Segment1.data(:, 9); % D2 - 1 PPS
end 

if num_channels > 8
    signal_D3_X = data.Segment1.data(:, 10); % D3 - Accelerometer (X)		
    signal_D3_Y = data.Segment1.data(:, 11); % D3 - Accelerometer (Y)		
    signal_D3_Z = data.Segment1.data(:, 12); % D3 - Accelerometer (Z)	
end

if num_channels > 13
    signal_D4_X = data.Segment1.data(:, 13); % D3 - Accelerometer (X)		
    signal_D4_Y = data.Segment1.data(:, 14); % D3 - Accelerometer (Y)		
    signal_D4_Z = data.Segment1.data(:, 15); % D3 - Accelerometer (Z)	
end

legends = data.Segment1.column_labels;

%% Time Metrics %%
test_duration = time(end);
num_data_points = size(time,1);
sampling_rate = num_data_points/test_duration;

disp("Test Duration: " + test_duration + " seconds.");
disp("Test Duration: " + test_duration/60 + " minutes.");
disp("Test Duration: " + test_duration/(60*60) + " hours.");
disp("Sampling Rate: " + sampling_rate + " Hz.");

channels_text = ["Trigger (Signal Generator)", "Pulse/Receiver (T/R)", "Pulse/Receiver (Output)", "Accel (X)", "Accel (Y)", "Accel (Z)"];

%%
time = time/60;                    % seconds → minutes

%% PSD Data Processing %%

ave_period = 1;
min_x_axis = 20;

figure;
% Device 1 - X, Y, Z
[freq_x, ave_psdx] = PSD(signal_D1_X, sampling_rate, ave_period);
subplot_tight(4,3,1,0.030); plot(freq_x, ave_psdx); title(legends(2) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D1_Y, sampling_rate, ave_period);
subplot_tight(4,3,2,0.030); plot(freq_x, ave_psdx); title(legends(3) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D1_Z, sampling_rate, ave_period);
subplot_tight(4,3,3,0.030); plot(freq_x, ave_psdx); title(legends(4) + " PSD"); xlim([min_x_axis max(freq_x)]);

% Device 2 - X, Y, Z
[freq_x, ave_psdx] = PSD(signal_D2_X, sampling_rate, ave_period);
subplot_tight(4,3,4,0.030); plot(freq_x, ave_psdx); title(legends(5) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D2_Y, sampling_rate, ave_period);
subplot_tight(4,3,5,0.030); plot(freq_x, ave_psdx); title(legends(6) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D2_Z, sampling_rate, ave_period);
subplot_tight(4,3,6,0.030); plot(freq_x, ave_psdx); title(legends(7) + " PSD"); xlim([min_x_axis max(freq_x)]);

% Device 3 - X, Y, Z
[freq_x, ave_psdx] = PSD(signal_D3_X, sampling_rate, ave_period);
subplot_tight(4,3,7,0.030); plot(freq_x, ave_psdx); title(legends(10) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D3_Y, sampling_rate, ave_period);
subplot_tight(4,3,8,0.030); plot(freq_x, ave_psdx); title(legends(11) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D3_Z, sampling_rate, ave_period);
subplot_tight(4,3,9,0.030); plot(freq_x, ave_psdx); title(legends(12) + " PSD"); xlim([min_x_axis max(freq_x)]);

% Device 4 - X, Y, Z
[freq_x, ave_psdx] = PSD(signal_D4_X, sampling_rate, ave_period);
subplot_tight(4,3,10,0.030); plot(freq_x, ave_psdx); title(legends(13) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D4_Y, sampling_rate, ave_period);
subplot_tight(4,3,11,0.030); plot(freq_x, ave_psdx); title(legends(14) + " PSD"); xlim([min_x_axis max(freq_x)]);
[freq_x, ave_psdx] = PSD(signal_D4_Z, sampling_rate, ave_period);
subplot_tight(4,3,12,0.030); plot(freq_x, ave_psdx); title(legends(15) + " PSD"); xlim([min_x_axis max(freq_x)]);

my_export(title_string);

%% Time Domain - Stacked %% 
display_all = 1;

if display_all == 1
    figure;
    %title(strrep(title_string,'_'," "));
    if num_channels <= 4
        subplot_tight(4,3,1,0.030); plot(time, signal_D1_X); quickformat(); title(legends(2));
        subplot_tight(4,3,2,0.030); plot(time, signal_D1_Y); quickformat(); title(legends(3)); ylim([-1 1]);
        
        subplot_tight(4,3,4+3,0.030); plot(time, signal_D1_Irig); quickformat(); title(legends(4)); ylim([-2 2]);    
        subplot_tight(4,3,5+3,0.030); plot(time, signal_D2_PPS); quickformat(); title(legends(5));  ylim([-1 5]);
    else
            subplot_tight(4,3,1,0.030); plot(time, signal_D1_X); quickformat(); title(legends(2)); 
            subplot_tight(4,3,2,0.030); plot(time, signal_D1_Y); quickformat(); title(legends(3));
            subplot_tight(4,3,3,0.030); plot(time, signal_D1_Z); quickformat(); title(legends(4));
            
            subplot_tight(4,3,4,0.030); plot(time, signal_D2_X); quickformat(); title(legends(5));     
            subplot_tight(4,3,5,0.030); plot(time, signal_D2_Y); quickformat(); title(legends(6)); 
            subplot_tight(4,3,6,0.030); plot(time, signal_D2_Z); quickformat(); title(legends(7));    
           
            subplot_tight(4,3,7,0.030); plot(time, signal_D3_X); quickformat(); title(legends(10));
            subplot_tight(4,3,8,0.030); plot(time, signal_D3_Y); quickformat(); title(legends(11));
            subplot_tight(4,3,9,0.030); plot(time, signal_D3_Z); quickformat(); title(legends(12));

            subplot_tight(4,3,10,0.030); plot(time, signal_D4_X); quickformat(); title(legends(13));
            subplot_tight(4,3,11,0.030); plot(time, signal_D4_Y); quickformat(); title(legends(14));
            subplot_tight(4,3,12,0.030); plot(time, signal_D4_Z); quickformat(); title(legends(15));

            %subplot_tight(4,3,10,0.030); plot(time, signal_D1_Irig); quickformat(); title(legends(8)); ylim([-2 2]);
            %subplot_tight(4,3,11,0.030); plot(time, signal_D2_PPS); quickformat(); title(legends(9)); ylim([-1 5]);
    end
    my_export(title_string);
else 
    close all;
    figure;
    %x_start = 107960000+200+9700;
    %x_end   = 107960000+7500+9700;
    x_start = 1;
    x_end   = size(time,1);
    subplot_tight(2,1,1,0.030); plot(time(x_start:x_end), signal_D1_Y(x_start:x_end)); quickformat(); title(legends(8)); ylim([-4 4]); xlim([time(x_start) time(x_end)]);
    subplot_tight(2,1,2,0.030); plot(time(x_start:x_end), signal_D1_Z(x_start:x_end)); quickformat(); title(legends(9)); ylim([-1 6]); xlim([time(x_start) time(x_end)]);
    my_export(title_string);
end

function quickformat_psd()
    global time;
    %ylabel('Voltage [V]'); grid on;
    %xlim([min(time) max(time)]);
    %ylim([-1.0 1.0]);
    %xlabel('Time [s]'); 
end

function quickformat()
    global time;
    ylabel('Voltage [V]'); grid on;
    xlim([min(time) max(time)]);
    ylim([-1.0 1.0]);
    %xlabel('Time [s]'); 
end

function y = my_export(title)
    s = get(0, 'ScreenSize');
    set(gcf, 'Position', [0 0 s(3) s(4)]);
    set(gcf, 'Color', 'w');
    % Interesting options: -transparent
    %export_fig(title, "-png", "-r300");
end