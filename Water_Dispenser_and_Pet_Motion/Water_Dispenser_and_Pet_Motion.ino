#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// --- Pin Definitions ---
#define WATER_SENSOR_PIN 36
#define PIR_SENSOR_PIN 13
#define TRIG_PIN 5
#define ECHO_PIN 18
#define RELAY_PIN 25

// --- WiFi Configuration ---
const char* ssid = "ssid";
const char* password = "pass";

// --- Server Endpoints ---
const char* logPetURL = "https://humancc.site/ndhos/Pet_Water_Dispenser/log_pet.php";
const char* waterLogURL = "https://humancc.site/ndhos/Pet_Water_Dispenser/log_water.php";

// --- Thresholds ---
const int waterThreshold = 1000;  // analog value
const int overflowDistance = 5;   // cm

// --- Timing ---
unsigned long lastSensorCheck = 0;
const unsigned long sensorInterval = 10000;

void setup() {
  Serial.begin(115200);

  // Pin Modes
  pinMode(WATER_SENSOR_PIN, INPUT);
  pinMode(PIR_SENSOR_PIN, INPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Relay OFF initially (active LOW)

  // WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
}

void loop() {
  unsigned long currentMillis = millis();

  // --- Auto-reconnect to WiFi ---
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    WiFi.disconnect();
    WiFi.begin(ssid, password);
    unsigned long startAttemptTime = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 10000) {
      delay(500);
      Serial.print(".");
    }
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nReconnected to WiFi!");
    } else {
      Serial.println("\nFailed to reconnect.");
      return;
    }
  }

  // --- Combined 10s Sensor Check ---
  if (currentMillis - lastSensorCheck >= sensorInterval) {
    lastSensorCheck = currentMillis;

    // --- PIR Check ---
    if (digitalRead(PIR_SENSOR_PIN) == HIGH) {
      Serial.println("PIR: Pet detected");
      logPetPresence("PetDetected");
    } else {
      Serial.println("PIR: No pet detected");
      logPetPresence("NoPet");
    }

    // --- Water Check ---
    int waterLevel = analogRead(WATER_SENSOR_PIN);
    long distance = readUltrasonicDistance();
    String status = "";

    Serial.printf("Water Level: %d, Distance: %ld cm\n", waterLevel, distance);

    if (waterLevel < waterThreshold) {
      digitalWrite(RELAY_PIN, LOW);
      status = "Low";
      Serial.println("Status: Low, Relay ON");
    } else if (waterLevel >= waterThreshold && distance <= overflowDistance) {
      digitalWrite(RELAY_PIN, HIGH);
      status = "High";
      Serial.println("Status: High, Relay OFF");
    } else if (waterLevel >= waterThreshold && distance > overflowDistance) {
      digitalWrite(RELAY_PIN, HIGH);
      status = "Normal";
      Serial.println("Status: Normal, Relay OFF");
    }

    if (status != "") {
      logWaterStatus(status);
    }
  }
}

// --- Ultrasonic Distance ---
long readUltrasonicDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  return pulseIn(ECHO_PIN, HIGH) * 0.034 / 2;
}

// --- Log Pet Detection (with status) ---
void logPetPresence(String petStatus) {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient https;

  String url = String(logPetURL) + "?status=" + petStatus;
  https.begin(client, url);
  int httpCode = https.GET();

  if (httpCode > 0) {
    Serial.println("Pet log sent!");
    //Serial.println(https.getString());
  } else {
    Serial.println("Failed to log pet: " + https.errorToString(httpCode));
  }
  https.end();
}

// --- Log Water Status ---
void logWaterStatus(String status) {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient https;

  String url = String(waterLogURL) + "?water_status=" + status;
  https.begin(client, url);
  int httpCode = https.GET();

  if (httpCode > 0) {
    Serial.println("Water status logged!");
    Serial.println(https.getString());
  } else {
    Serial.println("Failed to log water: " + https.errorToString(httpCode));
  }
  https.end();
}
