import machine
import time
import onewire, ds18x20

# temperature_pin = machine.Pin(14)
# ds = ds18x20.DS18X20(onewire.OneWire(temperature_pin))
# roms = ds.scan()

sensor = machine.ADC(0)
S1 = machine.Pin(4, machine.Pin.OUT)
S2 = machine.Pin(5, machine.Pin.OUT)
S3 = machine.Pin(16, machine.Pin.OUT)

Trigger = machine.Pin(13, machine.Pin.OUT)
Echo = machine.Pin(12, machine.Pin.IN)

point = [4.6355555555556, -74.082777777778, "Punto de Prueba", "5"]

# counter = 0
while True:
    print("Creating new data point...")
    random.seed(counter)
    #timestamp = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    #timestamp = randomDate((2019, 05, 30, 0, 0, 0, 0, 0), (2019, 05, 31, 12, 0, 0, 0, 0), random.getrandbits(32)/2**32)
    timestamp = time.localtime(time.time())
    event_uuid = uuid4()
    # point = points[random.getrandbits(2)]
	
    # ds.convert_temp() #temperature
    temperature_value = 18 # ds.read_temp(roms[0])

    S1.value(1)
    S2.value(0)
    S3.value(0)
    ph_value = (1023-sensor.read())/73.07
    time.sleep(1)

    S1.value(1)
    S2.value(1)
    S3.value(0)
    turbidity_value = sensor.read()
    time.sleep(1)
    
    Trigger.value(0)
    Trigger.value(1)
    time.sleep(10/1000000)
    Trigger.value(0)
    
    while not Echo.value():
    	pass
    start = time.ticks_us()
    while Echo.value():
    	pass
    width = time.ticks_diff(time.ticks_us(), start)
    level_value = width/59
    
    payload = {
        'measure_id': event_uuid,
        'device_id': point[3],
        'description': point[2],
        'lat': point[0],
        'lng': point[1],
        'event_timestamp': '{}-{}-{} {}:{}:{}'.format(timestamp[0], timestamp[1], timestamp[2], timestamp[3], timestamp[4], timestamp[5]),
        'metrics': [
            {
                'name': 'temperature',
                'value': temperature_value
            },

            {
                'name': 'level',
                'value': level_value
            },
            {
                'name': 'ph',
                'value': ph_value
            },
            {
                'name': 'turbidity',
                'value': turbidity_value
            }
        ]
    }
    
    print("Payload: {}".format(json.dumps(payload)))
    print("Publishing message to topic", CONFIG['topic'])
    try:    
        client.publish(CONFIG['topic'], bytes(str(json.dumps(payload)), 'utf-8'))
    except:
        print('Could not publish measure')
    # counter += 1
    # if counter == 9999999: counter = 0
    time.sleep(1)
