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

  boolean eat(PVector pos) {
    float d = dist(x, y, pos.x, pos.y);
    if (d < 1) {
      total++;
      return true;
    } else {
      return false;
    }
  }

  void dir(float x, float y) {
    xspeed = x;
    yspeed = y;
  }

  void death() {
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

  void update() {
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

  void show() {
    stroke(0);
    fill(255);
    for (PVector v : tail) {
      rect(v.x, v.y, scl, scl);
    }
    rect(x, y, scl, scl);
  }
  
  String asString() {
    String out = new String( "s("+x+","+y+") ds("+xspeed+","+yspeed+")" );
    return out;
  }
}
