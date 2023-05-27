from __future__ import print_function
import os
from sys import stdout, version_info
from math import sqrt
from time import sleep, time
from daqhats import (hat_list, mcc172, OptionFlags, HatIDs, TriggerModes,
                     HatError, SourceType)
from daqhats_utils import (enum_mask_to_string, chan_list_to_mask,
                           validate_channels)
import pandas as pd
from datetime import datetime
import numpy as np
import psutil
import shutil

# Settings
hat_address = 1 # Select HAT to record
scan_rate = 10240.0  # Samples per second. has to be multiples of 2

# Constants
#DEVICE_COUNT = 2 # Deprecated: Calculating with number_of_hats
MASTER = 0
CURSOR_SAVE = "\x1b[s"
CURSOR_RESTORE = "\x1b[u"
CURSOR_BACK_2 = '\x1b[2D'
ERASE_TO_END_OF_LINE = '\x1b[0K'
READ_ALL_AVAILABLE = -1
VERBOSE = 1

# Number of hats detected and types of hats
filter_by_id = HatIDs.MCC_172
hats = hat_list(filter_by_id=filter_by_id)
number_of_hats = len(hats)

print("INFO: there are " + str(number_of_hats) + " hats.")

chans = [
    {0, 1},
    {0, 1}]


###############
## Functions ##
###############

def write_to_csv_file(array_list, filename, sample_rate=10240, elapsed_time=0):
    # Check for array length consistency
    if not all(len(arr) == len(array_list[0]) for arr in array_list):
        print("Array lengths are not consistent, skipping this batch.")
        return

    # Create DataFrame
    times = np.linspace(elapsed_time, elapsed_time + len(array_list[0])/sample_rate, len(array_list[0]))
    df = pd.DataFrame(times, columns=["time"])
    for i, array in enumerate(array_list):
        df["value_" + str(i+1)] = array

    new_filename = filename

    # If file exists, append. If not, write a new file.
    df.to_csv(new_filename, mode='a', header=not os.path.exists(new_filename), index=False)

###############

def clean_and_config_HATs():
    ##########################
    ## Configuring the hats ##
    # Configures every connected hat to :
    # 1 - Activate IEPE
    # 2 - Sets clock source as local
    # 3 - Sets Trigger source as local
    print("\nClearing scan, re-configuring HATs.")
    MASTER = 0
    scan_rate = 10240.0  # Samples per second. has to be multiples of 2
    
    filter_by_id = HatIDs.MCC_172
    hats = hat_list(filter_by_id=filter_by_id)
    number_of_hats = len(hats)

    ## Clearing out any previous scans ##
    for i in range(number_of_hats):
        mcc172(i).a_in_scan_stop()
        mcc172(i).a_in_scan_cleanup()

    for i in range(number_of_hats):
        for channel in chans[i]:
            iepe_enable = 1
            mcc172(i).iepe_config_write(channel, iepe_enable)
    
        ##if mcc172(i).address() != 100000:
            # Configure the slave clocks.
            mcc172(i).a_in_clock_config_write(SourceType.LOCAL, scan_rate)
            # Configure the trigger.
            mcc172(i).trigger_config(SourceType.LOCAL, TriggerModes.ACTIVE_HIGH)

import os

def get_cpu_temp():
    temp_file = os.popen("vcgencmd measure_temp")
    temp_string = temp_file.read()
    temp_file.close()
    return float(temp_string.split('=')[1].split("'")[0])

#######################
## Recording Section ##

clean_and_config_HATs()


hat = mcc172(hat_address)

# Trying to manually record:
channel_mask = chan_list_to_mask([0, 1])
samples_per_channel = 51240*5
#options = OptionFlags.DEFAULT
options = OptionFlags.CONTINUOUS

# Since the continuous option is being used, the samples_per_channel
# parameter is ignored if the value is less than the default internal
# buffer size (10000 * num_channels in this case). If a larger internal
# buffer size is desired, set the value of this parameter accordingly.
hat.a_in_scan_start(channel_mask, samples_per_channel, options)

#read_and_display_data(hat, 2)

## Settings
read_request_size = READ_ALL_AVAILABLE
timeout = 1
num_channels = 2
max_file_size = 4000 # MB, maximum it will record before splitting a new file

filename = "/home/pi/daqhats/Field-Test-Ferrier-2023/mcc-data-collection/data/"
filename = filename + "Hat_" + datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
filename = filename + ".csv"
original_filename = filename

total_samples_read = 0
file_size_MB = 0
file_count = 1
accumulated_data = []

start_time = time()

while True:
    read_result = hat.a_in_scan_read_numpy(read_request_size, timeout)
    
    # Meta Data Calculation
    start_loop_time = time()

    samples_read_per_channel = int(len(read_result.data) / num_channels)
    total_samples_read += samples_read_per_channel

    if samples_read_per_channel > 0:
        write_to_csv_file([read_result.data[0::2], read_result.data[1::2]], filename, elapsed_time=time()-start_time)
        stdout.flush()
    
    if os.path.isfile(filename):
        delta_file_size_MB = os.path.getsize(filename) / (1024 * 1024) - file_size_MB
        file_size_MB = os.path.getsize(filename) / (1024 * 1024)
        
        if VERBOSE:
            elapsed_time = time() - start_time
            loop_time = time() - start_loop_time
            memory_info = psutil.virtual_memory()
            #total, used, free = shutil.disk_usage("/")

            print(f'\rElapsed time: {elapsed_time:.2f} sec. Loop Time: {loop_time:.2f} sec. Current file size: {file_size_MB:.2f} MB (+ {delta_file_size_MB:.2f} MB). Memory used: {memory_info.percent} %. CPU temperature is: {get_cpu_temp()} C.', end='', flush=True)
            #print(f'\rElapsed time: {elapsed_time:.2f} sec. Loop Time: {loop_time:.2f} sec. Current file size: {file_size_MB:.2f} MB (+ {delta_file_size_MB:.2f} MB). Memory used: {memory_info.percent} %. CPU temperature is: {get_cpu_temp()} C. Hard Disk Space: {used // (2**30)} / {total // (2**30)} GB ({free / total * 100:.2f}% free)', end='', flush=True)

        if file_size_MB > max_file_size:
            file_count += 1
            
            filename = f"{original_filename.split('.')[0]}_{file_count}.csv"
            
            clean_and_config_HATs()
            hat.a_in_scan_start(channel_mask, samples_per_channel, options)
    
    sleep(0.1)
    

    