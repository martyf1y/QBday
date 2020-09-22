// Makes all particles draw the next word
void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(messageWidth, messageHeight);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(fontSize);
  pg.textAlign(CENTER);
  PFont font = createFont(fontName, fontSize);
  pg.textFont(font);
  pg.text(word, 0, 0, messageWidth, messageHeight);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to
  color realQColor = color(239, 193, 57);

  for (int i = 0; i < (messageWidth*messageHeight)-1; i+=10) {

    // Only continue if the pixel is not blank
    if (pg.pixels[i] != 0) {
      // Convert index to its coordinates
      int x = i % messageWidth;
      int y = i / messageWidth;

      // Create a new particle
      Particle newParticle = new Particle();     

      newParticle.pos.x = x+ messagePositionX-messageWidth/2;
      newParticle.pos.y = y + messagePositionY-messageHeight/2;
      // Assign the particle's new target to seek
      newParticle.target.x = int(random(-particleWidth/2 + 65, particleWidth/2 - 75));

      
      float radiusSquared = int(((particleWidth/2-58)) * ((particleWidth/2-58)));
      float xSquared = int((newParticle.target.x) * (newParticle.target.x));
      newParticle.target.y = int(sqrt((radiusSquared - xSquared)));
      //   newParticle.target.x = newParticle.target.x + width/2-maskSize/2;
      newParticle.target.x += width/2;
      int ran = int(random(0,2));
      if(ran==1){
        newParticle.target.y*=-1;
      }
      newParticle.target.y += height/2 - 28;  
      newParticle.maxSpeed = random(5.0, 8.0);
      newParticle.maxForce = newParticle.maxSpeed*0.025;
      newParticle.particleSize = random(3, 6);
      newParticle.colorBlendRate = random(0.0025, 0.03);

      particles.add(newParticle);

      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = realQColor;
      newParticle.colorWeight = 0;
    }
  }
  sizepercent = particles.size();
  // MIGHT NEED THIS FOR DEBUGGING
  // Kill off any left over particles
  /* if (particleIndex < particleCount) {
   for (int i = particleIndex; i < particleCount; i++) {
   Particle particle = particles.get(i);
   particle.kill();
   }
   } */
}

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);

  float closeEnoughTarget = 40;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = newColor;
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;
  boolean areWeLeft;

  void move() {
     
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    // float easing = 0.05;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }
    //this.maxSpeed = distance*easing; 
    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    // steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);

    if (distance <= 10) {
      kill();
    }
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      // PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      //  this.target.x = target.x;
      //  this.target.y = target.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;
      this.isKilled = true;
    }
  }
}