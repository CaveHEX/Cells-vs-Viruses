float splitStr = 1.0;
float growthSpeed = 0.02;
float growthAmp = growthSpeed * 0.5;
float radiusThreshold = 10;
float childrenRadEx = 0.5;
float radiusMin = radiusThreshold * childrenRadEx;
float consumeRate = radiusMin * 0.2;


class Cell {

  PVector pos;
  PVector vel;
  PVector acc;
  float friction = 0.98;
  float radius;
  color col;

  boolean done = false;
  boolean undergoesMitosis = false;

  float seed = random(1000, 9999);

  Cell() {
    pos = new PVector(width/2, height/2);
    vel = new PVector();
    acc = new PVector();
    radius = 0;
  }

  Cell(PVector pos, float radius) {
    this.pos = pos.copy();
    vel = new PVector();
    acc = new PVector();
    this.radius = radius * random(1);
    col = palette.col(map(PVector.dist(pos, center), 0, width*0.5, 0, 1.2));
  }

  Cell(PVector pos, PVector vel, float radius, color col) {
    this.pos = pos.copy();
    this.vel = vel.copy();
    this.radius = radius * random(1);
    acc = new PVector();
    this.col = col;
  }

  void update() {
    float angle = atan2(center.y - pos.y, center.x - pos.x) + HALF_PI;
    PVector force = new PVector(cos(angle), sin(angle)).mult(0.01);
    this.applyForce(force);
    
    this.physics();
    this.warp();

    radius += growthSpeed + random(-growthAmp, growthAmp);

    if ( radius > radiusThreshold ) {
      this.mitosis();
    }
  }

  void render() {
    float step = TWO_PI / 20;
    push();
    translate(pos.x, pos.y, pos.z);
    rotateZ(seed + frameCount * 0.001);
    beginShape(TRIANGLE_FAN);
    noStroke();
    fill(0, 0);
    vertex(0, 0, 0);
    fill(col);
    for ( float a = -step; a < TWO_PI; a += step ) {
      float rad = radius + sin(a*50) * 3;
      rad = radius;
      float x = rad * cos(a);
      float y = rad * sin(a);
      vertex(x, y, 0);
    }
    endShape();
    pop();
  }

  void physics() {
    vel.add(acc);
    vel.mult(friction);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void mitosis() {
    done = true;
    undergoesMitosis = true;
  }

  void warp() {
    if ( pos.x < -radius ) {
      pos.x = width + radius;
    }
    if ( pos.x > width + radius ) {
      pos.x = - radius;
    }
    if ( pos.y < -radius ) {
      pos.y = height + radius;
    }
    if ( pos.y > height + radius ) {
      pos.y = - radius;
    }
  }

  float getConsumed() {
    this.radius -= consumeRate;
    if ( radius <= 0.0 ) {
      done = true;
    }
    return consumeRate * 5;
  }

  boolean isDone() {
    return done;
  }
}


class Cells {

  ArrayList<Cell> cells;
  ArrayList<Cell> toAdd;
  int count = 4000;

  Cells() {
    this.cells = new ArrayList<Cell>();
    this.toAdd = new ArrayList<Cell>();

    for ( int i = 0; i < count; ++i ) {
      this.cells.add(new Cell(new PVector(random(width), random(height)), 5));
    }
  }

  void update() {
    toAdd.clear();
    Iterator<Cell> it = this.cells.iterator();
    while ( it.hasNext() ) {
      Cell c = it.next();
      c.update();
      
      if ( c.undergoesMitosis ) {
        this.mitosis(c);
      }
      if ( c.isDone() ) {
        it.remove();
      }
    }

    for ( Cell c : toAdd ) {
      cells.add(c);
    }
  }

  void render() {
    for ( Cell c : cells ) {
      c.render();
    }
  }

  void run() {
    this.update();
    this.render();
  }

  void mitosis(Cell c) {
    float childrenRad = c.radius * childrenRadEx;
    PVector dir = PVector.random2D();
    dir.mult(splitStr);
    toAdd.add(new Cell(c.pos, dir, childrenRad, c.col));
    dir.mult(-1);
    toAdd.add(new Cell(c.pos, dir, childrenRad, c.col));
  }
}
