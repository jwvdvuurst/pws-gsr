//   Daniel Shiffman //<>//
//   http:  codingtra.in
//   http:  patreon.com/codingtrain
//   Code for: https:  youtu.be/AaGK-fj-BAM

import processing.serial.*;    
import java.io.BufferedWriter;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.FileReader;


//Gsr gsr;
Snake s;
int scl = 20;
int round = 1;
float basevolt = 5.0f;       //5v
float averagecurrent = 0.5f; //500mA max.

int maxheight;
int maxwidth;
int starttime;
int endtime;
int round_duration;

float volt;
float conductivity;

String port;

PVector food;

Serial myport;

IntList measurements;
boolean gsrinitialized;
boolean loginitialized;
boolean showdetails = false;
int session;

BufferedWriter logfile;

String name;

String hd=System.getProperty("user.home");

void setup() {
  size(600, 800);
  s = new Snake();
  frameRate(10);
  pickLocation();

  maxheight = height - 200;
  maxwidth = width;

  File sessions = new File(hd+File.separator+"sessions.txt");

  try {
    session = 1;

    if (!sessions.exists()) {
      println( "Session file not found, create new one" );
      sessions.createNewFile();
      FileWriter writer = new FileWriter(sessions);
      writer.write(str(session)+"\n");
      writer.flush();
      writer.close();
    } else {
      println( "Session file found, reading and updating it" );
      BufferedReader reader = new BufferedReader(new FileReader(sessions));

      String line;
      line=reader.readLine();
      if (line != null) {
        session = int(line);
      } else {
        session = 1;
      }
      reader.close();

      session++;

      FileWriter writer = new FileWriter(sessions, false );
      writer.write(str(session)+"\n");
      writer.flush();
      writer.close();
    }
  } 
  catch (IOException e) {
    println( "IOException session file read/write" );
    logMsg( "Could not read/write session file" );
  }

  //  gsr = new Gsr();
  initGsr();
  initlog4p();

  round_duration = 1;

  starttime = millis();
  endtime = millis() + (round_duration*60*1000);
}


void initlog4p() {    
  name = new String( hd+File.separator+"gsr_experiment"+session+".csv" );
  loginitialized = false;
  open();
}

boolean isLogInitialized() {
  return loginitialized;
}

void setName( String name ) {
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
  } 
  catch (Exception e ) {
    println( "Exception occured while opening file \""+name+"\" : "+e.getMessage() );
  } 
  finally {
    if (loginitialized) {
      try {
        logfile.write( "Opened file \""+name+"\"" );
        logfile.flush();
      } 
      catch (IOException e) {
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
    } 
    catch (IOException e ) {
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
    } 
    catch (IOException e) {
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

  String outmsg = String.format( "%02d:%02d;%s", minutes, seconds, message );
//  String outmsg = new String( minutes+":"+seconds+" : "+message );

  return outmsg;
}

void initGsr() {
  gsrinitialized=false;

  if ( Serial.list().length > 0 ) {
    port = new String( Serial.list()[0] );
    try {
      myport = new Serial( this, port, 9600);
      gsrinitialized=true;
//      myport.write(65);
    } 
    catch (Exception e) {
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

int getMeasurement() {
  int measurement = 0;
  int avgmeasurement = 0;
  int num = 0;
  if (gsrinitialized) {
    while (myport.available() > 0) {
       measurement += myport.read();
       num++;
    }
    
    if (num > 0) {
      avgmeasurement = floor( measurement / num );
    }
  }
  
  return avgmeasurement;
}

void processMeasurement( int measurement ) {
   volt = (measurement * basevolt) / 1024.0;
   float resistance = volt / averagecurrent; 
   conductivity = (1.0f / resistance) * 100;

   measurements.append(measurement);
//      myport.write(65);
   logMsg( new String( "M;"+getNumMeasurements() + ";" + measurement + ";" + volt + ";" + conductivity ) );
}

//void getMeasurement() {
//  if (gsrinitialized) {
//    if (myport.available() > 0) {
//      int measure = myport.read();
//      volt = (measure * basevolt) / 1024.0;
//      float resistance = volt / averagecurrent; 
//      conductivity = 1/resistance;

//      measurements.append(measure);
////      myport.write(65);
//      logMsg( new String( "M;"+getNumMeasurements() + ";" + measure + ";" + volt + ";" + conductivity ) );
//    }
//  } else {
//    logMsg( new String( "M;"+getNumMeasurements() + ";---;---;---" ) );
//  }
//}

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

  String sessionstr = new String ( "Session "+session );
  text( sessionstr, 300, maxheight + 80 );

  if (showdetails) {
    if (gsrinitialized) {
      if (loginitialized) {
        text( "gl", 250, maxheight + 80 );
      } else {
        text( "g-", 250, maxheight + 80 );
      }
    } else {
      if (loginitialized) {
        text( "-l", 250, maxheight + 80 );
      } else {
        text( "--", 250, maxheight + 80 );
      }
    }
  
    int measurement = getMeasurement();
    processMeasurement( measurement );

    String mstr = new String( "M: "+String.format("%04d", measurement) + " V: "+String.format("%.2f", volt)+" C: "+String.format("%.2f", conductivity) );

    text( mstr, 10, maxheight+120 );
    
    text( s.asString(), 10, maxheight+160 );
  } else {
    int measurement = getMeasurement();
    processMeasurement( measurement );  
  }

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
    logMsg( "Switch round" );
    if ( round == 1 ) {
      round = 2;
    } else {
      round = 1;
    }
  }
  if (key == 'q' || key == 'Q' ) {
    logMsg( "Requested to quit" );
    close();
    exit();
  }
  if (key == 'l' || key == 'L' ) {
    if ( isLooping() ) {
      logMsg( "stop looping" );
      noLoop();
    } else {
      logMsg( "start looping" );
      loop();
    }
  }
  if (key == 'd' || key == 'D' ) {
    logMsg( "Switch details" );
    showdetails = !showdetails;
  }
}
