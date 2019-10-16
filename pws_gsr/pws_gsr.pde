//   Daniel Shiffman
//   http:  codingtra.in
//   http:  patreon.com/codingtrain
//   Code for: https:  youtu.be/AaGK-fj-BAM

import processing.serial.*;
import java.io.BufferedWriter;
import java.io.FileWriter;


//Gsr gsr;
Snake s;
int scl = 20;
int round = 1;

int maxheight;
int maxwidth;
int starttime;
int endtime;
int round_duration;

float volt;

String port;

PVector food;

//   private String port;
   private Serial myport;
   
   private IntList measurements;
   private boolean gsrinitialized;
   private boolean loginitialized;
   private int session;

   private BufferedWriter logfile;

   private String name;

  void setup() {
  size(600, 700);
  s = new Snake();
  frameRate(10);
  pickLocation();

  maxheight = height - 100;
  maxwidth = width;
  
//  gsr = new Gsr();
  initGsr();
  initlog4p();
  
  round_duration = 1;
  
  starttime = millis();
  endtime = millis() + (round_duration*60*1000);

}

  
void initlog4p() {
  String hd=System.getProperty("user.home");
  
  name = new String( hd+File.separator+"gsr_experiment.csv" );
  loginitialized = false;
  open();
}

boolean isLogInitialized() {
  return loginitialized;
}

void setName( String name ) {
  String hd=System.getProperty("user.home");
  String newname=new String( hd+File.separator+name );
  if ( loginitialized ) {
    if ( name != newname ) {
      close();
      name = newname;
      open();
    }
  }
}

String getName() {
  return name;
}
  
void open() {
  if ( loginitialized ) {
    close();
  }
  
  loginitialized = false;
  
  try {
     logfile = new BufferedWriter( new FileWriter( name ) );
     loginitialized = true;
  } catch (Exception e ) {
    println( "Exception occured while opening file \""+name+"\" : "+e.getMessage() );
  } finally {
    if (loginitialized) {
      try {
         logfile.write( "Opened file \""+name+"\"" );
         logfile.flush();
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
  if (loginitialized) {
    try {
       logfile.flush();
       logfile.close();
    } catch (IOException e ) {
      println( "IOException occurred while closing file \""+name+"\"" );
    }
    
    loginitialized = false;
  }
}

void logMsg( String message ) {
  if (loginitialized) {
    String logMessage = extend( message );
    
    try {
       logfile.write( logMessage+"\n" );
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
 
 void initGsr() {
   gsrinitialized=false;
   session = 0;
   
   if ( Serial.list().length > 0 ) {
      port = new String( Serial.list()[0] );
      try {
         myport = new Serial( this, port, 9600);
         gsrinitialized=true;
         myport.write("A");
      } catch (Exception e) {
        logMsg( "Exception "+e.toString()+" occurred during opening of serial port." );
        logMsg( e.getMessage() );
      }
   } else {
      port = new String("None");
   }
 
   measurements = new IntList();
 }
 
 String getPort() {
   return port;
 }
 
 boolean isGsrInitialized() {
   return gsrinitialized;
 }
 
 int getNumMeasurements() {
   return measurements.size();
 }
  
 void getMeasurement() {
    if (gsrinitialized) {
       if (myport.available() > 0) {
          int measure = myport.read();
          volt = (measure * 5) / 1024;
          
          measurements.append(measure);
          myport.write("A");
          logMsg( new String( "M;"+getNumMeasurements() +";" + measure + ";" + volt ) );
       }
    } else {
      logMsg( "Not initialized, not taking a measurement" );
    }
 }

void pickLocation() {
  int cols = maxwidth/scl;
  int rows = maxheight/scl;
  food = new PVector(floor(random(cols)), floor(random(rows)));
  food.mult(scl);
}

void mousePressed() {
  s.total++;
}

void draw() {
  background(51);

  if (s.eat(food)) {
    pickLocation();
  }
  s.death();
  s.update();
  s.show();

  fill(255, 0, 100);
  rect(food.x, food.y, scl, scl);

  stroke( 255, 0, 0 );
  line( 0, maxheight+1, maxwidth, maxheight+1 );

  textSize(32);
  text( getPort(), 10, maxheight + 40 );
  
  String rndstr = new String( "Round: "+round );
  text( rndstr, 10, maxheight + 80 );
 
  int now = millis();
  int remain = endtime - now;
  
  int seconds = (int) (remain / 1000) % 60 ;
  int minutes = (int) ((remain / (1000*60)) % 60);
  
  String timestr = new String( "Time "+minutes+":"+ seconds );
  text( timestr, 300, maxheight + 40 );
    
  if (gsrinitialized) {
    text( "g", 300, maxheight + 80 );
  } else {
    text( "-", 300, maxheight + 80 );
  }
  
  if (loginitialized ) {
    text( "l", 340, maxheight + 80 );
  } else {
    text( "-", 340, maxheight + 80 );    
  }
  
  text( str(volt), 380, maxheight + 80 );
  
  getMeasurement();
  
  if (remain <= 0) {
    if (round == 1) {
      starttime = millis();
      endtime = starttime + (round_duration*60*1000);
      round = 2;
    } else {
      noLoop();
    }
  }
}

void keyPressed() {
  if (round == 1) {
    if (keyCode == UP) {
      s.dir(0, -1);
    } else if (keyCode == DOWN) {
      s.dir(0, 1);
    } else if (keyCode == RIGHT) {
      s.dir(1, 0);
    } else if (keyCode == LEFT) {
      s.dir(-1, 0);
    }
  } else {
    if (keyCode == RIGHT) {
      s.dir(0, -1);
    } else if (keyCode == UP) {
      s.dir(0, 1);
    } else if (keyCode == LEFT) {
      s.dir(1, 0);
    } else if (keyCode == DOWN) {
      s.dir(-1, 0);
    }
  }
  if (key == 'r' || key == 'R') {
    if ( round == 1 ) {
      round = 2;
    } else {
      round = 1;
    }
  }
  if (key == 'q' || key == 'Q' ) {
    close();
    exit();
  }
  if (key == 'l' || key == 'L' ) {
    if ( isLooping() ) {
      noLoop();
    } else {
      loop();
    }
  }
}
