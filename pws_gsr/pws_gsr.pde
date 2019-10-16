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

void setup() {
  size(600, 700);
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
}
