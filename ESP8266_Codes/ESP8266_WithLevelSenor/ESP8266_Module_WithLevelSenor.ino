/***************************************************
  Adafruit MQTT Library ESP8266 Example

  Must use ESP8266 Arduino from:
    https://github.com/esp8266/Arduino

  Works great with Adafruit's Huzzah ESP board & Feather
  ----> https://www.adafruit.com/product/2471
  ----> https://www.adafruit.com/products/2821

  Adafruit invests time and resources providing this open source code,
  please support Adafruit and open-source hardware by purchasing
  products from Adafruit!

  Written by Tony DiCola for Adafruit Industries.
  MIT license, all text above must be included in any redistribution
 ****************************************************/
#include <ESP8266WiFi.h>
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"

/************************* WiFi Access Point *********************************/

//#define WLAN_SSID       "APRENDIZ"
//#define WLAN_PASS       "Dvbew89*UBuc70%RCuc95="

//#define WLAN_SSID       "HUAWEI P20 lite"
//#define WLAN_PASS       "c44173a456ce"

#define WLAN_SSID         "Lunch"
#define WLAN_PASS         "12345678"
char variable[] = "Hola";
/************************* Adafruit.io Setup *********************************/

//#define AIO_SERVER      "35.211.233.243"
//#define AIO_SERVERPORT  1883                   // use 8883 for SSL
//#define AIO_SERVER      "10.0.0.1"
#define AIO_SERVER      "lunch.local"
#define AIO_SERVERPORT  1883            

//#define AIO_USERNAME    "Crackio"
//#define AIO_KEY         "c0b97932269f44a1807c120dca5dd6f2"

int sensorPin = A0;    // select the input pin for the potentiometer
int sensorValue = 0;  // variable to store the value coming from the sensor



/************ Global State (you don't need to change this!) ******************/

// Create an ESP8266 WiFiClient class to connect to the MQTT server.
WiFiClient client;
// or... use WiFiFlientSecure for SSL
//WiFiClientSecure client;

// Setup the MQTT client class by passing in the WiFi client and MQTT server and login details.
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT);//, AIO_USERNAME, AIO_KEY);

/****************************** Feeds ***************************************/

// Setup a feed called 'valuesGraph' for publishing.
// Notice MQTT paths for AIO follow the form: <username>/feeds/<feedname>
//Adafruit_MQTT_Publish valuesGraph = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/valuesGraph");
//Adafruit_MQTT_Publish valuesGraph = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "sensor_data");
//Adafruit_MQTT_Publish valuesGraph = Adafruit_MQTT_Publish(&mqtt, "sensor_data");
Adafruit_MQTT_Publish valuesGraph = Adafruit_MQTT_Publish(&mqtt, "test");

// Setup a feed called 'onoff' for subscribing to changes.
// Adafruit_MQTT_Subscribe onoffbutton = Adafruit_MQTT_Subscribe(&mqtt, AIO_USERNAME "/feeds/onoff");

/*************************** Sketch Code ************************************/

// Bug workaround for Arduino 1.6.6, it seems to need a function declaration
// for some reason (only affects ESP8266, likely an arduino-builder bug).
void MQTT_connect();

void setup() {
  Serial.begin(115200);
  delay(10);

  Serial.println(F("Adafruit MQTT demo"));

  // Connect to WiFi access point.
  Serial.println(); Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WLAN_SSID);

  WiFi.begin(WLAN_SSID, WLAN_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.println("WiFi connected");
  Serial.println("IP address: "); Serial.println(WiFi.localIP());


/* JOACO comment
  // Setup MQTT subscription for onoff feed.
  mqtt.subscribe(&onoffbutton);
 */
}

uint32_t x=0;

void loop() {
  // Ensure the connection to the MQTT server is alive (this will make the first
  // connection and automatically reconnect when disconnected).  See the MQTT_connect
  // function definition further below.
  MQTT_connect();

  // this is our 'wait for incoming subscription packets' busy subloop
  // try to spend your time here

/* JOACO comment
  Adafruit_MQTT_Subscribe *subscription;
  while ((subscription = mqtt.readSubscription(5000))) {
    if (subscription == &onoffbutton) {
      Serial.print(F("Got: "));
      Serial.println((char *)onoffbutton.lastread);
    }
  }
*/

  delay(2000);
  // Now we can publish stuff!
  Serial.print(F("\nSending valuesGraph val "));  
  Serial.print(variable);
  Serial.print(x);
  Serial.print("...");
  if (! valuesGraph.publish(variable) & valuesGraph.publish(x++)) {
    Serial.println(F("Failed"));
  } else {
    Serial.println(F("OK!"));
  }


  sensorValue = analogRead(sensorPin);
  Serial.println(sensorValue);

  // ping the server to keep the mqtt connection alive
  // NOT required if you are publishing once every KEEPALIVE seconds
  /*
  if(! mqtt.ping()) {
    mqtt.disconnect();
  }
  */
}

// Function to connect and reconnect as necessary to the MQTT server.
// Should be called in the loop function and it will take care if connecting.
void MQTT_connect() {
  int8_t ret;

  // Stop if already connected.
  if (mqtt.connected()) {
    return;
  }

  Serial.print("Connecting to MQTT... ");

  uint8_t retries = 3;
  while ((ret = mqtt.connect()) != 0) { // connect will return 0 for connected
       Serial.println(mqtt.connectErrorString(ret));
       Serial.println("Retrying MQTT connection in 5 seconds...");
       mqtt.disconnect();
       delay(5000);  // wait 5 seconds
       retries--;
       if (retries == 0) {
         // basically die and wait for WDT to reset me
         while (1);
       }
  }
  Serial.println("MQTT Connected!");
}
