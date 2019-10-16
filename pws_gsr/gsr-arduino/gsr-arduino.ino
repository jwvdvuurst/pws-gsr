int a = 0;

void setup() {
  
  Serial.begin(9600);
  
}

void loop(){
//  if (Serial.available()) {
//    int inbyte = Serial.read();
//
//    if (inbyte == 65) {
       a=analogRead(0);
       Serial.write(a);
//    }
//  }
}
