% Leak Rate Calculator
clear;clc;close all;
% Read IRIG-B Data

   
%pathname = strcat('test',num2str(i));
%disp(pathname);
%addpath(pathname)

%filename = {'test_001.lvm','testacc_001.lvm','signal_001.lvm'};
filename = ['test_4.lvm'];

data_f = lvm_import(filename,2);
test.f  = data_f.Segment1.data;

time = test.f(:,1);       % Time domain
signal_IRIG = test.f(:,2);   % IRIG-B Signal
signal_PPS = test.f(:,3); % 1-PPS Signal

sampling_rate = size(test.f, 1)/max(time)

%% Time Domain %% 
% Time Domain - Output Signal
figure;
%plot(time(70000:80000), signal_IRIG(70000:80000));
plot(time, signal_IRIG);
%hold on;
%plot(time, signal_PPS);
title_string = ['Time_Domain'];
title(strrep(title_string,'_'," "));
xlabel('Time [s]');
ylabel('Voltage [V]');
%xlim([0.7 0.9])
ylim([0 2])
grid on;

min_treshold = 0;
[pks,locs] = findpeaks(signal_IRIG(1:10000), time(1:10000), 'MinPeakHeight', min_treshold); % additionally returns the indices at which the peaks occur.
%pks = pks./pks;
pks(pks>1) = 1;
pks(pks<1) = 0.5;


%figure; 
hold on
plot(locs, pks, '.');
legend(["Signal", "Identified Peaks"])
ylim([0 2]);
xlim([0.7 0.9]);

my_export(title_string);


function y = my_export(title)
    s = get(0, 'ScreenSize');
    set(gcf, 'Position', [0 0 s(3) s(4)]);
    set(gcf, 'Color', 'w');
    export_fig(title, "-png", "-r300");
end