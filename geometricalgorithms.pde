int numberOfPoints=60;                           //The number of points to be generated
PVector[] points=new PVector[numberOfPoints];    //We store the points as vectors
float[][] slopes;                               //stores the slopes of all possible lines as a number between -pi/2 and pi/2 

mline line1=new mline();                        //the three lines, and the defining indices. linex goes trough points[lxa] and points[lxb] 
int l1a, l1b, dir1;                              //We also need the direction of the lines. If dirx=1 then the direction of linex is from points[lxa] to points[lxb]
mline line2=new mline();
int l2a, l2b, dir2;
mline line3=new mline();
int l3a, l3b, dir3;

boolean solved=false;                          //Is the problem solved by the three line.

boolean pause=false;                            //for testing, if you press 'p' while the program is running it will pause
int numberOfSteps=0;                            //The number of setps we make with the lines.

int counterlll=0;                              //The number of points contained in the 8 possible area, one of the areas is always nonexistent.
int counterllr=0;
int counterlrl=0;
int counterlrr=0;
int counterrll=0;
int counterrlr=0;
int counterrrl=0;
int counterrrr=0;

boolean phase1=true;                            //True if we are in the first phase of the algorithm
int initialSide;                                //Stores on which side of line1 is the intersection of line2 and line3

int numgif=0;                                   //Number of frames saved for gif creation.

//Initialization
void setup()
{
  frameRate(60);
  size(600, 600);
  randomPoints();        //Generate points
  init();                //Initilaization of the algorithm
}

//Initalization of the algorithm. We calculate the slopes of every line that goes trhough two of the points. Then we look for a halving line.
void init()
{
  slopes=new float[numberOfPoints][numberOfPoints];        
  setSlopes();      //Calculate slopes
  l1a=0;
  l1b=0;
  boolean found=false;

  //We search for a halvingline that goes trough the first point and an other one  
  while (!found)
  {
    l1b++;
    mline lines1=new mline(points[l1a], points[l1b]);
    int counter=0;
    for (int i = 0; i < points.length; i++) {
      if (whichSide(lines1, points[i])==-1 && i!=l1b) {
        counter++;
      }
      if (i==l1a)
      {
        counter++;
      }
    }
    if (counter==numberOfPoints/2) {
      found=true;
    }
  }

  //We set the three lines to the same position.
  line1=new mline(points[l1a], points[l1b]);
  dir1=1;
  l2a=l1a;
  l2b=l1b;
  line2=new mline(points[l2a], points[l2b]);
  dir2=1;
  l3a=l1a;
  l3b=l1b;
  line3=new mline(points[l3a], points[l3b]);
  dir3=1;
  //We initialize our counters.
  counterlll=numberOfPoints/2;
  counterllr=0;
  counterlrl=0;
  counterlrr=0;
  counterrll=0;
  counterrlr=0;
  counterrrl=0;
  counterrrr=numberOfPoints/2;
}


//Drawing function called for every frame.
void draw()
{
  if (!pause) {
    if (!solved)
    {
      background(255);
      drawPoints();
      //uncomenting these lines we block the animation
      //while(!solved)
      //{
      step();
      //}

      drawPoints();
      drawLines();

      //uncomenting these lines will save all the frames, for gif creation.
      /*if (numgif<100) { 
       saveFrame("image-####.gif"); 
       numgif++;
       }*/

      //if the problem is solved we stop
    } else {   
      noLoop();
    }
  }
}

void step()
{
  numberOfSteps++;

  //if we are in the first phase we move the second and the third forward until we have enough points in llr+rlr, and lrr+lrl
  if (phase1)
  {
    if (counterllr+counterrlr<numberOfPoints/6)
    {
      move(3);
    } else {
      move(2);
    }
    if (counterlrr+counterlrl==numberOfPoints/6 && counterllr+counterrlr==numberOfPoints/6)
    {
      phase1=false;
      //things to do after phase1
      //we calculate the intersection of line2 and line3 and check which side of l1 contains it. If it is on l1 we are ready imediately. 
      PVector p=lineIntersection(line2, line3);
      initialSide=whichSide(line1, p);
      if (initialSide==0) {
        solved=true;
      }
    }
  } else { 
    //Phase2
    //We move approporiate line(s) to the next position. We always maintain enough points in llr+rlr, and lrr+lrl
    if (canWeMove(true, false, false))
    {
      move(1);
      checkReady(1);
    } else {
      if (canWeMove(false, true, false))
      {
        move(2);
        checkReady(2);
      } else {
        if (canWeMove(true, true, false))
        {
          move(1);
          checkReady(1);
          move(2);
          checkReady(2);
        } else {
          if (canWeMove(false, false, true))
          {
            move(3);
            checkReady(3);
          } else {
            if (canWeMove(false, true, true)) {
              move(2);
              checkReady(2);
              move(3);
              checkReady(3);
            } else {
              move(1);
              checkReady(1);
              move(2);
              checkReady(2);
              move(3);
              checkReady(3);
            }
          }
        }
      }
    }
  }
}

//Checks if the intersection of line2 and line3 moved to the other side of line1. If it did, we are ready. 
void checkReady(int lineInd)
{
  if (!solved) {
    PVector p=lineIntersection(line2, line3);
    int currentSide=whichSide(line1, p);
    if (initialSide!=currentSide) {
      solved=true;
      print("We are done");
    } 
    if (solved)
    {

      if (lineInd==1)
      {
        line1=new mline(points[l1b], p);
      }

      if (lineInd==2)
      {
        PVector p2=lineIntersection(line1, line3);
        line2=new mline(points[l2b], p2);
      }

      if (lineInd==3)
      {
        PVector p2=lineIntersection(line1, line2);    
        line3=new mline(points[l3b], p2);
      }
    }
  }
}

//Cheks if the number of points would change if we would make a step with our lines.
boolean canWeMove(boolean first, boolean second, boolean third)
{

  //We save the current state of the algorithm
  int tempcounterlll=counterlll;                              
  int tempcounterllr=counterllr;
  int tempcounterlrl=counterlrl;
  int tempcounterlrr=counterlrr;
  int tempcounterrll=counterrll;
  int tempcounterrlr=counterrlr;
  int tempcounterrrl=counterrrl;
  int tempcounterrrr=counterrrr;
  int templ1a=l1a;
  int templ1b=l1b;
  int tempdir1=dir1;
  int templ2a=l2a;
  int templ2b=l2b;
  int tempdir2=dir2;
  int templ3a=l3a;
  int templ3b=l3b;
  int tempdir3=dir3;
  boolean ans=true;
  //We move the lines.
  if (first)
  {
    move(1);
  }
  if (second)
  {
    move(2);
  }
  if (third)
  {
    move(3);
  }
  //If something changed, we will answer false.
  if (tempcounterlrr+tempcounterlrl!=counterlrr+counterlrl || counterllr+counterrlr!=tempcounterllr+tempcounterrlr)
  {
    ans=false;
  } else
  {
    ans=true;
  }
  //set everything back to original
  counterlll=tempcounterlll;      
  counterllr=tempcounterllr;
  counterlrl=tempcounterlrl;
  counterlrr=tempcounterlrr;
  counterrll=tempcounterrll;
  counterrlr=tempcounterrlr;
  counterrrl=tempcounterrrl;
  counterrrr=tempcounterrrr;
  l1a=templ1a;
  l1b=templ1b;
  dir1=tempdir1;
  l2a=templ2a;
  l2b=templ2b;
  dir2=tempdir2;
  l3a=templ3a;
  l3b=templ3b;
  dir3=tempdir3;
  if (dir1==1) {
    line1=new mline(points[l1a], points[l1b]);
  } else {
    line1=new mline(points[l1b], points[l1a]);
  }
  if (dir2==1) {
    line2=new mline(points[l2a], points[l2b]);
  } else {
    line2=new mline(points[l2b], points[l2a]);
  }
  if (dir3==1) {
    line3=new mline(points[l3a], points[l3b]);
  } else {
    line3=new mline(points[l3b], points[l3a]);
  }
  return ans;
}

//Updates the number of points in the areas
void changeCounters(int ind, int amount)
{
  int side1=whichSide2(line1, 1, ind);
  int side2=whichSide2(line2, 2, ind);
  int side3=whichSide2(line3, 3, ind);
  if (side1==-1 && side2==-1 &&  side3==-1) {
    counterlll=counterlll+amount;
  } 
  if (side1==-1 && side2==-1 &&  side3==1) {
    counterllr=counterllr+amount;
  } 
  if (side1==-1 && side2==1 &&  side3==-1) {
    counterlrl=counterlrl+amount;
  } 
  if (side1==-1 && side2==1 &&  side3==1) {
    counterlrr=counterlrr+amount;
  } 
  if (side1==1 && side2==-1 &&  side3==-1) {
    counterrll=counterrll+amount;
  } 
  if (side1==1 && side2==-1 &&  side3==1) {
    counterrlr=counterrlr+amount;
  } 
  if (side1==1 && side2==1 &&  side3==-1) {
    counterrrl=counterrrl+amount;
  } 
  if (side1==1 && side2==1 &&  side3==1) {
    counterrrr=counterrrr+amount;
  }
}


//This function moves a given line to the next position
void move(int whatToMove)
{
  if (!solved) {
    if (whatToMove==1)
    {
      //The current center might go from one area to an other so we take it out from the counters. Later we add it to the correct new area
      changeCounters(l1a, -1);

      int help=nextCenter(l1a, slopes[l1a][l1b]); // the next center. This might also go to an other area so we take this one out too.
      changeCounters(help, -1); 

      if (whichSide(line1, points[help])==-1)
      {
        dir1=-1;
      } else {
        dir1=1;
      }
      l1b=l1a;
      l1a=help;
      if (dir1==1) {
        line1=new mline(points[l1a], points[l1b]);
      } else {
        line1=new mline(points[l1b], points[l1a]);
      }
      //we add the two points to the appropriate counter. Here l1a, l1b already have new values!
      changeCounters(l1a, 1);
      changeCounters(l1b, 1);
    }
    if (whatToMove==2)
    {
      changeCounters(l2a, -1);

      int help=nextCenter(l2a, slopes[l2a][l2b]); // the next center. This might also go to an other area so we take this one out too.
      changeCounters(help, -1); 

      if (whichSide(line2, points[help])==-1)
      {
        dir2=-1;
      } else {
        dir2=1;
      }
      l2b=l2a;
      l2a=help;
      if (dir2==1) {
        line2=new mline(points[l2a], points[l2b]);
      } else {
        line2=new mline(points[l2b], points[l2a]);
      }
      changeCounters(l2a, 1);
      changeCounters(l2b, 1);
    }
    if (whatToMove==3)
    {
      changeCounters(l3a, -1);

      int help=nextCenter(l3a, slopes[l3a][l3b]); // the next center. This might also go to an other area so we take this one out too.
      changeCounters(help, -1); 


      if (whichSide(line3, points[help])==-1)
      {
        dir3=-1;
      } else {
        dir3=1;
      }
      l3b=l3a;
      l3a=help;
      if (dir3==1) {
        line3=new mline(points[l3a], points[l3b]);
      } else {
        line3=new mline(points[l3b], points[l3a]);
      }
      changeCounters(l3a, 1);
      changeCounters(l3b, 1);
    }
  }
}



//Random point generation
void randomPoints()
{
  for (int i = 0; i < points.length; i++) {
    points[i] = new PVector(random(width), random(height));
  }
}

//Function to draw the points. 
void drawPoints()
{
  strokeWeight(10);
  for (int i = 0; i < points.length; i++) {
    fill(0);
    //text(i, points[i].x+10, points[i].y);
    point(points[i].x, points[i].y);
    stroke(0);
  }
}


//function to calculate and store the slopes of possible lines
void setSlopes()
{
  for (int i = 0; i < points.length; i++) {
    for (int j = 0; j < points.length; j++) {
      //We dont want to divide by 0!
      if (points[j].x-points[i].x!=0) {
        slopes[i][j]=atan((points[j].y-points[i].y)/( points[j].x-points[i].x));
      } else {
        slopes[i][j]=PI/2;
      }
    }
  }
}

//finds the next center for the moving line
int nextCenter(int currentCenter, float currentSlope)
{
  int minind=0;
  float min=100; //Just random some big number, bigger than Pi
  for (int i=0; i<numberOfPoints; i++)
  {
    if (angleDist(currentSlope, slopes[currentCenter][i])<min && i!=currentCenter )
    {
      minind=i;
      min=angleDist(currentSlope, slopes[currentCenter][i]);
    }
  }
  return minind;
}

//Calculates the required angle of turning from one angle to an other. 
//The angles should be given between -pi/2 and pi/2. The result is between 0 and PI. But not 0!
float angleDist(float angleFrom, float angleTo)
{
  if (angleFrom<angleTo)
  {
    return angleTo-angleFrom;
  }
  return PI-(angleFrom-angleTo);
}

//Class for line determined by two of it's points
class mline
{
  PVector a;
  PVector b;

  mline(float ax, float ay, float bx, float by)
  {
    a=new PVector(ax, ay);
    b=new PVector(bx, by);
  }
  mline()
  {
    a=new PVector(0, 0);
    b=new PVector(100, 0);
  }

  mline(PVector ina, PVector inb)
  {
    a=ina;
    b=inb;
  }


  void display()
  {
    strokeWeight(3);
    PVector dif=PVector.sub(a, b);
    dif.setMag(3000);
    line((float)(a.x+dif.x), (float) (a.y+dif.y), (float)(a.x-dif.x), (float)(a.y-dif.y));
  }
}

//Decides if the point is left or right of the line. The direction of the line is from "a to b" where a and b are the defining points. -1 left 0 incidence 1 right
int whichSide(mline l, PVector p)
{
  if ( (l.a.x-p.x)*(l.b.y-p.y)-(l.a.y-p.y)*(l.b.x-p.x)>0 )
  {
    return -1;
  }
  if ( (l.a.x-p.x)*(l.b.y-p.y)-(l.a.y-p.y)*(l.b.x-p.x)==0 )
  {
    return 0;
  }
  return 1;
}

//Decides if the point is left or right of the line. This version makes a decision even if the point is on the line. -1 left 1 right
int whichSide2(mline l, int lineind, int ind)
{
  PVector p=points[ind];
  if ( (l.a.x-p.x)*(l.b.y-p.y)-(l.a.y-p.y)*(l.b.x-p.x)>0 )
  {
    return -1;
  }
  if ( (l.a.x-p.x)*(l.b.y-p.y)-(l.a.y-p.y)*(l.b.x-p.x)<0 )
  {
    return 1;
  }
  if ( (ind==l1a && lineind==1) ||(ind==l2a && lineind==2) || (ind==l3a && lineind==3) )
  {
    return -1;
  }

  if ( (ind==l1b && lineind==1 && dir1==-1) ||(ind==l2b && lineind==2 && dir2==-1) || (ind==l3b && lineind==3 && dir3==-1) )
  {
    return -1;
  }

  if ( (ind==l1b && lineind==1 && dir1==1) ||(ind==l2b && lineind==2 && dir2==1) || (ind==l3b && lineind==3 && dir3==1) )
  {
    return 1;
  }

  return 1;
}


//Calculates the intersection of two lines
PVector lineIntersection(mline e, mline f)
{
  PVector ans=new PVector(); 
  float x1=e.a.x;
  float x2=e.b.x;
  float x3=f.a.x;
  float x4=f.b.x;
  float y1=e.a.y;
  float y2=e.b.y;
  float y3=f.a.y;
  float y4=f.b.y;

  float newx=((x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
  float newy=((x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4))/((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
  ans = new PVector(newx, newy); 

  return ans;
}

//Function that draws the three lines on the screen
void drawLines()
{
  stroke(255, 0, 0);
  line1.display(); 
  stroke(0, 100, 0);
  line2.display(); 
  stroke(0, 0, 255);
  line3.display(); 
  stroke(0);
}

//If 'p' is pressed the program pauses.
void keyPressed() {
  if (key=='p')
  {
    pause=!pause;
  }
  if (key=='i')
  {
    save("kep.png");
  }
}