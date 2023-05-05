# This is the config file for the Raspberry DAQ system 

#The actual sampling rate is limited to values of 51.2 kHz devided by an integer between 1 and 255
#Example: if SAMPLING_RATE_DIVISOR = 5 then the sampling rate is 51.2kHz/5 = 10240 Hz
SAMPLING_RATE_DIVISOR = 5 

# Set the names assigned to different channels here
# Use "-" to denote that data from this channel is not to be saved
Channel_Number_Name_Dictionary = {
    1:"X",
    2:"Y",
    3:"Z",
    4:"IRIG-B",
    5:"1PPS",
    6:"-"
}