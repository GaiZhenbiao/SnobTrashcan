/*
  WiFi UDP Send and Receive String
 This sketch wait an UDP packet on localPort using the CC3200 launchpad
 When a packet is received an Acknowledge packet is sent to the client on port remotePort
 created 30 December 2012
 by dlf (Metodo2 srl)

 modified 1 July 2014
 by Noah Luskey
 */

#ifndef __CC3200R1M1RGC__
// Do not include SPI for CC3200 LaunchPad
#include <SPI.h>
#endif
#define PWMpin RED_LED
#define humanSensorButton PUSH1
#include <WiFi.h>

int lidAngle = 0;
int analogPin = A3;
int val = 0;

// your network name also called SSID
char ssid[] = "8-301";
// your network password
char password[] = "aokbike668";

unsigned int localPort = 2390;      // local port to listen on

char packetBuffer[255]; //buffer to hold incoming packet
char  ReplyBuffer[] = "acknowledged";       // a string to send back

WiFiUDP Udp;

void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(115200);
  pinMode(PWMpin, OUTPUT);
  pinMode(humanSensorButton, INPUT_PULLUP);
  attachInterrupt(humanSensorButton, buttonSendHumanPassedby, RISING);

  // attempt to connect to Wifi network:
  Serial.print("Attempting to connect to Network named: ");
  // print the network name (SSID);
  Serial.println(ssid);
  // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
  WiFi.begin(ssid, password);
  while ( WiFi.status() != WL_CONNECTED) {
    // print dots while we wait to connect
    Serial.print(".");
    delay(300);
  }

  Serial.println("\nYou're connected to the network");
  Serial.println("Waiting for an ip address");

  while (WiFi.localIP() == INADDR_NONE) {
    // print dots while we wait for an ip addresss
    Serial.print(".");
    delay(300);
  }

  Serial.println("\nIP Address obtained");
  printWifiStatus();

  Serial.println("\nWaiting for a connection from a client...");
  Udp.begin(localPort);
}

void loop() {

  // if there's data available, read a packet
  int packetSize = Udp.parsePacket();
  if (packetSize)
  {
    Serial.print("Received packet of size ");
    Serial.println(packetSize);
    Serial.print("From ");
    IPAddress remoteIp = Udp.remoteIP();
    Serial.print(remoteIp);
    Serial.print(", port ");
    Serial.println(Udp.remotePort());

    // read the packet into packetBufffer
    int len = Udp.read(packetBuffer, 255);
    if (len > 0) packetBuffer[len] = 0;
    Serial.println("Contents:");
    Serial.println(packetBuffer);

    // lidControl
    if(strncmp("Lid: ", packetBuffer, 5) == 0){
      char lidAngleString[4];
      strncpy(lidAngleString, packetBuffer+5, len-5);
      lidAngle = atoi(lidAngleString);
      Serial.println("Lid Angle set to:");
      Serial.println(lidAngle);
      setLidAngle(lidAngle);
    }

    // send a reply, to the IP address and port that sent us the packet we received
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(ReplyBuffer);
    Udp.endPacket();
  }
}

void setLidAngle(int newAngle){
  analogWrite(PWMpin, newAngle);
}

void autoHumanPassedby(){
  delay(20);
  val = analogRead(analogPin);    // read the input pin
  if(val>0){
    sendHumanPassedby();
    }
}

void buttonSendHumanPassedby(){
  delay(20);
  if(digitalRead(humanSensorButton)==HIGH){
    sendHumanPassedby();
  }
}

void sendHumanPassedby(){
  Serial.println("Sending human sensor passedby");
  Serial.print("To:");
  IPAddress remoteIp = Udp.remoteIP();
  Serial.print(remoteIp);
  Serial.print(", port ");
  Serial.println(Udp.remotePort());
  Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
  Udp.write("passby");
  Udp.endPacket();
}


void printWifiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
