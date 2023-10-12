% Author: Josmar Cristello
% Returns a cell array with the files of the current directory, matching extension
% Inputs:
%    extension: File extension to look for.
% Outputs
%    filenames: Cell array of all the filenames
%% Main function
function fileNames = get_files(extension)
    extensionFiles = dir(extension);    % Filter files for selected extension (e.g. '*.mat')
    fileNames = {extensionFiles.name};  % Names in a cell array
end


