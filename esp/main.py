import machine
import onewire, ds18x20

temperature_pin = machine.Pin(2)
ds = ds18x20.DS18X20(onewire.OneWire(temperature_pin))
roms = ds.scan()

sensor = machine.ADC(0)
S1 = machine.Pin(16, machine.Pin.OUT)
S2 = machine.Pin(5, machine.Pin.OUT)
S3 = machine.Pin(4, machine.Pin.OUT)

Trigger = machine.Pin(14, machine.Pin.OUT)
Echo = machine.Pin(12, machine.Pin.IN)


while True:
    print("Creating new data point...")
    #timestamp = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    timestamp = randomDate((2019, 05, 30, 0, 0, 0, 0, 0), (2019, 05, 31, 12, 0, 0, 0, 0), random.getrandbits(32)/2**32)
    event_uuid = uuid4()
    point = points[random.getrandbits(2)]

    ds.convert_temp() #temperature
    temperature_level = ds.read_temp(roms[0])
    """
    S1.value(0)
    S2.value(0)
    S3.value(0)
    ph_value = (1023-sensor.read())/73.07
    time.sleep(1)
    """
    S1.value(1)
    S2.value(0)
    S3.value(0)
    level_value = sensor.read()
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
    level_value2 = width/59

    """payload = {
        'measure_id': event_uuid,
        'device_id': point[3],
        'description': point[2],
        'lat': point[0],
        'lng': point[1],
        'event_timestamp': '{}-{}-{} {}:{}:{}'.format(timestamp[0], timestamp[1], timestamp[2], timestamp[3], timestamp[4], timestamp[5]),
        'metrics': [
            {
                'name': 'temperature',
                'value': temperature_level
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
                'name': 'level_2',
                'value': level_value2
            }
        ]
    }"""

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
                'value': temperature_level
            },

            {
                'name': 'level',
                'value': level_value
            },
            {
                'name': 'level_2',
                'value': level_value2
            }
        ]
    }
    
    print("Payload: {}".format(json.dumps(payload)))
    print("Publishing message to topic", CONFIG['topic'])
    try:    
        client.publish(CONFIG['topic'], bytes(str(json.dumps(payload)), 'utf-8'))
    except:
        print('Could not publish measure')
    time.sleep(1)

