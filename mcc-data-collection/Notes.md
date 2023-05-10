# Defining Run & Startup

```
sudo nano /etc/systemd/system/continuous_record_data.service
```
Add in the code:
```
[Unit]
Description=Continuous Record Data Service
After=multi-user.target

[Service]
User=pi
ExecStart=/usr/bin/python3 /path/to/your/script/continuous_record_data.py

[Install]
WantedBy=multi-user.target
```

Reload the systemd manager configuration to recognize the new service file:
```
sudo systemctl daemon-reload
```

Enable the service so it starts on boot:

```
sudo systemctl enable continuous_record_data.service
```
Optionally, you can start the service immediately without rebooting to test it:

```
sudo systemctl start continuous_record_data.service
```

Check the status of the service:

```
sudo systemctl status continuous_record_data.service
```

Restart the service:
```
sudo systemctl restart continuous_record_data.service
```

Stop the continuous_record_data service, you can use the following command:
```
sudo systemctl stop continuous_record_data.service
```

If you want to stop & **disable** the service from running on startup, use this command: 
```
sudo systemctl stop continuous_record_data.service
sudo systemctl disable continuous_record_data.service
```

# Dealing with the hats

Count number of daqhats
```
daqhats_list_boards 
```