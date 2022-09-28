/// In this file, you will have to implement seek and waypoint-following
/// The relevant locations are marked with "TODO"

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
   PVector direction;
   ArrayList<PVector> waypoints;
   boolean stillInRadius = true;
   int currentTarget = 0;
   
   Boid(PVector position, float heading, float max_speed, float max_rotational_speed, float acceleration, float rotational_acceleration)
   {
     this.kinematic = new KinematicMovement(position, heading, max_speed, max_rotational_speed);
     this.last_crumb = millis();
     this.acceleration = acceleration;
     this.rotational_acceleration = rotational_acceleration;
   }

   void update(float dt)
   {
     if (target != null)
     {  
        // TODO: Implement seek here
        
        //This makes a vector with the direction our boid needs to go to
        PVector direction = PVector.sub(target, kinematic.position);
        
        //atan2(direction.y, direction.x) will return the direction we need to go in radians
        
        //print direction we need to go and the direction we are facing right now
        //println(atan2(direction.y, direction.x) + " " + normalize_angle_left_right(kinematic.getHeading()));
        
        float directionalThreshold = .1;
        //You have to normalize this too or the boid goes the wrong way sometimes
        float angleToTarget = normalize_angle_left_right(atan2(direction.y, direction.x) - normalize_angle_left_right(kinematic.getHeading()));
        float arrivalThreshold = 60.0;
        
        //This just draws a circle for visual debugging purposes
        circle(target.x, target.y, 3);
        
        //prints the angle to the target
        //println(angleToTarget);
        
        //if the angle is larger than the threshold in the positive direction, rotate counterclockwise
        if (angleToTarget > directionalThreshold && direction.mag() > 30) {
          kinematic.increaseSpeed(0.0, +1);
          
        } else if (angleToTarget > directionalThreshold && direction.mag() > 15) {
          kinematic.increaseSpeed(0.0, +.5);
          
        //if the angle is smaller than the threshold in the negative direction, rotate clockwise
        } else if (angleToTarget < -directionalThreshold && direction.mag() > 30) {
          kinematic.increaseSpeed(0.0, -1);
          
        } else if (angleToTarget < -directionalThreshold && direction.mag() > 15) {
          kinematic.increaseSpeed(0.0, -.5);
          
        //if the angle is within our threshold, stop our rotational velocity by rotating opposite
        } else if (directionalThreshold > angleToTarget) {
          
          if (kinematic.getRotationalVelocity() > 0) {
            kinematic.increaseSpeed(0.0, -kinematic.getRotationalVelocity());
          }
          else if (kinematic.getRotationalVelocity() < 0) {
            kinematic.increaseSpeed(0.0, kinematic.getRotationalVelocity()); 
          }
        }
        
        
        
        
        //if the target is outside its arrival threshold, accelerate. 
        //if the target is inside its arrival threshold, accelerate backwards until the speed is 0.
        if (direction.mag() > arrivalThreshold) {
          kinematic.increaseSpeed(1,0);
          
        } else if (direction.mag() < arrivalThreshold) {
          
          
          //Need more specific code here to handle arrivals correctly
          //TODO: change this to slow down less / not at all if the angle to the next target is not large
          
          //This handles starting / stopping if there are more targets
          
          //This ensures that we don't crash because waypoints is null
          if (waypoints != null) {
            
            //this checks if there's another target to go to
            if (currentTarget + 1 < waypoints.size()) {
              
              //if so, change the speed depending on the angle to the next target
              //This part isn't really implemented at all, and I need sleep
              
              if (kinematic.getSpeed() < 40 && direction.mag() > 30) {
                kinematic.increaseSpeed(1,0);
              } else if (kinematic.getSpeed() < 20 && direction.mag() > 15) {
                kinematic.increaseSpeed(.75,0);
              } else if (kinematic.getSpeed() < 10 && direction.mag() > 5) {
                kinematic.increaseSpeed(.5,0);
              } else if (kinematic.getSpeed() < 5 && direction.mag() < 5) {
                //This should ensure that the boid's speed can be dropped to exactly 0 so we don't have stuttering
                kinematic.increaseSpeed(-kinematic.getSpeed(),0);
              } else {
                kinematic.increaseSpeed(-1,0);
              }
              
            } else {
            
              //if no more targets to check, do the normal calculation
              if (kinematic.getSpeed() < 40 && direction.mag() > 30) {
                kinematic.increaseSpeed(1,0);
              } else if (kinematic.getSpeed() < 20 && direction.mag() > 15) {
                kinematic.increaseSpeed(.75,0);
              } else if (kinematic.getSpeed() < 10 && direction.mag() > 5) {
                kinematic.increaseSpeed(.5,0);
              } else if (kinematic.getSpeed() < 5 && direction.mag() < 5) {
                //This should ensure that the boid's speed can be dropped to exactly 0 so we don't have stuttering
                kinematic.increaseSpeed(-kinematic.getSpeed(),0);
              } else {
                kinematic.increaseSpeed(-1,0);
              }
            
            }
          
          } else {
          
            //if waypoints is null, do normal things
            println("waypoints is null");
            //This code should trigger if there's only one target left
            if (kinematic.getSpeed() < 40 && direction.mag() > 30) {
              kinematic.increaseSpeed(1,0);
            } else if (kinematic.getSpeed() < 20 && direction.mag() > 15) {
              kinematic.increaseSpeed(.75,0);
            } else if (kinematic.getSpeed() < 10 && direction.mag() > 5) {
              kinematic.increaseSpeed(.5,0);
            } else if (kinematic.getSpeed() < 5 && direction.mag() < 5) {
              //This should ensure that the boid's speed can be dropped to exactly 0 so we don't have stuttering
              kinematic.increaseSpeed(-kinematic.getSpeed(),0);
            } else {
              kinematic.increaseSpeed(-1,0);
            }
          
          }
          
        }
        
        
        
        //drawing a line for testing purposes
        //line(kinematic.position.x, kinematic.position.y, kinematic.position.x + direction.x, kinematic.position.y + direction.y);
        
        //handling going to multiple targets
        
        //initial check exists because waypoints will be null for a single target
        if (waypoints != null) {
          //If within 5 units, move to next target
          if (direction.mag() < 5) {
            //This ensures that the same target can't trigger moving to the next target twice
            if (stillInRadius == false) {
              //this ensures that waypoints get cleared after finishing checking all targets
              if (currentTarget < waypoints.size() - 1) {
                currentTarget++;
              } else {
                currentTarget = 0;
                waypoints = null;
              }
            }
            stillInRadius = true;
            if (waypoints != null) {
              seek(waypoints.get(currentTarget));
            }
          } else {
            stillInRadius = false; 
          }
          
        }
        
        
        
        
        
        
        
        
        
        
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
   
   void follow(ArrayList<PVector> waypoints)
   {
      
      this.waypoints = waypoints;
      
      seek(waypoints.get(0));
      
      
      
      
      
      
      
   }
}
