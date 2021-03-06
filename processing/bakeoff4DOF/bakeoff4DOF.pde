import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 200f;
float startX = 0;
float startY = 0;
boolean moveSquare = false;
int num = 3;
float mx[] = new float[num];
float my[] = new float[num];

int trialCount = 20; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
float permrot = 0;

final int screenPPI = 518; //what is the DPI of the screen you are using
//Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

private class Bar 
{
  float x = 0;
  float y = 0;
}


Bar sizing = new Bar();
Bar rotating = new Bar();

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  //size does not let you use variables, so you have to manually compute this
  size(1036, 1813); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 90); //random rotation between 0 and 360
    t.z = ((i%20  )+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
    permrot = t.rotation;
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(0); //background is dark grey
  fill(255);
  noStroke();

  //if (startTime == 0)
  //  startTime = millis();

  if (userDone)
  {
    textSize(52);
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }
  
  for (int i = 1; i < num; i++) {
    mx[i-1] = mx[i];
    my[i-1] = my[i];
  }
  
  mx[num-1] = mouseX;
  my[num-1] = mouseY;

  

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  startX = mouseX;
  startY = mouseY;
  

  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  rotate(radians(-1));
  fill(255); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);

  popMatrix();
  
  
  if(checkForDistance()) fill(0,200,0);
  else fill(200,0,0);
  ellipse(width/2 - 150, inchesToPixels(.4f), 100, 100);
  if(checkForRotation()) fill(0,200,0);
  else fill(200,0,0);
  ellipse(width/2, inchesToPixels(.4f), 100, 100);
  if(checkForSize()) fill(0,200,0);
  else fill(200,0,0);
  ellipse(width/2 + 150, inchesToPixels(.4f), 100, 100);
  fill(255);
  textSize(35);
  text("Position", width/2 - 150,inchesToPixels(.6f));
  text("Rotation", width/2,inchesToPixels(.6f));
  text("Size", width/2 + 150,inchesToPixels(.6f));
  textSize(100); 
  fill(200);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.2f));
  if(checkForSuccess()) fill(0,200,0);
  else fill(200,0,0);
  rect(width/2, height-125, width - 50, 200);
  fill(255);
  textSize(125);
  text("Next", width/2 ,height-90);
  
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);
  //float newSize = t.z * 2;

  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
  
  rotate(radians(t.rotation+screenRotation));
  fill(255);
  
  //noFill();
  //stroke(255, 200, 0);
  //strokeWeight(5);
  //ellipse(0, 0, newSize, newSize);
  //noStroke();
  if(checkForSuccess())
  {
    fill(0, 255, 0);  
  }
  else
  {
    fill(255, 200, 0); 
  }
  rect(0, 0, t.z, t.z);

  popMatrix();
  
  
  
  
  //rotation
  textSize(50);
  fill(127);
  text("Rotate", width/2, height - 525);
  fill(255);
  rect(width/2, height - 500, width - 100, 100);
  rotating.x = (t.rotation - permrot) + 100;
  rotating.y = height - 500;
  fill(0,0,255);
  rect(rotating.x, rotating.y, 100, 100);
  fill(127);
  
  rect(90 - permrot + 100, rotating.y, 100, 100);
  
  //rect((width - 100) + 50, rotating.y, 50, 50);
  
  //resizing
  fill(127);
  text("Resize", width/2, height - 325);
  fill(255);
  rect(width/2, height - 300, width - 100, 100);
  sizing.x = (t.z / 900) * (width - 100) + 100;
  sizing.y = height - 300;
  fill(0,0,255);
  rect(sizing.x, sizing.y, 100, 100);
  
  fill(127);
  rect((screenZ / 900) * (width - 100) + 100, sizing.y, 100, 100);
}

boolean inCircle(float x1, float y1, float x2, float y2, float size) {
  if (dist(x2, y2, x1, y1) <= size/2.0) return true;
  return false;
}

boolean onCircle(float x1, float y1, float x2, float y2, float size) {
  if (dist(x2, y2, x1, y1) <= size/2.0 + 10 && dist(x2, y2, x1, y1) >= size/2.0 - 10) return true;
  return false;
}

boolean inSquare(float x2, float y2, float x1, float y1, float size) {
  if ((abs(x2 - x1) <= size * sqrt(2) / 2.0) && (abs(y2 - y1) <= size * sqrt(2) / 2.0)) return true;
  return false;
}

boolean inRotate(float x1, float y1) {
  if (x1 >= 25 && x1 <= width - 25 && y1 <= height - 475 && y1 >= height - 525) return true;
  return false;
}

boolean inSize(float x1, float y1) {
  if (x1 >= 25 && x1 <= width - 25 && y1 <= height - 275 && y1 >= height - 325) return true;
  return false;
}

//int onEdges(float x, float y, float size) {
//  int edgenum = 0;
//  if ((abs(mouseX - x) < 30) && (abs(mouseY - y) < 30)) {
//    edgenum = 1;  
//  }
//  else if ((abs(mouseX - (x + size)) < 30) && (abs(mouseY - y) < 30)) {
//    edgenum = 2;  
//  }
//  else if ((abs(mouseX - x) < 30) && (abs(mouseY - (y + size)) < 30)) {
//    edgenum = 3;  
//  }
//  else if ((abs(mouseX - (x + size)) < 30) && (abs(mouseY - (y + size)) < 30)) {
//    edgenum = 4;  
//  }
//  return edgenum;
//}

void mouseDragged() {
  if(trialIndex < targets.size())
  {
    Target t = targets.get(trialIndex);
    float newSize = 2 * t.z;
    float x = width / 2 + t.x + screenTransX;
    float y = height / 2 + t.y + screenTransY;
    float vecx1 = mx[num-2] - x;
    float vecy1 = my[num-2] - y;
    float vecx2 = mx[num-1] - x;
    float vecy2 = my[num-1] - y;
    float crossprod = vecx1 * vecy2 - vecy1 * vecx2;
    
    if(moveSquare) {
      screenTransX = mouseX - (width / 2 + t.x);
      screenTransY = mouseY - (height / 2 + t.y);
    }
    else {
      if (inRotate(mouseX,mouseY)) {
        t.rotation += (mouseX - mx[num-1]);
      }
      else if (inSize(mouseX,mouseY)) {
        t.z += (mouseX - mx[num-1]) / (width - 50) * 900;
      }
    }
  }
}

void mousePressed() {
  if (startTime == 0) //start time on the instant of the first user action    
  {     
    startTime = millis();      
    println("time started!");    
  }
  if(trialIndex < targets.size())
  {
    Target t = targets.get(trialIndex);
    float x = width / 2 + t.x + screenTransX;
    float y = height / 2 + t.y + screenTransY;
    
    if (inRotate(mouseX,mouseY) || inSize(mouseX,mouseY)) {
      moveSquare = false;
    }
    else if (inSquare(mouseX, mouseY, x, y, t.z))
    {
      moveSquare = true;
    }
    else if(mouseY >= (height - 150)) {
      if (userDone==false && !checkForSuccess())
        errorCount++;
  
      //and move on to next trial
      trialIndex++;
  
      screenTransX = 0;
      screenTransY = 0;
  
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
    }
  }
}


//void scaffoldControlLogic()
//{

//  //lower left corner, decrease Z
//  text("+", width - inchesToPixels(.2f), height/2-inchesToPixels(.5f));
//  if (mousePressed && dist(width, height/2-inchesToPixels(.2f), mouseX, mouseY)<inchesToPixels(.5f))
//    screenZ+=inchesToPixels(.02f);

//  text("-", width-inchesToPixels(.2f), height/2+inchesToPixels(.5f));
//  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToxels(.5f))
//    screenZ-=inchesToPixels(.02f);
//}

void mouseReleased()
{
  if(moveSquare)
  {
    moveSquare = !moveSquare;
  }
}

public boolean checkForDistance()
{
  Target t = targets.get(trialIndex);  
  return dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);
}

public boolean checkForRotation()
{
  Target t = targets.get(trialIndex);  
  return calculateDifferenceBetweenAngles(t.rotation+screenRotation,0)<=5;
}

public boolean checkForSize()
{
  Target t = targets.get(trialIndex);  
  return abs(t.z - screenZ)<inchesToPixels(.05f);
}

public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation+screenRotation,0)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  
  //println("Close Enough Distance: " + closeDist);
  //println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,0)+")");
  //println("Close Enough Z: " + closeZ);
  
  return closeDist && closeRotation && closeZ;  
}

double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }