import java.io.BufferedWriter;
import java.io.FileWriter;

static class log4p {
  private static BufferedWriter output;
  private boolean initialized;
  private String name;
  private static log4p instance;
  
  private log4p() {
    String hd=System.getProperty("user.home");
    
    name = new String( hd+File.separator+"gsr_experiment.csv" );
    initialized = false;
    open();
  }
  
  public static log4p getInstance() {
    if (instance == null) {
      instance = new log4p();
    }
    
    return instance;
  }
  
  boolean isInitialized() {
    return initialized;
  }
  
  void setName( String name ) {
    String hd=System.getProperty("user.home");
    String newname=new String( hd+File.separator+name );
    if ( initialized ) {
      if ( this.name != newname ) {
        close();
        this.name = newname;
        open();
      }
    }
  }
  
  String getName() {
    return name;
  }
    
  void open() {
    if ( initialized ) {
      close();
    }
    
    initialized = false;
    
    try {
       output = new BufferedWriter( new FileWriter( name ) );
       initialized = true;
    } catch (Exception e ) {
      println( "Exception occured while opening file \""+name+"\" : "+e.getMessage() );
    } finally {
      if (initialized) {
        try {
           output.write( "Opened file \""+name+"\"" );
           output.flush();
        } catch (IOException e) {
          println( "IOException occurred while writing to file \""+name+"\" : "+e.getMessage() );
        }
      } else {
        println( "Failed to write to file" );
      }
    }
  }
  
  void open( String name ) {
    setName( name );
    open();
  }
  
  void close() {
    if (initialized) {
      try {
         output.flush();
         output.close();
      } catch (IOException e ) {
        println( "IOException occurred while closing file \""+name+"\"" );
      }
      
      initialized = false;
    }
  }
  
  void logMsg( String message ) {
    if (initialized) {
      String logMessage = extend( message );
      
      try {
         output.write( logMessage );
      } catch (IOException e) {
        println( "IOException occurred while writing message \""+message+"\" to file \""+name+"\"" );
      }
    } else {
      println( "Could not write: "+message );
    }
  }
  
  String extend( String message ) {
     long timestamp = System.currentTimeMillis();
      
     int seconds = (int) ((timestamp / 1000) % 60);
     int minutes = (int) ((timestamp / 1000*60) % 60);

     String outmsg = new String( minutes+":"+seconds+" : "+message );
     
     return outmsg;
  }
   
}
