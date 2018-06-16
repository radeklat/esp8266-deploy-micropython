# ESP8266 Deploy MicroPython
Deployment script and base project structure for ESP8266 with Serial port emulated over USB 
(such as NodeMCU). You can run the deployment script as a run command from PyCharm.

The deployment script has been tested on Linux and Windows. It may work on Unix based systems as well. 

Pull requests are welcomed.

## Dependencies

* bash, find (on Windows available as part of [Cygwin](https://cygwin.com/install.html) or 
  [Git Bash](https://git-scm.com/download/win)).
* [Adafruit MicroPython Tool](https://github.com/adafruit/ampy#installation) (ampy)

## Functions

1. Detects emulated serial port where device is connected.
1. Deletes all files on the device and puts there all new ones. Or updates only changes files (use the `-u` or `--update` option)
1. Opens console with the device (use the `-c` or `--console` option)
1. Goes to _step 1_ when console closes (use the `-l` or `--loop` option)

## Usage

### Windows

`bash deploy.sh`

to clean all files and push the entire content of the _src_ folder.

`bash deploy.sh -u`

to not remove anything and push only files and folders changed since last run of the script.

### Other OSes

Run the same as above with `sudo` as it requires elevated privileges to access the serial port.