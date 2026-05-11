#include <WiFi.h>
#include <WebServer.h>

// WiFi Configuration - Connect to RPi Hotspot
const char* ssid = "CatfishMonitor";  // Your RPi hotspot name
const char* password = "catfish123";  // Your RPi hotspot password

// ESP32 IP Configuration (static IP to match app)
IPAddress local_IP(192, 168, 100, 114);
IPAddress gateway(192, 168, 100, 113);
IPAddress subnet(255, 255, 255, 0);

// PIN MAPPING (Based on your KiCad Schematic)
const int RING_CTRL = 13;   // Ring Light Control
const int BUZZER_CTRL = 12; // Buzzer Control
const int LED1_CTRL = 14;   // RED LED (Initialization)
const int LED2_CTRL = 27;   // GREEN LED (Ready)

// Web Server on port 80
WebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // Initialize Pins
  pinMode(RING_CTRL, OUTPUT);
  pinMode(BUZZER_CTRL, OUTPUT);
  pinMode(LED1_CTRL, OUTPUT);
  pinMode(LED2_CTRL, OUTPUT);
  
  // Start with everything OFF
  digitalWrite(RING_CTRL, LOW);
  digitalWrite(BUZZER_CTRL, LOW);
  
  // --- STAGE 1: INITIALIZATION ---
  digitalWrite(LED1_CTRL, HIGH); // Red ON
  digitalWrite(LED2_CTRL, LOW);  // Green OFF
  Serial.println("Initializing... RED LED ON");
  
  // Connect to WiFi
  Serial.println("Connecting to WiFi...");
  WiFi.config(local_IP, gateway, subnet);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("\nWiFi Connected!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());
  
  // Setup Web Server Endpoints
  server.on("/ringlight", HTTP_POST, handleRingLight);
  server.on("/buzzer", HTTP_POST, handleBuzzer);
  server.on("/", HTTP_GET, handleRoot);
  server.on("/status", HTTP_GET, handleStatus);
  
  // Start Server
  server.begin();
  Serial.println("Server started on port 80");
  
  // --- STAGE 2: READY TO GO ---
  digitalWrite(LED1_CTRL, LOW);  // Red OFF
  digitalWrite(LED2_CTRL, HIGH); // Green ON
  Serial.println("Ring Light Control Ready! GREEN LED ON");
}

void loop() {
  server.handleClient();
}

// Handle Ring Light Control
void handleRingLight() {
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    Serial.println("Received: " + body);
    
    // Parse JSON body
    if (body.indexOf("\"state\":\"on\"") >= 0 || body.indexOf("\"state\": \"on\"") >= 0) {
      digitalWrite(RING_CTRL, HIGH);
      Serial.println("Ring Light: ON");
      server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"on\"}");
    } 
    else if (body.indexOf("\"state\":\"off\"") >= 0 || body.indexOf("\"state\": \"off\"") >= 0) {
      digitalWrite(RING_CTRL, LOW);
      Serial.println("Ring Light: OFF");
      server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"off\"}");
    } 
    else {
      server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"Invalid state\"}");
    }
  } else {
    server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"No body\"}");
  }
}

// Handle Buzzer Control
void handleBuzzer() {
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    Serial.println("Received: " + body);
    
    if (body.indexOf("\"state\":\"on\"") >= 0 || body.indexOf("\"state\": \"on\"") >= 0) {
      digitalWrite(BUZZER_CTRL, HIGH);
      Serial.println("Buzzer: ON");
      server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"on\"}");
    } 
    else if (body.indexOf("\"state\":\"off\"") >= 0 || body.indexOf("\"state\": \"off\"") >= 0) {
      digitalWrite(BUZZER_CTRL, LOW);
      Serial.println("Buzzer: OFF");
      server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"off\"}");
    } 
    else {
      server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"Invalid state\"}");
    }
  } else {
    server.send(400, "application/json", "{\"status\":\"error\",\"message\":\"No body\"}");
  }
}

// Handle Root Endpoint
void handleRoot() {
  server.send(200, "text/plain", "ESP32 Ring Light Control Server");
}

// Handle Status Endpoint
void handleStatus() {
  String ringState = digitalRead(RING_CTRL) ? "on" : "off";
  String buzzerState = digitalRead(BUZZER_CTRL) ? "on" : "off";
  server.send(200, "application/json", "{\"status\":\"success\",\"ringlight\":\"" + ringState + "\",\"buzzer\":\"" + buzzerState + "\"}");
}
