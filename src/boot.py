# This file is executed on every boot (including wake-boot from deepsleep)
import gc
import webrepl
import network
import time

ESSID = ''
PASSWORD = ''


def set_interface_active(interface: network.WLAN, state: bool):
    if interface.active() != state:
        interface.active(state)


def do_connect():
    sta_if = network.WLAN(network.STA_IF)
    ap_if = network.WLAN(network.AP_IF)

    set_interface_active(sta_if, True)
    set_interface_active(ap_if, False)

    print('Connecting to network ', end='', flush=True)
    i = 0

    while not sta_if.isconnected():
        sta_if.connect(ESSID, PASSWORD)
        time.sleep(0.1)
        i += 1

        if i % 10 == 0:
            print('.', end='', flush=True)
            i = 0

    print('Connected')
    print('Network config:', sta_if.ifconfig())


webrepl.start()
do_connect()
gc.collect()
