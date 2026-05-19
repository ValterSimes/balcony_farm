#include <Arduino.h>
#include <DHT.h>
#include <Wire.h>
#include <BH1750.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include "date.h"

// Broker
const int MQTT_PORT = 1883;
const char* DEVICE_ID = "mistol_01"; // Mistol is a native tree from home that produces sweet red fruits used for medicine

// Sensors
#define DHT_PIN D2
#define DHT_TYPE DHT22
#define SOIL_STRAWBERRY A0
#define SOIL_CHILI A1

DHT tempHumSensor(DHT_PIN, DHT_TYPE);
BH1750 lightSensor;
WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);

// Publish schedule
unsigned long lastPublish = 0;
const unsigned long PUBLISH_INTERVAL = 30000;

void connectWiFi() {
  Serial.printf("Connecting to Wifi...\n");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
  }
  Serial.printf("Wifi Connected!\n");
}

void connectBroker() {
  while (!mqtt.connected()){
    Serial.printf("Connecting to Broker...\n");
    if (mqtt.connect(DEVICE_ID, MQTT_USER, MQTT_PASS)){
      Serial.printf("Broker Conected!\n");
    } else {
      Serial.printf("Failed to connect, rc=%d, retrying.\n", mqtt.state());
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  tempHumSensor.begin();
  Wire.begin();
  lightSensor.begin();

  connectWiFi();
  syncTime();
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  connectBroker();
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) connectWiFi();
  if (!mqtt.connected()) connectBroker();
  mqtt.loop();

  if (millis() - lastPublish >= PUBLISH_INTERVAL) {
    lastPublish = millis();
    float temp = tempHumSensor.readTemperature();
    float hum = tempHumSensor.readHumidity();
    float lux = lightSensor.readLightLevel();
    int soilStrawberry = analogRead(SOIL_STRAWBERRY);
    int soilChili = analogRead(SOIL_CHILI);
    char payload[300];
    char topic[64];

    snprintf(payload, sizeof(payload),
        "{\"device\":\"%s\",\"timestamp\":\"%s\",\"temp\":%.1f,"
        "\"humidity\":%.1f,\"lux\":%.1f,\"soil_strawberry\":%d,\"soil_chili\":%d}",
        DEVICE_ID, getTimestamp(), temp, hum, lux, soilStrawberry, soilChili);

    snprintf(topic, sizeof(topic), "farm/%s/sensors", DEVICE_ID);
    mqtt.publish(topic, payload);
  }
  delay(100);
}