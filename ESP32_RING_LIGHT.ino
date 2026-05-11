#include <WiFi.h>
#include <WebServer.h>

// WiFi Configuration - Connect to RPi Hotspot
const char* ssid = "CatfishMonitor";  // Your RPi hotspot name
const char* password = "catfish123";  // Your RPi hotspot password

// ESP32 IP Configuration (static IP to match app)
IPAddress local_IP(192, 168, 100, 114);
IPAddress gateway(192, 168, 100, 113);
IPAddress subnet(255, 255, 255, 0);

// Ring Light GPIO Pin
const int RING_LIGHT_PIN = 2;  // Change to your actual GPIO pin

// Status LED Pins
const int RED_LED_PIN = 4;     // Red LED - Initializing
const int GREEN_LED_PIN = 5;   // Green LED - Ready

// Web Server on port 80
WebServer server(80);

void setup() {
  Serial.begin(115200);
  
  // Initialize Ring Light Pin
  pinMode(RING_LIGHT_PIN, OUTPUT);
  digitalWrite(RING_LIGHT_PIN, LOW);  // Start with ring light OFF
  
  // Initialize Status LEDs
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
  
  // Turn on RED LED (Initializing)
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(GREEN_LED_PIN, LOW);
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
  server.on("/", HTTP_GET, handleRoot);
  server.on("/status", HTTP_GET, handleStatus);
  
  // Start Server
  server.begin();
  Serial.println("Server started on port 80");
  
  // Switch to GREEN LED (Ready)
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, HIGH);
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
      digitalWrite(RING_LIGHT_PIN, HIGH);
      Serial.println("Ring Light: ON");
      server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"on\"}");
    } 
    else if (body.indexOf("\"state\":\"off\"") >= 0 || body.indexOf("\"state\": \"off\"") >= 0) {
      digitalWrite(RING_LIGHT_PIN, LOW);
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

// Handle Root Endpoint
void handleRoot() {
  server.send(200, "text/plain", "ESP32 Ring Light Control Server");
}

// Handle Status Endpoint
void handleStatus() {
  String state = digitalRead(RING_LIGHT_PIN) ? "on" : "off";
  server.send(200, "application/json", "{\"status\":\"success\",\"state\":\"" + state + "\"}");
}
