/// In this file, you will have to implement seek and waypoint-following
/// The relevant locations are marked with "TODO"
import java.util.*;
class Crumb
{
  PVector position;
  Crumb(PVector position)
  {
    this.position = position;
  }
  void draw()
  {
    fill(255);
    noStroke();
    circle(this.position.x, this.position.y, CRUMB_SIZE);
  }
}

class Boid
{
  Crumb[] crumbs = {};
  int last_crumb;
  float acceleration;
  float rotational_acceleration;
  KinematicMovement kinematic;
  PVector target;

  Boid(PVector position, float heading, float max_speed, float max_rotational_speed, float acceleration, float rotational_acceleration)
  {
    this.kinematic = new KinematicMovement(position, heading, max_speed, max_rotational_speed);
    this.last_crumb = millis();
    this.acceleration = acceleration;
    this.rotational_acceleration = rotational_acceleration;
  }

  void update(float dt)
  {
    
    if (waypoints != null) {
      for (int i = 0; i<waypoints.size(); i++)
      {
        text(i, waypoints.get(i).x + 10, waypoints.get(i).y + 10);
      }
    }
    if (target != null)
    {
      // TODO: Implement seek here
      


      //This makes a vector with the direction our boid needs to go to
      PVector direction = PVector.sub(target, kinematic.position);

      //atan2(direction.y, direction.x) will return the direction we need to go in radians

      //print direction we need to go and the direction we are facing right now
      //println(atan2(direction.y, direction.x) + " " + normalize_angle_left_right(kinematic.getHeading()));

      float directionalThreshold = .1;
      float angleToTarget = normalize_angle_left_right(atan2(direction.y, direction.x) - normalize_angle_left_right(kinematic.getHeading()));
      float arrivalThreshold = 60.0;

      //This just draws a circle for visual debugging purposes
      circle(target.x, target.y, 3);

      //prints the angle to the target
      //println(angleToTarget);

      //if the angle is larger than the threshold in the positive direction, rotate counterclockwise
      if (angleToTarget >= .1) {
       //println("positive angle");
        kinematic.increaseSpeed(0.0, 2);


        //if the angle is smaller than the threshold in the negative direction, rotate clockwise
      } else if (angleToTarget < -.1) {
        kinematic.increaseSpeed(0.0, -1);

        //if the angle is within our threshold, stop our rotational velocity by rotating opposite
      } else if (directionalThreshold > angleToTarget) {

        if (kinematic.getRotationalVelocity() > 0) {
          kinematic.increaseSpeed(0.0, -1);
        } else if (kinematic.getRotationalVelocity() < 0) {
          kinematic.increaseSpeed(0.0, 1);

        }
      }



      //Sometimes our Boid just goes and does weird things and I don't know why

      //if the target is outside its arrival threshold, accelerate.
      //if the target is inside its arrival threshold, accelerate backwards until the speed is 0.
      if (direction.mag() > arrivalThreshold) {
        //println("main if");
        kinematic.increaseSpeed(.5, 0);
      } else if (direction.mag() < arrivalThreshold) {
        //Need more specific code here to handle arrivals correctly

        if (kinematic.getSpeed() < 40 && direction.mag() > 30) {
          //println("if 1");
          kinematic.increaseSpeed(1, 0);
        } else if (kinematic.getSpeed() < 20 && direction.mag() > 15) {
          //println("if .75");
          kinematic.increaseSpeed(.75, 0);
        } else if (kinematic.getSpeed() < 10 && direction.mag() > 5) {
          //println("if .5");
          kinematic.increaseSpeed(.5, 0);
        } else if (kinematic.getSpeed() < 5 && direction.mag() < 5) {
          //println("if -kin");
          //This should ensure that the boid's speed can be dropped to exactly 0 so we don't have stuttering

          kinematic.increaseSpeed(-kinematic.getSpeed(), 0);
        } else {
          //println("else");
          kinematic.increaseSpeed(-1, 0);
        }
      }



      //drawing a line for testing purposes
      //line(kinematic.position.x, kinematic.position.y, kinematic.position.x + direction.x, kinematic.position.y + direction.y);
    }

    // place crumbs, do not change
    if (LEAVE_CRUMBS && (millis() - this.last_crumb > CRUMB_INTERVAL))
    {
      this.last_crumb = millis();
      this.crumbs = (Crumb[])append(this.crumbs, new Crumb(this.kinematic.position));
      if (this.crumbs.length > MAX_CRUMBS)
        this.crumbs = (Crumb[])subset(this.crumbs, 1);
    }

    // do not change
    this.kinematic.update(dt);

    draw();
  }

  void draw()
  {
    for (Crumb c : this.crumbs)
    {
      c.draw();
    }

    fill(255);
    noStroke();
    float x = kinematic.position.x;
    float y = kinematic.position.y;
    float r = kinematic.heading;
    circle(x, y, BOID_SIZE);
    // front
    float xp = x + BOID_SIZE*cos(r);
    float yp = y + BOID_SIZE*sin(r);

    // left
    float x1p = x - (BOID_SIZE/2)*sin(r);
    float y1p = y + (BOID_SIZE/2)*cos(r);

    // right
    float x2p = x + (BOID_SIZE/2)*sin(r);
    float y2p = y - (BOID_SIZE/2)*cos(r);
    triangle(xp, yp, x1p, y1p, x2p, y2p);
  }

  void seek(PVector target)
  {
    this.target = target;
  }
int count = 0;
 
  //void follow(ArrayList<PVector> waypoints)
  //{
     
  //  //println("func count " + count);
  //  if(count > waypoints.size() - 1){
  //  this.target = waypoints.get(0);
  //  return;
  //  }
  //  else {
  //  // TODO: change to follow *all* waypoints
  //  println("count " + count);
  //  this.target = waypoints.get(count);
  //  PVector temp = waypoints.remove(count);
  //  count++;
  //  //count--;
    
  //  follow(waypoints);
  //  }
    
  //}
  void follow(ArrayList<PVector> waypoints)
  {
    if(waypoints.size() == 0) return;
    println("vector " + waypoints);   
    println("reverse vector " + waypoints);
    int count = 0;
    PVector stop = waypoints.get(0);
    this.seek(stop);
    
    
    
    
    PVector temp = waypoints.remove(0);
    println("temp vector " + waypoints);
    //follow(waypoints);
   
    //this.target = waypoints.get(0);
     //do{
       
       
     // println("in while " + count);
     ////this.target = waypoints.get(count);
     //this.target = waypoints.get(count);
     //if(PVector.sub(this.target,this.kinematic.position).mag() < 40){
     //   count++;
     //}
    
  
     //}while(count < waypoints.size());
    //count++;
    //for(int i = 1; i < waypoints.size(); i++){
    //    println("dist " + PVector.sub(this.target,this.kinematic.position).mag());
    //    if(PVector.sub(this.target,this.kinematic.position).mag() < 40){
    //    this.seek(waypoints.get(i));
    //    this.target = waypoints.get(i);
    //    }
    
    }

}
