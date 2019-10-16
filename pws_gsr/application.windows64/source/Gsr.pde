import processing.serial.*;

class Gsr {
  
   private String port;
   private Serial myport;
   
   private IntList measurements;
   private boolean initialized;

   private int session;
   
   Gsr() {
     initialized=false;
     session = 0;
     
     if ( Serial.list().length > 0 ) {
        port = new String( Serial.list()[0] );
        try {
           myport = new Serial(null, port, 9600);
           initialized=true;
           myport.write("a");
        } catch (Exception e) {
//          output.logMsg( "Exception "+e.toString()+" occurred during opening of serial port." );
//          output.logMsg( e.getMessage() );
        }
     } else {
        port = new String("None");
     }
 
     measurements = new IntList();
   }
   
   String getPort() {
     return port;
   }
   
   boolean isInitialized() {
     return initialized;
   }
   
   int getNumMeasurements() {
     return measurements.size();
   }
    
   void getMeasurement() {
      if (initialized) {
         if (myport.available() > 0) {
            int measure = myport.read();
            measurements.append(measure);
            myport.write("a");
            output.logMsg( new String( getNumMeasurements() +";" + measure ) );
         }
      } else {
        output.logMsg( "Not initialized, not taking a measurement" );
      }
   }
}
