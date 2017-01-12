int numberOfPoints=18;
PVector[] points=new PVector[numberOfPoints];   //stores the points as vectors
float[][] slopes;                               //stores the slopes of all possible lines as a number between -pi/2 and pi/2 

mline line1=new mline();                        //the three lines, and the defining indices. 
int l1a, l1b, dir1;                              //We also need the direction of the lines. If dirx=1 then the direction of linex is from points[lxa] to points[lxb]
mline line2=new mline();
int l2a, l2b, dir2;
mline line3=new mline();
int l3a, l3b, dir3;

int nextToMove;                                //Which line will make the next step
boolean solved=false;                          //Is the problem solved by the three line.

boolean pause=false;                            //for testing


//Initialization
void setup()
{
  frameRate(20);
  size(600, 600);
  randomPoints();        //Generate points
  init();                //Initilaization of the algorithm
}

//Initalization of the algorithm. We calculate the slopes of every line that goes trhough two of the points. Then we look for a halfing line.
void init()
{
  slopes=new float[numberOfPoints][numberOfPoints];        
  setSlopes();      //Calculate slopes
  l1a=0;
  l1b=0;
  boolean found=false;

  //we search for a line that goes trough the first point and an other one and halfs the points. 
  while (!found)
  {
    l1b++;
    mline lines1=new mline(points[l1a], points[l1b]);
    int counter=0;
    for (int i = 0; i < points.length; i++) {
      if (whichSide(lines1, points[i])==-1 ) {
        counter++;
      }
    }
    if (counter==numberOfPoints/2-1) {
      found=true;
    }
  }
  //We set the three lines to the same position but then we move the second and third one so they wont start from the same place.
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

  move(2);
  move(3);
  move(3);
  //We start by moving the third line.
  nextToMove=3;
}


//Drawing function called for every frame.
void draw()
{
  if (!pause) {
    background(255);
    drawPoints();
    //test();
    //  test2();
    step();
   drawLines();
   
    //if the problem is solved we stop
    if (solved)
    {
      noLoop();
    }
  }
}

void step()
{
  //We move approporiate line to its next position.
  if (nextToMove==1)
  {
    move(1);
  }
  if (nextToMove==2)
  {
    move(2);
  }
  if (nextToMove==3)
  {
    move(3);
  }

  //We calculate the number of points in each area. There are 8 possible area, we can define them by wich side of the lines are we on.
  int counterlll=0;
  int counterllr=0;
  int counterlrl=0;
  int counterlrr=0;
  int counterrll=0;
  int counterrlr=0;
  int counterrrl=0;
  int counterrrr=0;
  for (int i = 0; i < points.length; i++) {
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==-1 &&  whichSide(line3, points[i])==-1) {
      counterlll++;
      text("lll", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==-1 &&  whichSide(line3, points[i])==1) {
      counterllr++;
      text("llr", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==1 &&  whichSide(line3, points[i])==-1) {
      counterlrl++;
      text("lrl", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==1 &&  whichSide(line3, points[i])==1) {
      counterlrr++;
      text("lrr", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==-1 &&  whichSide(line3, points[i])==-1) {
      counterrll++;
      text("rll", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==-1 &&  whichSide(line3, points[i])==1) {
      counterrlr++;
      text("rlr", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==1 &&  whichSide(line3, points[i])==-1) {
      counterrrl++;
      text("rrl", points[i].x+10, points[i].y);
    } 
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==1 &&  whichSide(line3, points[i])==1) {
      counterrrr++;
      text("rrr", points[i].x+10, points[i].y);
    }
    //based on the numberes check if we are ready. If we are not then we decide wich line to move next time.

    int persix=(numberOfPoints-6)/6;
    if (counterlrl==0 && counterrlr==0 &&                                                            //the inner one is empty (also the nonexistent one)
      counterrrr==persix && counterlll==persix && counterlrr==persix && counterrrl==persix && counterllr==persix && counterrll==persix )           //other areas have 1/6 of the points.   
    {
      solved=true;
    } else
    {
      print(counterllr+" "+counterrrr+" "+persix+" "+nextToMove+"\n");
      if (counterllr<persix)
      {
        nextToMove=3;
      } else {
        if (counterlrr<persix)
        {
          nextToMove=2;
        } else {
          nextToMove=1;
        }
      }
    }
  }
}


//This function moves a line
void move(int whatToMove)
{
  if (whatToMove==1)
  {
    int help=nextCenter(l1a, slopes[l1a][l1b]);
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
  }
  if (whatToMove==2)
  {
    int help=nextCenter(l2a, slopes[l2a][l2b]);
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
  }
  if (whatToMove==3)
  {
    int help=nextCenter(l3a, slopes[l3a][l3b]);
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
  }
}

//I just use this to test things.
void test2()
{

  int help=nextCenter(l1a, slopes[l1a][l1b]);
  l1b=l1a;
  l1a=help;
  line1=new mline(points[l1a], points[l1b]);
  line1.display();
  print(l1a+" "+l1b+"\n");
}

//I just use this to test things.
void test()
{
  boolean found=false;
  for (int i=0; i<numberOfPoints; i++)
  {
    for (int j=0; j<i; j++)
    {
      for (int k=0; k<j; k++)
      {
        for (int l=0; l<k; l++)
        {
          if (testConfig(i, j, k, l) && !found) {
            mline lines1=new mline(points[i], points[j]); 
            lines1.display();
            mline lines2=new mline(points[k], points[l]); 
            lines2.display();
            found=true;
          }
        }
      }
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

boolean testConfig(int a, int b, int c, int d)
{
  mline lines1=new mline(points[a], points[b]);
  mline lines2=new mline(points[c], points[d]);
  int counterll=0;
  int counterlr=0;
  int counterrl=0;
  int counterrr=0;
  for (int i = 0; i < points.length; i++) {
    if (whichSide(lines1, points[i])==-1 && whichSide(lines2, points[i])==-1  ) {
      counterll++;
    }
    if (whichSide(lines1, points[i])==1 && whichSide(lines2, points[i])==-1  ) {
      counterrl++;
    }
    if (whichSide(lines1, points[i])==-1 && whichSide(lines2, points[i])==1  ) {
      counterlr++;
    }
    if (whichSide(lines1, points[i])==1 && whichSide(lines2, points[i])==1  ) {
      counterrr++;
    }
  }
  //print(a+" "+b+" "+counterll+"\n");
  if ( counterll==(numberOfPoints-4)/4 && counterlr==(numberOfPoints-4)/4 && counterrl==(numberOfPoints-4)/4 && counterrr==(numberOfPoints-4)/4 )
  {
    return true;
  }
  return false;
}

//Function to draw the points. 
void drawPoints()
{
  strokeWeight(10);
  for (int i = 0; i < points.length; i++) {
    fill(0);
    //text(i, points[i].x+10, points[i].y);
    point(points[i].x, points[i].y);
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
    strokeWeight(1);
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
  stroke(0, 255, 0);
  line2.display(); 
  stroke(0, 0, 255);
  line3.display(); 
  stroke(0);
}

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