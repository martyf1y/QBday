import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.*;

// Global variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int pixelSteps = 1; // Amount of pixels to skip
boolean drawAsPoints = false;
int wordIndex = 0;
int messageWidth;
int messageHeight;
int messagePositionX;
int messagePositionY;
int fontSize = 50;
color bgColor = color(255, 100);
String fontName = "National-SemiBold";
int counterTwit = 0;
float maskSize = 468.0;
PImage QLogo;
PImage QEllipse;
PGraphics QMasking;
PGraphics frame;
float particleWidth = maskSize;
float sizepercent = 0;
Twitter twitter;
String searchString = "#qturns5";
List<Status>tweets;
int currentTweet;
String[] theTweets = new String[100];

//Status status;
String thisTwit;
boolean goAgain = true;
boolean waitType = false;
boolean runAway = false;
boolean findNewWord = false;
int stringCount = 0;
String message;
int updateCount = 0;

///// Word timers
int wordEndTime = 7000;
int wordTimer;
String defaultMessage; 
color newColor;
color[] QColor = new color[5];
boolean fadeQ = false;
int fade = 255;

/// txt stuff
String[] loadtxt;
String[] txtMessages;
int txtcount = 0;

void setup()
{
//  size(1280, 720);
  background(255);
noCursor();
fullScreen();
  messagePositionX = width/2;
  messagePositionY = height/2;
  messageWidth = int(width/1.5);
  messageHeight = int(height/1.5);
  QLogo = loadImage("Q_Logo.png");
  QLogo.resize(0, height-30);
  frame = createGraphics(QLogo.width, QLogo.height);
  QMasking = createGraphics(QLogo.width, QLogo.height);

  frame.beginDraw();
  frame.background(0);
 // frame.translate(QLogo.width/2, QLogo.height/2);
 // frame.rotate(radians(millis())/2)
  frame.imageMode(CENTER);
  frame.image(QLogo, QLogo.width/2, QLogo.height/2);
  frame.endDraw();
  
  PGraphics Cirlce = createGraphics(QLogo.width, QLogo.height);
  Cirlce.beginDraw();
  Cirlce.background(0);
  // rotate_light.translate(width/2, height/2);
  // rotate_light.rotate(-point_dir());
  Cirlce.ellipseMode(CENTER);
  Cirlce.ellipse(QLogo.width/2, QLogo.height/2, maskSize, maskSize);
  Cirlce.filter(BLUR, 2);
  Cirlce.endDraw();
  QEllipse = Cirlce.get();

  //twitter
  ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("");
  cb.setOAuthConsumerSecret("");
  cb.setOAuthAccessToken("");
  cb.setOAuthAccessTokenSecret("");

  // Twitter twitter = new TwitterFactory(cb.build()).getInstance();
   TwitterFactory tf = new TwitterFactory(cb.build());

    twitter = tf.getInstance();

    getNewTweets();
  currentTweet = 0;
  thread("refreshTweets");

  defaultMessage = "SHARE YOUR BIRTHDAY WISH FOR Q: Simply tweet your wish today using #QTurns5 and we'll display it tonight on our big birthday screen!";

  QColor[0] = color(35, 177, 221);
  QColor[1] = color(118, 61, 144);
  QColor[2] = color(250, 198, 0);
  QColor[3] = color(238, 237, 238);
  QColor[4] = color(224, 0, 105);
  
  loadtxt = loadStrings("bday.txt");
  txtMessages = split(loadtxt[0], '*' );
  
  frameRate(60);
}

void draw()
{
    background(0);

    qLogoMasking();
    updateMessage();

if(fadeQ && wordTimer < millis()-wordEndTime/2){
  fade -=10;
}
if(fade <=0){
  fadeQ = false;
  maskSize = 468;
}
imageMode(CENTER);
tint(255, fade);
  image(frame, width/2, height/2); // The Q
noTint();
  if (runAway && !waitType) {
    for (int x = particles.size() -1; x > -1; x--) {
      // Simulate and draw pixels
      Particle particle = particles.get(x);
      particle.move();  
      particle.draw();
      
      // Remove any dead pixels out of bounds
      if (particle.isKilled) {
        //if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
        particles.remove(particle);
        maskSize += (3/sizepercent)*285;
        // }
      }
    }
    if (particles.size() == 0) {
      runAway = false; 
      waitType = false;
      wordTimer = millis(); // resets time
      fadeQ = true;
    }
  }

  fill(newColor);
  //textSize(fontSize);
  textAlign(CENTER);
  PFont font = createFont(fontName, fontSize);
  textFont(font);
  if (waitType) {
    text(message, messagePositionX-messageWidth/2, messagePositionY-messageHeight/2, messageWidth, messageHeight);
   if(!runAway){
    wordTimer = millis(); // resets timer 
   }
}
 // println("Frames: " + frameRate);
//    println("Tweets: " + tweets.size());
}

void qLogoMasking(){
  // DRAW FLASHLIGHT MASK
  QMasking.beginDraw();
  QMasking.background(0);
  QMasking.imageMode(CENTER);
  QMasking.image(QEllipse, QLogo.width/2, QLogo.height/2-28, maskSize-36, maskSize);
  
  QMasking.endDraw();

  // APPLY FLASHLIGHT MASK TO FRAME
  mask(frame, QMasking); 
  
  
}

void mask(PImage target, PImage mask) {
  mask.loadPixels();
  target.loadPixels();
  if (mask.pixels.length != target.pixels.length) {
    println("Images are not the same size");
  } else {
    for (int i=0; i<target.pixels.length; i++) {
      target.pixels[i] = ((mask.pixels[i] & 0xff) << 24) | (target.pixels[i] & 0xffffff);
    }
    target.updatePixels();
  }
}

// Show next word
void mousePressed() {
  if (mouseButton == LEFT && !runAway) {
    runAway = true;
    if (runAway) {
      nextWord(message);
    }
  }
}

// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
  
   if(key == 'q'){
    maskSize +=30;
  }
  else if(key == 'w'){
    maskSize -=3;
  }
}
