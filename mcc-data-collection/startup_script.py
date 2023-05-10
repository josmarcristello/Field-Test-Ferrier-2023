import RPi.GPIO as GPIO
from time import sleep
from main import main
import os

STATUS_PIN = 23
SWITCH_PIN = 24

GPIO.setmode(GPIO.BCM)  # set the pin numbering scheme to BCM
GPIO.setup(STATUS_PIN, GPIO.OUT)  # set pin 17 as an input
GPIO.setup(SWITCH_PIN, GPIO.IN)  # set pin 17 as an input
GPIO.output(STATUS_PIN, GPIO.HIGH) #Pin to status Led

# Forever wait for 
while True:
    if GPIO.input(SWITCH_PIN) :
        # os.system("/home/pi/new_MCC172/env/bin/python3.9 /home/pi/new_MCC172/main.py") #This does not block
        main()
    sleep(1)
    
