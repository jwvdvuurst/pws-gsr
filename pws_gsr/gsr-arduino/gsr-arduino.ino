int analogPin = A0;
int a = 0;

void setup() {
  Serial.begin(9600);
  Serial.flush();
  analogReference(DEFAULT);
}

void loop(){
//  if (Serial.available()) {
//    int inbyte = Serial.read();

//    if (inbyte == 65) {
       a=analogRead(analogPin);
       Serial.write(a);
       delay(100);
//    }
//  }
}
