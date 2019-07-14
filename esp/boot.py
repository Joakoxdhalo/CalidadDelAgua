import time
import json
import random
import network
from umqtt.simple import MQTTClient 
from ntptime import settime

CONFIG = {
    "broker": "35.211.233.243",
    "sensor_pin": 0, 
    "client_id": b"esp8266_test",
    "topic": "sensor_data",
}


def strTimeProp(start, end, format, prop):
    stime = time.mktime(start)
    etime = time.mktime(end)
    ptime = stime + int(prop * (etime - stime))
    return time.localtime(ptime)


def randomDate(start, end, prop):
    return strTimeProp(start, end, '%Y-%m-%d %H:%M', prop)

def uniform(a, b):
    return a + (b-a) * random.getrandbits(32)/2**32

def uniform_int(a, b):
    return round(a + (b-a) * random.getrandbits(32)/2**32)

def rand_char():
    return [chr(uniform_int(97, 97 + 25)), chr(uniform_int(48, 48 + 9)), chr(uniform_int(65, 65 + 25))][uniform_int(0, 1)]

def rand_str(l):
    return ''.join([rand_char() for i in range(l)])

def uuid4():
    return '{}-{}-{}-{}-{}'.format(rand_str(8), rand_str(4), rand_str(4), rand_str(4), rand_str(8))

wlan = network.WLAN(network.STA_IF)
wlan.active(True)
connected = wlan.isconnected()
#wlan.connect('HUAWEIP20', 'c44173a456c3')
#wlan.connect('Camu', 'intern3t')
wlan.connect('ADEJANDO', 'kiriku22')
#wlan.connect('Dantiteis', 'Standar.1406')
while not connected:
    print('connecting wifi')
    connected = wlan.isconnected()
    time.sleep(1)

settime()

client = MQTTClient(CONFIG['client_id'], CONFIG['broker'])
connected = False
while not connected:
    try:
        client.connect()
        connected = True
    except:
        time.sleep(1)
        print("Failed connecting to {}".format(CONFIG['broker']))
        continue

print("Connected to {}".format(CONFIG['broker']))

#ts = time.time()
"""
points = [
	(5.217041, -73.542104, "Rio Bogota Nacedero", "1"),
	(5.150290, -73.690503, "Rio Bogota Choconta", "2"),
	(4.750229, -74.127806, "Rio Bogota Siberia", "3"),
	(-1.418765, -70.587582, "Rio Caqueta Zona Media", "4")
]
"""
points = [(4.6355555555556, -74.082777777778, "Punto de Prueba", "5")]
