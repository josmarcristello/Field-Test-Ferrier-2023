import os

# specify the directory you want to delete files from
dir_path = "/home/pi/daqhats/Field-Test-Ferrier-2023/mcc-data-collection/data/"

# iterate over the files in
# that directory
for filename in os.listdir(dir_path):
    file_path = os.path.join(dir_path, filename)
    # check if it is a file
    if os.path.isfile(file_path):
        os.remove(file_path)