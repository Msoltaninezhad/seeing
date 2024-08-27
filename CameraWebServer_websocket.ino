#include "esp_camera.h"
#include <WiFi.h>
#include <WebSocketsServer.h>

#define CAMERA_MODEL_AI_THINKER
#include "camera_pins.h"

// Wi-Fi credentials
const char *ssid = "Mohammad";
const char *password = "123456789";

// WebSocket server
WebSocketsServer webSocket = WebSocketsServer(81);

// Define the button pin
#define BUTTON_PIN 14

bool buttonState = HIGH;
unsigned long pressStartTime = 0;
bool isLongPress = false;

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.printf("[%u] Disconnected!\n", num);
            break;
        case WStype_CONNECTED:
            {
                IPAddress ip = webSocket.remoteIP(num);
                Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
                // Send message to client
                webSocket.sendTXT(num, "Connected");
            }
            break;
        case WStype_TEXT:
            Serial.printf("[%u] get Text: %s\n", num, payload);
            break;
        case WStype_BIN:
            Serial.printf("[%u] get binary length: %u\n", num, length);
            break;
        case WStype_ERROR:
        case WStype_FRAGMENT_TEXT_START:
        case WStype_FRAGMENT_BIN_START:
        case WStype_FRAGMENT:
        case WStype_FRAGMENT_FIN:
            break;
    }
}

void setup() {
    Serial.begin(115200);
    Serial.setDebugOutput(true);
    Serial.println();

    // Initialize the button pin
    pinMode(BUTTON_PIN, INPUT_PULLUP);

    // Connect to Wi-Fi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.println("WiFi connected");

    // Initialize camera
    camera_config_t config;
    config.ledc_channel = LEDC_CHANNEL_0;
    config.ledc_timer = LEDC_TIMER_0;
    config.pin_d0 = Y2_GPIO_NUM;
    config.pin_d1 = Y3_GPIO_NUM;
    config.pin_d2 = Y4_GPIO_NUM;
    config.pin_d3 = Y5_GPIO_NUM;
    config.pin_d4 = Y6_GPIO_NUM;
    config.pin_d5 = Y7_GPIO_NUM;
    config.pin_d6 = Y8_GPIO_NUM;
    config.pin_d7 = Y9_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.pin_pclk = PCLK_GPIO_NUM;
    config.pin_vsync = VSYNC_GPIO_NUM;
    config.pin_href = HREF_GPIO_NUM;
    config.pin_sscb_sda = SIOD_GPIO_NUM;
    config.pin_sscb_scl = SIOC_GPIO_NUM;
    config.pin_pwdn = PWDN_GPIO_NUM;
    config.pin_reset = RESET_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.xclk_freq_hz = 20000000;
    config.pixel_format = PIXFORMAT_JPEG;

    if(psramFound()){
        config.frame_size = FRAMESIZE_UXGA;
        config.jpeg_quality = 10;
        config.fb_count = 2;
    } else {
        config.frame_size = FRAMESIZE_SVGA;
        config.jpeg_quality = 12;
        config.fb_count = 1;
    }

    // Camera init
    esp_err_t err = esp_camera_init(&config);
    if (err != ESP_OK) {
        Serial.printf("Camera init failed with error 0x%x", err);
        return;
    }

    // Start WebSocket server
    webSocket.begin();
    webSocket.onEvent(webSocketEvent);

    Serial.print("WebSocket Server Ready! Use 'ws://");
    Serial.print(WiFi.localIP());
    Serial.println(":81' to connect");
}

void loop() {
    webSocket.loop();  // Handle WebSocket events
    handleButtonPress();  // Handle button press events
    delay(10);
}

void handleButtonPress() {
    bool currentButtonState = digitalRead(BUTTON_PIN);

    if (currentButtonState == LOW && buttonState == HIGH) {
        pressStartTime = millis();
        isLongPress = false;
    } 
    else if (currentButtonState == LOW && buttonState == LOW) {
        if (millis() - pressStartTime > 2000) {
            isLongPress = true;
        }
    } 
    else if (currentButtonState == HIGH && buttonState == LOW) {
        if (isLongPress) {
            Serial.println("Long press detected");
            webSocket.broadcastTXT("long_press");
        } else {
            Serial.println("Short press detected");
            webSocket.broadcastTXT("short_press");

            // Capture and send image on short press
            camera_fb_t * fb = esp_camera_fb_get();
            if(!fb) {
                Serial.println("Camera capture failed");
                webSocket.broadcastTXT("Camera capture failed");
                return;
            }
            webSocket.broadcastBIN(fb->buf, fb->len);
            esp_camera_fb_return(fb);
            Serial.println("Image sent to client");
        }
    }

    buttonState = currentButtonState;
}
