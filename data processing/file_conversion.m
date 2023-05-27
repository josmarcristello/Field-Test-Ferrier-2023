% Publish that
clear;clc;close all;

% Reads lvm %
folder = "\Dropbox\Projects\001 - CNRL - Pipewise\005 - Field Test\2023\data\Field Visit 1\Station 1\NI\";
root_drive = split(matlabroot, '\'); root_drive = root_drive(1); folder_path = root_drive + folder;

% Change the current folder to the folder of this m-file.
if cd ~= folder_path, cd(folder_path), end
    
test_files = get_files('*.lvm');
num_files = size(test_files, 1);
for j = 1
    filename = test_files{j};
end

title_string = [filename];

convert_lvm_to_mat(filename);