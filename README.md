# ESP8266 Deploy MicroPython
Deployment script and base project structure for ESP8266 with Serial port emulated over USB 
(such as NodeMCU). You can run the deployment script as a run command from PyCharm.

The deployment script currently works only on Windows. Make a feature request if you'd like
to use it on Linux as well. Pull requests are welcomed.

## Dependencies

* bash, find (available as part of [Cygwin](https://cygwin.com/install.html) or 
  [Git Bash](https://git-scm.com/download/win)).
* [Adafruit MicroPython Tool](https://github.com/adafruit/ampy#installation) (ampy)

## Functions

* Detects COM port where device is connected.
* Updates files on the device.
* Restarts the device if any changes were made.

## Usage

`bash deploy.sh`

to clean all files and push the entire content of the _src_ folder.

`bash deploy.sh -u`

to not remove anything and push only files and folders changed since last run of the script.