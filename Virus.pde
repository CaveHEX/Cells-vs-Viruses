float arriveRange = 100;
float maxSpeed = 6;
float maxForce = 0.05;
float decay = 1;

class Virus {

  PVector pos;
  PVector vel;
  PVector acc;
  float friction = 0.98;
  float radius;

  float lifeSpan = 255;

  boolean reproduce = false;

  Virus(PVector pos) {
    this.pos = pos.copy();
    vel = new PVector();
    acc = new PVector();
    this.radius = 15;
  }

  void update() {
    Cell cell = closestTarget();
    arrive(cell.pos);

    if ( PVector.dist(pos, cell.pos) < radius + cell.radius ) {
      this.consume(cell.getConsumed());
      if ( cell.isDone() ) {
        if ( random(1) > 0.9 ) {
          reproduce = true;
        }
      }
    }

    this.physics();

    lifeSpan -= decay;
    lifeSpan = constrain(lifeSpan, 0, 255);
  }

  void render() {
    float step = TWO_PI / 35;
    push();
    translate(pos.x, pos.y, pos.z);

    beginShape(TRIANGLE_FAN);
    noStroke();
    fill(0, 0);
    vertex(0, 0, 0);
    fill(255, 0, 0, lifeSpan);
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

  Cell closestTarget() {
    Cell winner = new Cell();
    float winnerDist = 99999;

    for ( Cell c : cells.cells ) {
      float dist = PVector.dist(pos, c.pos);
      if ( dist < winnerDist ) {
        winner = c;
        winnerDist = dist;
      }
    }

    return winner;
  }

  void arrive(PVector target) {
    PVector desired = PVector.sub(target, pos);
    float dist = desired.mag();
    desired.normalize();
    if ( dist < arriveRange ) {
      float m = map(dist, 0, arriveRange, 0, maxSpeed);
      desired.mult(m);
    } else {
      desired.mult(maxSpeed);
    }
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxForce);

    applyForce(steer);
  }

  boolean isDone() {
    return lifeSpan < 0.01;
  }

  void consume(float food) {
    lifeSpan += food;
  }
}

class Viruses {

  ArrayList<Virus> viruses;
  ArrayList<Virus> toAdd;
  int count = 4;

  Viruses() {
    this.viruses = new ArrayList<Virus>();
    this.toAdd = new ArrayList<Virus>();

    for ( int i = 0; i < count; ++i ) {
      for ( float a = 0; a < TWO_PI; a += TWO_PI/15 ) {
        PVector off = PVector.random2D().mult(random(20));
        this.viruses.add(new Virus(new PVector(width * 0.5 + cos(a)*height/2, height*0.5 + sin(a)*height/2).add(off)));
      }
    }
  }

  void update() {
    toAdd.clear();

    Iterator<Virus> it = this.viruses.iterator();
    while ( it.hasNext() ) {
      Virus v = it.next();
      v.update();
      if ( v.reproduce ) {
        v.reproduce = false;
        toAdd.add(new Virus(v.pos));
      }
      if ( v.isDone() ) {
        it.remove();
      }
    }

    for ( Virus v : toAdd ) {
      viruses.add(v);
    }
  }

  void render() {
    for ( Virus v : this.viruses ) {
      v.render();
    }
  }

  void run() {
    this.update();
    this.render();
  }
}
