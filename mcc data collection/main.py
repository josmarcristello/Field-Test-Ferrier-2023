from time import sleep
import RPi.GPIO as GPIO
from time import sleep, strftime
from daqhats import OptionFlags, SourceType, hat_list, mcc172
from numpy import ndarray
import RPi.GPIO as GPIO
from daqhats import mcc172, OptionFlags, SourceType, TriggerModes
from daqhats_utils import chan_list_to_mask
import Sampling_Config as Config
import os


def write_to_file(stream, array):
    string = ""
    for i in array:
        string += f"{i}, "
    stream.write(string)

def main() :
    # The order in which the devices are listed is the order the will appear in the .csv output

    SAMPLING_RATE_DEVISOR = Config.SAMPLING_RATE_DIVISOR

    # NOTE: Ensure that the hats are organised in increasing address from the raspberrypi to the far size of the enclosure

    list_of_hats = []
    for i in hat_list(): list_of_hats.append(mcc172(i.address))
    # Configure Clocks

    # Set clock to local if only one hat is used
    for ic, board_obj in enumerate(list_of_hats):
        board_obj:mcc172
        if(ic+1 == len(list_of_hats)) : board_obj.a_in_clock_config_write(SourceType.MASTER, SAMPLING_RATE_DEVISOR)
        else: board_obj.a_in_clock_config_write(SourceType.SLAVE, SAMPLING_RATE_DEVISOR)

    # Sync Clocks
    hats_synced = False
    while not hats_synced:
        hats_synced = True
        for i in list_of_hats:
            i:mcc172
            if i.a_in_clock_config_read()[2] == False: hats_synced = False
        sleep(0.1)

    # Setup done
    SLEEP_TIME = 1

    # Setup GPIO pin used for triggering recording
    GPIO.setwarnings(False) 
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(5, GPIO.OUT)
    GPIO.output(5, GPIO.LOW)

    # Set eaech board to start recording when signal is given on GPIO pin
    BUFFER_CAPACITY_SAMPLES = 51240*5
    for i in list_of_hats: 
        i:mcc172

        i.trigger_config(SourceType.SLAVE, TriggerModes.RISING_EDGE)
        mask = chan_list_to_mask([0,1]) 
        i.a_in_scan_start(mask, BUFFER_CAPACITY_SAMPLES, OptionFlags.EXTTRIGGER) 

    STATUS_PIN = 23
    SWITCH_PIN = 24
    RECORDING_PIN = 18

    # Setup pin to detect end of recording
    GPIO.setmode(GPIO.BCM)  # set the pin numbering scheme to BCM
    GPIO.setup(SWITCH_PIN, GPIO.IN)  

    # Setup pin to blink recording led
    GPIO.setmode(GPIO.BCM)  # set the pin numbering scheme to BCM
    GPIO.setup(RECORDING_PIN, GPIO.OUT)  # set pin 17 as an input
     
    path = "/"
    channel_number_file_dict = {}
    file_store_loc = path+strftime("%Y-%m-%d_%H:%M:%S")
    os.mkdir(file_store_loc)

    for num, name in Config.Channel_Number_Name_Dictionary.keys():
        if name != "-" : 
            channel_number_file_dict[num] = open(f"{file_store_loc}_{name}", mode="x+")

    # Trigger pin
    GPIO.output(5, GPIO.HIGH) # Start recording


    # Sampling Loop
    while GPIO.input(SWITCH_PIN):  

        for ic, i in enumerate(list_of_hats):
            first_channel_number = ic*2 +1
            second_channel_number = ic*2 +2
            data = i.a_in_scan_read_numpy(-1,0)[5]

            if(Config.Channel_Number_Name_Dictionary[first_channel_number] != "-"): write_to_file(channel_number_file_dict[num], data[0::2])
            if(Config.Channel_Number_Name_Dictionary[second_channel_number] != "-"): write_to_file(channel_number_file_dict[num], data[1::2])


        time_elapsed += SLEEP_TIME

        # Blink recording led
        if GPIO.input(RECORDING_PIN):
            GPIO.output(RECORDING_PIN, GPIO.LOW)
        else:
            GPIO.output(RECORDING_PIN, GPIO.HIGH)


        sleep(SLEEP_TIME)


    # Scan terminate and buffer cleanup
    for i in list_of_hats: 
        i.a_in_scan_stop()
        i.a_in_scan_cleanup()
                                                 
        
    
if __name__ == "__main__" : main()