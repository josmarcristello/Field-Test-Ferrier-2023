% Author: Josmar Cristello
% Returns a cell array with the subfolders of the current directory
% Inputs:
%    None
% Outputs:
%    subFolderCell: Cell array of all the subfolder names

%% Main function
function subFolderCell = get_subfolders()
    files = dir(pwd);                          % List of all files and folders in this folder.
    dirFlags = [files.isdir];                  % Logical vector that tells which is a directory.
    subFolders = files(dirFlags);              % Extract only those that are directories.
    subFolderNames = {subFolders(3:end).name}; % Get only the folder names into a cell array. Start at 3 to skip . and ..
    subFolderCell = subFolderNames;
end