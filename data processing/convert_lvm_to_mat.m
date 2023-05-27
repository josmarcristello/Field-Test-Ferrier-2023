% Author: Josmar Cristello
% Converts a .lvm extension to a .mat. 
% Filename is the same, with the converted extension.
% Inputs:
%    filename: filename to be converted
% Outputs: None

%% Main function
function convert_lvm_to_mat(filename)
    % Loading Original File %
    cprintf("cyan", "[convert_lvm_to_mat] Loading the .lvm file."); 
    tic
    data = lvm_import(filename);
    toc
    
    % Saving to Mat File %
    converted_filename = cell2mat(split(filename,   ".lvm"));
    converted_filename = strcat(converted_filename, ".mat");

    
    if isfile(converted_filename)
        cprintf("red", "[convert_lvm_to_mat] Filename already exists. Delete it if you want to proceed with the conversion."); 
        return;
    else 
        % If the variable is larger than 2 GB use version 7.3. Else, don't.
        dt=whos('data'); 
        size=dt.bytes*9.53674e-7/1000; % GB
        
        tic
        cprintf("cyan", "[convert_lvm_to_mat] Converting .lvm to .mat."); 
        if size > 2
            save(converted_filename, 'data', '-mat', '-v7.3');
        else 
            save(converted_filename, 'data', '-mat');
        end 
        toc
    end
    return;
end

%% Note on optimizations
% Example 1:
% .lvm file with 9.5 GB → Converted to .mat file with 3.2 GB
% Original loading time was 190 seconds, converted was 25 seconds.

% Example 2:
% .lvm file with 4.3 GB → Converted to .mat file with 2.0 GB
% Original loading time was 78 seconds, converted was 15 seconds.

% Example 3:
% .lvm file with 1.3 GB → Converted to .mat file with 0.3 GB
% Original loading time was 27 seconds, converted was 4 seconds.
