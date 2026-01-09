#include <DHT.h>
#define DHTPIN 8
#define DHTTYPE DHT11
#define START_BYTE 0xAA
#define STOP_BYTE  0x55
#define ERROR_STOP 0xFF


DHT dht(DHTPIN, DHTTYPE);


unsigned long lastReadTime = 0;
const unsigned long READ_INTERVAL = 5000;  //citire la 5 secunde
int errorCount = 0;  //contor erori consecutive


void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ; //asteapta conexiunea seriala
  }
  dht.begin();
  delay(2000); //stabilizare senzor
}


void loop() {
  unsigned long currentTime = millis();
  
  //citeste senzorul la interval fix
  if (currentTime - lastReadTime >= READ_INTERVAL) {
    lastReadTime = currentTime;
    
    float tempC = dht.readTemperature();
    
    if (!isnan(tempC)) {
      //valoare valida - trimite pachet normal
      sendTemperature(tempC);
      errorCount = 0;
    } else {
      //eroare citire - trimite pachet eroare
      errorCount++;
      sendErrorPacket();
      Serial.print("Eroare senzor! (Count: ");
      Serial.print(errorCount);
      Serial.println(")");
      
      //dupa 3 erori consecutive reinitializeaza senzorul
      if (errorCount >= 3) {
        Serial.println("Reinitializare senzor...");
        dht.begin();
        delay(2000);
        errorCount = 0;
      }
    }
  }
}

void sendTemperature(float temp) {
  //converteste temperatura
  int16_t tempX100 = (int16_t)(temp * 100);
  uint8_t msb = (tempX100 >> 8) & 0xFF;
  uint8_t lsb = tempX100 & 0xFF;

  //trimite pachet START | MSB | LSB | STOP
  Serial.write(START_BYTE); //0xAA
  Serial.write(msb);
  Serial.write(lsb);
  Serial.write(STOP_BYTE); //0x55
  Serial.flush();

  Serial.print("   Trimis: ");
  Serial.print(temp);
  Serial.println(" °C");
}

void sendErrorPacket() {
  //trimite pachet eroare START | 0xFF | 0xFF | ERROR_STOP
  Serial.write(START_BYTE); //0xAA
  Serial.write(0xFF);
  Serial.write(0xFF);
  Serial.write(ERROR_STOP); //0xFF
  Serial.flush(); 
}