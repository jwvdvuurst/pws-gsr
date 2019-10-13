//   Daniel Shiffman
//   http:  codingtra.in
//   http:  patreon.com/codingtrain
//   Code for: https:  youtu.be/AaGK-fj-BAM

import processing.serial.*;
Serial myport;

Snake s;
int scl = 20;
int round = 1;

int maxheight;
int maxwidth;

String port;

PVector food;

void setup() {
  size(600, 700);
  s = new Snake();
  frameRate(10);
  pickLocation();

  maxheight = height - 100;
  maxwidth = width;
  
  if ( Serial.list().length > 0 ) {
     port = new String( Serial.list()[0] );
     myport = new Serial(this, port, 9600);
  } else {
    port = new String("None");
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
  text( port, 10, maxheight + 40 );
  
  String rndstr = new String( "Round: "+round );
  text( rndstr, 10, maxheight + 80 );
  
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
