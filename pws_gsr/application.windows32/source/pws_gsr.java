import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import java.io.BufferedWriter; 
import java.io.FileWriter; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pws_gsr extends PApplet {

//   Daniel Shiffman
//   http:  codingtra.in
//   http:  patreon.com/codingtrain
//   Code for: https:  youtu.be/AaGK-fj-BAM

Gsr gsr;
Snake s;
int scl = 20;
int round = 1;

int maxheight;
int maxwidth;
int starttime;
int endtime;
int round_duration;

String port;
log4p output;

PVector food;

public void setup() {
  
  s = new Snake();
  frameRate(10);
  pickLocation();

  maxheight = height - 100;
  maxwidth = width;
  
  gsr = new Gsr();
  
  round_duration = 1;
  
  starttime = millis();
  endtime = millis() + (round_duration*60*1000);
  output = log4p.getInstance();
}

public void pickLocation() {
  int cols = maxwidth/scl;
  int rows = maxheight/scl;
  food = new PVector(floor(random(cols)), floor(random(rows)));
  food.mult(scl);
}

public void mousePressed() {
  s.total++;
}

public void draw() {
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
  text( gsr.getPort(), 10, maxheight + 40 );
  
  String rndstr = new String( "Round: "+round );
  text( rndstr, 10, maxheight + 80 );
 
  int now = millis();
  int remain = endtime - now;
  
  int seconds = (int) (remain / 1000) % 60 ;
  int minutes = (int) ((remain / (1000*60)) % 60);
  
  String timestr = new String( "Time "+minutes+":"+ seconds );
  text( timestr, 300, maxheight + 40 );
    
  if (gsr.isInitialized() ) {
    text( "I", 300, maxheight + 80 );
  } else {
    text( "-", 300, maxheight + 80 );
  }
  
  if (output.isInitialized() ) {
    text( "I", 340, maxheight + 80 );
  } else {
    text( "_", 340, maxheight + 80 );    
  }
  
  text( output.getName(), 100, 100 );
 
  output.logMsg( "Take measurement" );
  gsr.getMeasurement();
  
  if (remain <= 0) {
    if (round == 1) {
      starttime = millis();
      endtime = starttime + (round_duration*60*1000);
      round = 2;
    } else {
      ;
    }
  }
}

public void keyPressed() {
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
}


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
   
   public String getPort() {
     return port;
   }
   
   public boolean isInitialized() {
     return initialized;
   }
   
   public int getNumMeasurements() {
     return measurements.size();
   }
    
   public void getMeasurement() {
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
// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/AaGK-fj-BAM

class Snake {
  float x = 0;
  float y = 0;
  float xspeed = 1;
  float yspeed = 0;
  int total = 0;
  ArrayList<PVector> tail = new ArrayList<PVector>();

  Snake() {
  }

  public boolean eat(PVector pos) {
    float d = dist(x, y, pos.x, pos.y);
    if (d < 1) {
      total++;
      return true;
    } else {
      return false;
    }
  }

  public void dir(float x, float y) {
    xspeed = x;
    yspeed = y;
  }

  public void death() {
    for (int i = 0; i < tail.size(); i++) {
      PVector pos = tail.get(i);
      float d = dist(x, y, pos.x, pos.y);
      if (d < 1) {
        println("starting over");
        total = 0;
        tail.clear();
      }
    }
  }

  public void update() {
    //println(total + " " + tail.size());
    if (total > 0) {
      if (total == tail.size() && !tail.isEmpty()) {
        tail.remove(0);
      }
      tail.add(new PVector(x, y));
    }

    x = x + xspeed*scl;
    y = y + yspeed*scl;
    
    if (x < 0) {
      x = maxwidth-scl;
    }
    if (x > maxwidth-scl) {
      x=0;
    } 
    if (y < 0) {
      y = maxheight-scl;
    }
    if (y > maxheight-scl) {
      y=0;
    } 
    
//    x = constrain(x, 0, width-scl);
//    y = constrain(y, 0, (height-100)-scl);
  }

  public void show() {
    stroke(0);
    fill(255);
    for (PVector v : tail) {
      rect(v.x, v.y, scl, scl);
    }
    rect(x, y, scl, scl);
  }
}



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
  
  public boolean isInitialized() {
    return initialized;
  }
  
  public void setName( String name ) {
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
  
  public String getName() {
    return name;
  }
    
  public void open() {
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
  
  public void open( String name ) {
    setName( name );
    open();
  }
  
  public void close() {
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
  
  public void logMsg( String message ) {
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
  
  public String extend( String message ) {
     long timestamp = System.currentTimeMillis();
      
     int seconds = (int) ((timestamp / 1000) % 60);
     int minutes = (int) ((timestamp / 1000*60) % 60);

     String outmsg = new String( minutes+":"+seconds+" : "+message );
     
     return outmsg;
  }
   
}
  public void settings() {  size(600, 700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--stop-color=#cccccc", "pws_gsr" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
