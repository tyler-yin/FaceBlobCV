
// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles


class ParticleSystem {
  ArrayList<Particle> particles;
  ArrayList<Particle> particles2;
  PVector origin;
  int never;
  int overayear;
  int ayear;
  int amonth;
  int twoweeks;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
    particles2 = new ArrayList<Particle>();
    never = 15; //50;
    overayear = 440;
    ayear = 82;
    amonth = 37;
    twoweeks = 53;
  }

  void run() {

    // NEVER DATA
    for (int i = 0; i < never; i++) {
      particles.add(new Particle(origin));
      Particle p = particles.get(i);
      PVector startposition = new PVector(width/2, height/2);

      p.run1();
      p.avoid(particles);
      if (oneface == true) {
        PVector face1 = new PVector(faceX, faceY);
        fill(50, 200, 200);
        p.seek(face1);
      }
      else {
        p.align(particles);
      }
    }

    // OVER A YEAR DATA
    // for (int i = 0; i < overayear; i++) {
    // particles2.add(new Particle(origin));
    // Particle p2 = particles2.get(i);
    // p2.run2();
    // p2.follow(path);
    // }
  }
}


class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float d1;
  float maxforce;
  float maxspeed;
  float d2;

  Particle(PVector l) {
    acceleration = new PVector (0, 0);
    velocity = new PVector(random(-5, 5), random(-2, 0));
    position = new PVector(random(0, width), random(0, height));
    maxspeed = 4;
    maxforce = 0.08;
  }

  void applyForce (PVector force) {
    acceleration.add(force);
  }

  // NEVER DATA ------------------------------------------------------------------
  void run1() {
    update();
    display();
  }

  // Method to update position for "never"
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed); // range
    position.add(velocity);
    acceleration.mult(0);
    if ((position.x > width) || (position.x < 0)) {
      velocity.x = velocity.x*-1;
    }
    if ((position.y > height) || (position.y < 0)) {
      velocity.y = velocity.y*-1;
    }
  }

  // Method to display data for "never"
  void display() {

    // Display as cross
    stroke(0, 255, 0);
    strokeWeight(1);
    int length = 4;
    line(position.x-length, position.y, position.x+length, position.y);
    line(position.x, position.y-length, position.x, position.y+length);

    // Display as Rectangles
    //stroke(0, 255, 0);
    //strokeWeight(1);
    //int length = 4;
    //rect(position.x, position.y, length, length);
  }

  // SEEK ------------------------------------------------------------------
  void seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    desired.setMag(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }

  // SEEK ------------------------------------------------------------------
  void align (ArrayList<Particle> particles) {
    float neighbordist = 45;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Particle other : particles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
  }

  // AVOID ------------------------------------------------------------------
  void avoid(ArrayList<Particle> particles) {
    PVector separateForce = separate(particles);
    separateForce.mult(2);
    applyForce(separateForce);
  }

  PVector separate (ArrayList<Particle> particles) {
    float desiredSeparation = 30;
    PVector sum = new PVector();
    int count = 0;
    for (Particle other : particles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredSeparation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }


  // OVER A YEAR DATA ------------------------------------------------------------------
  // void run2() {
  //   update2();
  //   display2();
  // }

  // Method to update position for "overayear"
  // void update2() {
  //
  //   velocity.add(acceleration);
  //   velocity.limit(maxspeed); // range
  //   position.add(velocity);
  //   acceleration.mult(0);
  //
  //   if ((position.x > width) || (position.x < 0)) {
  //     velocity.x = velocity.x*-1;
  //   }
  //   if ((position.y > height) || (position.y < 0)) {
  //     velocity.y = velocity.y*-1;
  //   }
  // }

  // Method to display data for "overayear"
  // void display2() {
  //   fill(200);
  //   d2= 1 + (sin(angle) * diameter/2) + diameter/2;
  //   rect(position.x, position.y, d2, d2);
  //   angle += 0.02; // pulsing rate
  // }

  // FOLLOW PATH STUFF -------------------------------------------------------------------------
//
//   void follow(Path p) {
//
//     // This could be based on speed
//     PVector predict = velocity.get();
//     predict.normalize();
//     predict.mult(25); // frames ahead of predicted position
//     PVector predictpos = PVector.add(position, predict);
//
//     // Now we must find the normal to the path from the predicted position
//
//     PVector normal = null;
//     PVector target = null;
//     float worldRecord = 1000000;  // Start with a very high record distance that can easily be beaten
//
//     // Loop through all points of the path
//     for (int i = 0; i < p.points.size(); i++) {
//
//       // Look at a line segment
//       PVector a = p.points.get(i);
//       PVector b = p.points.get((i+1)%p.points.size());
//
//       // Get the normal point to that line
//       PVector normalPoint = getNormalPoint(predictpos, a, b);
//
//       PVector dir = PVector.sub(b, a);
//       if (normalPoint.x < min(a.x, b.x) || normalPoint.x > max(a.x, b.x) || normalPoint.y < min(a.y, b.y) || normalPoint.y > max(a.y, b.y)) {
//         normalPoint = b.get();
//         // If we're at the end we really want the next line segment for looking ahead
//         a = p.points.get((i+1)%p.points.size());
//         b = p.points.get((i+2)%p.points.size());  // Path wraps around
//         dir = PVector.sub(b, a);
//       }
//
//       // How far away are we from the path?
//       float d = PVector.dist(predictpos, normalPoint);
//       // Did we beat the worldRecord and find the closest line segment?
//       if (d < worldRecord) {
//         worldRecord = d;
//         normal = normalPoint;
//
//         // Look at the direction of the line segment so we can seek a little bit ahead of the normal
//         dir.normalize();
//         // This is an oversimplification
//         // Should be based on distance to path & velocity
//         dir.mult(25);
//         target = normal.get();
//         target.add(dir);
//       }
//     }
//
//     // Only if the distance is greater than the path's radius do we bother to steer
//     if (worldRecord > p.radius) {
//       seek(target);
//     }
//   }
//
//   PVector getNormalPoint(PVector p, PVector a, PVector b) {
//     // Vector from a to p
//     PVector ap = PVector.sub(p, a);
//     // Vector from a to b
//     PVector ab = PVector.sub(b, a);
//     ab.normalize(); // Normalize the line
//     // Project vector "diff" onto line by using the dot product
//     ab.mult(ap.dot(ab));
//     PVector normalPoint = PVector.add(a, ab);
//     return normalPoint;
//   }
 }
