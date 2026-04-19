#include <Arduino.h>
#include <DHT.h>
#include <Wire.h>
#include <BH1750.h>
#include <WiFi.h>

// Wifi
const char* wifiSSID = WIFI_SSID;
const char* wifiPass = WIFI_PASS;
const char* mqttHost = MQTT_HOST;

// Sensors
#define DHT_PIN D2
#define DHT_TYPE DHT22
#define SOIL_STRAWBERRY A0
#define SOIL_CHILI A1

DHT tempHumSensor(DHT_PIN, DHT_TYPE);
BH1750 lightSensor;
WiFiClient wifiClient;

void connectWiFi() {
    Serial.printf("Connecting to Wifi...\n");
    WiFi.begin(WIFI_SSID, WIFI_PASS);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.printf("Wifi Connected!\n");
}

void setup() {
    Serial.begin(115200);
    tempHumSensor.begin();
    Wire.begin();
    lightSensor.begin();

    connectWiFi();
}

void loop() {
    float temp = tempHumSensor.readTemperature();
    float hum = tempHumSensor.readHumidity();
    float lux = lightSensor.readLightLevel();
    int soilStrawberry = analogRead(SOIL_STRAWBERRY);
    int soilChili = analogRead(SOIL_CHILI);

    Serial.printf("Temp: %.1fC  Hum: %.1f%%  Lux: %.1f  SoilStrawberry: %d  SoilChili: %d\n", temp, hum, lux, soilStrawberry, soilChili);

    delay(2000);
}