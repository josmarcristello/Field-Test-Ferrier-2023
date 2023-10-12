% Leak Rate Calculator
clear;clc;close all;
% Read IRIG-B Data


%pathname = strcat('test',num2str(i));
%disp(pathname);
%addpath(pathname)

%filename = {'test_001.lvm','testacc_001.lvm','signal_001.lvm'};

%% Importing Files %%

root_drive = split(matlabroot, '\');
root_drive = root_drive(1);

%folder = "\Dropbox\Projects\001 - CNRL - Pipewise\005 - Field Test\Jul 19 - Field Test\Station 2 - NI";
%folder = "\Dropbox\Projects\001 - CNRL - Pipewise\005 - Field Test\Jul 19 - Field Test\Station 3 - NI";
folder = "\Dropbox\Projects\001 - CNRL - Pipewise\005 - Field Test\Jul 19 - Field Test\Station 1 - NI";

folder_path = root_drive + folder;

% Change the current folder to the folder of this m-file.
if cd ~= folder_path
    cd(folder_path)
end

    
test_files = get_files("*.lvm");
num_files = size(test_files,1);
for j = 1
    filename = test_files{j};
end


%% Iporting File itself

data_f = lvm_import(filename,2);


%% Iporting Data

test.f  = data_f.Segment1.data;

time = test.f(:,1);
signal_IRIG = test.f(:,8); % IRIG-B Signal
signal_PPS = test.f(:,9);  % 1-PPS Signal

sampling_rate = size(test.f, 1)/max(time);

%% Peak Identification %%
[IRIG_peaks,locs] = findpeaks(signal_IRIG, time, 'MinPeakHeight', 0); % additionally returns the indices at which the peaks occur.
IRIG_peaks(IRIG_peaks > 1) = 1;
IRIG_peaks(IRIG_peaks < 1) = 0;

time_array = [];
date_array = [];

plot(time(1:1000), signal_IRIG(1:1000));
hold on;
%plot(time(1:1000), IRIG_peaks(1:1000), '.');
plot(locs(1:100), IRIG_peaks(1:100), '.');


%% Making Sum Vectors %%
[sum_vec, IRIG_vec_idx] = make_sum_vectors(IRIG_peaks);
patterns_index = search_for_reftime(sum_vec);

%% Decoding the date - First date %%

% First Marker
start_idx = patterns_index(1);
seconds = 0;
seconds = seconds + 1 *  mod(sum_vec(start_idx + 1), 2);
seconds = seconds + 2 *  mod(sum_vec(start_idx + 2), 2);
seconds = seconds + 4 *  mod(sum_vec(start_idx + 3), 2);
seconds = seconds + 8 *  mod(sum_vec(start_idx + 4), 2);
%seconds = seconds + sum_vec(start_idx + 5);
seconds = seconds + 10 * mod(sum_vec(start_idx + 6), 2);
seconds = seconds + 20 * mod(sum_vec(start_idx + 7), 2);
seconds = seconds + 40 * mod(sum_vec(start_idx + 8), 2); 
%%sum_vec(start_idx + 9) % 8 pps marker

minutes = 0;
minutes = minutes + 1 *  mod(sum_vec(start_idx + 10), 2);
minutes = minutes + 2 *  mod(sum_vec(start_idx + 11), 2);
minutes = minutes + 4 *  mod(sum_vec(start_idx + 12), 2);
minutes = minutes + 8 *  mod(sum_vec(start_idx + 13), 2);
%minutes = minutes + sum_vec(start_idx + 14);
minutes = minutes + 10 * mod(sum_vec(start_idx + 15), 2);
minutes = minutes + 20 * mod(sum_vec(start_idx + 16), 2);
minutes = minutes + 40 * mod(sum_vec(start_idx + 17), 2); 
%minutes = minutes + sum_vec(start_idx + 18);
%%sum_vec(start_idx + 19) % 8 pps marker

hours = 0;
hours = hours + 1 *  mod(sum_vec(start_idx + 20), 2);
hours = hours + 2 *  mod(sum_vec(start_idx + 21), 2);
hours = hours + 4 *  mod(sum_vec(start_idx + 22), 2);
hours = hours + 8 *  mod(sum_vec(start_idx + 23), 2);
%hours = hours + sum_vec(start_idx + 24);
hours = hours + 10 * mod(sum_vec(start_idx + 25), 2);
hours = hours + 20 * mod(sum_vec(start_idx + 26), 2);
%hours = hours + mod(sum_vec(start_idx + 27), 2);
%hours = hours +  mod(sum_vec(start_idx + 28), 2);
%%sum_vec(start_idx + 29) % 8 pps marker

days = 0;
days = days +   1 * mod(sum_vec(start_idx + 30), 2);
days = days +   2 * mod(sum_vec(start_idx + 31), 2);
days = days +   4 * mod(sum_vec(start_idx + 32), 2);
days = days +   8 * mod(sum_vec(start_idx + 33), 2);
%days = days + sum_vec(start_idx + 34);
days = days +  10 * mod(sum_vec(start_idx + 35), 2);
days = days +  20 * mod(sum_vec(start_idx + 36), 2);
days = days +  40 * mod(sum_vec(start_idx + 37), 2);
days = days +  80 * mod(sum_vec(start_idx + 38), 2);

%%sum_vec(start_idx + 39) % 8 pps marker

days = days + 100 * mod(sum_vec(start_idx + 40), 2);
days = days + 200 * mod(sum_vec(start_idx + 41), 2);

start_date = [days, hours, minutes, seconds];
start_date = datetime(0, 0, days, hours, minutes, seconds);

% Time when the collection started
start_IRIG_idx = IRIG_vec_idx(patterns_index(1))
zero_date = datetime(0, 0, days, hours, minutes, seconds - start_IRIG_idx/1000);


%% Decoding the date - Final date %%

% First Marker
start_idx = patterns_index(end-1);
seconds = 0;
seconds = seconds + 1 *  mod(sum_vec(start_idx + 1), 2);
seconds = seconds + 2 *  mod(sum_vec(start_idx + 2), 2);
seconds = seconds + 4 *  mod(sum_vec(start_idx + 3), 2);
seconds = seconds + 8 *  mod(sum_vec(start_idx + 4), 2);
%seconds = seconds + sum_vec(start_idx + 5);
seconds = seconds + 10 * mod(sum_vec(start_idx + 6), 2);
seconds = seconds + 20 * mod(sum_vec(start_idx + 7), 2);
seconds = seconds + 40 * mod(sum_vec(start_idx + 8), 2); 
%%sum_vec(start_idx + 9) % 8 pps marker

minutes = 0;
minutes = minutes + 1 *  mod(sum_vec(start_idx + 10), 2);
minutes = minutes + 2 *  mod(sum_vec(start_idx + 11), 2);
minutes = minutes + 4 *  mod(sum_vec(start_idx + 12), 2);
minutes = minutes + 8 *  mod(sum_vec(start_idx + 13), 2);
%minutes = minutes + sum_vec(start_idx + 14);
minutes = minutes + 10 * mod(sum_vec(start_idx + 15), 2);
minutes = minutes + 20 * mod(sum_vec(start_idx + 16), 2);
minutes = minutes + 40 * mod(sum_vec(start_idx + 17), 2); 
%minutes = minutes + sum_vec(start_idx + 18);
%%sum_vec(start_idx + 19) % 8 pps marker

hours = 0;
hours = hours + 1 *  mod(sum_vec(start_idx + 20), 2);
hours = hours + 2 *  mod(sum_vec(start_idx + 21), 2);
hours = hours + 4 *  mod(sum_vec(start_idx + 22), 2);
hours = hours + 8 *  mod(sum_vec(start_idx + 23), 2);
%hours = hours + sum_vec(start_idx + 24);
hours = hours + 10 * mod(sum_vec(start_idx + 25), 2);
hours = hours + 20 * mod(sum_vec(start_idx + 26), 2);
%hours = hours + mod(sum_vec(start_idx + 27), 2);
%hours = hours +  mod(sum_vec(start_idx + 28), 2);
%%sum_vec(start_idx + 29) % 8 pps marker

days = 0;
days = days +   1 * mod(sum_vec(start_idx + 30), 2);
days = days +   2 * mod(sum_vec(start_idx + 31), 2);
days = days +   4 * mod(sum_vec(start_idx + 32), 2);
days = days +   8 * mod(sum_vec(start_idx + 33), 2);
%days = days + sum_vec(start_idx + 34);
days = days +  10 * mod(sum_vec(start_idx + 35), 2);
days = days +  20 * mod(sum_vec(start_idx + 36), 2);
days = days +  40 * mod(sum_vec(start_idx + 37), 2);
days = days +  80 * mod(sum_vec(start_idx + 38), 2);

sum_vec(start_idx + 39) % 8 pps marker

days = days + 100 * mod(sum_vec(start_idx + 40), 2);
days = days + 200 * mod(sum_vec(start_idx + 41), 2);

%end_date = [days, hours, minutes, seconds];
end_date = datetime(0, 0, days, hours, minutes, seconds);

% Time when the collection ended
end_IRIG_idx = IRIG_vec_idx(patterns_index(end-1));
final_IRIG_idx = IRIG_vec_idx(end) - end_IRIG_idx;
final_date = datetime(0, 0, days, hours, minutes, seconds + final_IRIG_idx/1000);


%% Decoding the time %%

%sum_vec(start_idx)
%IRIG_vec_idx(start_idx)

% At the middle of the 8-pps marker, seconds = 0
% Then, every 8-pps marker sums 0.1 seconds
% Then, fill in the middle

start_IRIG_idx = IRIG_vec_idx(patterns_index(1));
end_IRIG_idx = IRIG_vec_idx(patterns_index(end-1));

% Main loop: Creates date-times between start and end
date_array(start_IRIG_idx:end_IRIG_idx) = linspace(datenum(start_date), datenum(end_date), end_IRIG_idx - start_IRIG_idx + 1);


% Auxiliary loop: Creates date-time before start
date_array(1:start_IRIG_idx) = linspace(datenum(zero_date), datenum(start_date), start_IRIG_idx);

% Auxiliary loop: Creates date-time after end
date_array(end_IRIG_idx:IRIG_vec_idx(end)) = linspace(datenum(end_date), datenum(final_date), final_IRIG_idx + 1);

datevec(date_array(1))                % Zero Date
%datevec(date_array(start_IRIG_idx-1)) % 1 before Start Date
%datevec(date_array(start_IRIG_idx))   % Start Date
%datevec(date_array(end_IRIG_idx))     % End date
datevec(date_array(end))              % Final date

signal_date = linspace(date_array(1), date_array(end), size(signal_IRIG, 1));

%% Functions %%

function sum_vec_pat_idx = search_for_reftime(sum_vec)
    % Search for the reference time marker (Two sequences of eight peaks)
    % Returns the index for the sum vector. In the MIDDLE of the pattern
    % (i.e.between the two 8, 1 ms pulses)
    % Irig-B vector index could be found with
    % IRIG_vec_idx(sum_vec_pat_idx(2))
    sum_vec_pat_idx = [];
    index = 1;
    while index < size(sum_vec, 2)
        if sum_vec(index) == 8
           if sum_vec(index + 1) == 8
                sum_vec_pat_idx(end+1) = index + 1;
           end
        end 
        index = index + 1;
    end
end

function [sum_vec, IRIG_vec_idx] = make_sum_vectors(IRIG_peaks)
% Stores two vectors:
% The first one, is a sum of the peaks in a row (sum_vec)
% The second one, is the original index of those peaks (IRIG_vec_idx)
sum_vec = [];
IRIG_vec_idx = [];
index = 1;
    while index < size(IRIG_peaks, 1)
        sum = sum_peaks(IRIG_peaks, index);
        if sum ~= 0
            sum_vec(end+1) = sum(IRIG_peaks(index));  % Saves the value of the sum
            IRIG_vec_idx(end+1) = index;               % Saves the original index alongside
            index = index + sum;                      % Shifts index by sum amount
        else 
            index = index + 1;                        % Shifts index by 1
        end
    end
end

function r = sum_peaks(IRIG_peaks, index_start)
% If current index is not a peak, return zero.
% Else, returns the number of peaks in a row.
if IRIG_peaks(index_start) == 0
        r = 0;
    else
        r = IRIG_peaks(index_start);
        while IRIG_peaks(index_start + 1) == 1
            index_start = index_start + 1;
            r = r + IRIG_peaks(index_start);
        end
    end
end

function fileNames = get_files(extension)
    % Returns a cell array with the files of the current directory, matching extension
    extensionFiles = dir(extension);    % Filter files for selected extension (e.g. '*.mat')
    fileNames = {extensionFiles.name}; % Extracts just the names in a cell array
end

function subFolderCell = get_subfolders()
    files = dir(pwd);             % List of all files and folders in this folder.
    dirFlags = [files.isdir];     % Logical vector that tells which is a directory.
    subFolders = files(dirFlags); % Extract only those that are directories.
    subFolderNames = {subFolders(3:end).name}; % Get only the folder names into a cell array. Start at 3 to skip . and ..
    subFolderCell = subFolderNames;
end