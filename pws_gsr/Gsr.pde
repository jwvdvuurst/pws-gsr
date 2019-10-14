import processing.serial.*;

class Gsr {
  
   private String port;
   private Serial myport;
   private PrintWriter output;
   private int timestamp;
   
//   private ArrayList<float> measurements;
   
   Gsr() {
     if ( Serial.list().length > 0 ) {
        port = new String( Serial.list()[0] );
        myport = new Serial(null, port, 9600);
     } else {
        port = new String("None");
     }
     
     output = createWriter("gsr_experiment.csv");
//     measurements = new ArrayList<float>();
   }
   
   String getPort() {
     return port;
   }
   
   
}
