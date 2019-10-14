import processing.serial.*;

class Gsr {
  
   private String port;
   private Serial myport;
   
   Gsr() {
     if ( Serial.list().length > 0 ) {
        port = new String( Serial.list()[0] );
        myport = new Serial(null, port, 9600);
     } else {
        port = new String("None");
     }
   }
   
   String getPort() {
     return port;
   }
}
