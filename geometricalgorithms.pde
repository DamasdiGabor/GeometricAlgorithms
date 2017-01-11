int numberOfPoints=16;
PVector[] points=new PVector[numberOfPoints];   //stores the points as vectors
float[][] slopes;                               //stores the slopes of all possible lines as a number between -pi/2 and pi/2 

/*
PVector a=new PVector(0, 0);                     //The two point that determines the moving line, point a is the center of rotation.      
 PVector b=new PVector(0, 0);                                      
 */

float tim;                                      //We will you this variable to control time
//Initialization
 void setup()
{
  size(600, 600);
  randomPoints();                                         //Generate points
  slopes=new float[numberOfPoints][numberOfPoints];        
  setSlopes();                                            //Calculate slopes 
  //  b=new PVector(points[0].x, points[0].y);                 //Set line to start from the first point
}

//Drawing function called for every frame.
 void draw()
{
  //translate(width/2, height/2);
  background(255);
  tim=float(millis())*0.001f;                 //get current time and scale it to the speed we want 
  drawPoints();
  test();
  //drawLine();
  noLoop();
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
            mline line1=new mline(points[i], points[j]); 
            line1.display();
            mline line2=new mline(points[k], points[l]); 
            line2.display();
            found=true;
          }
        }
      }
    }
  }
  //PVector temp=new PVector(100*cos(tim), 100*sin(tim));
  //a=PVector.add(b, temp); 
  //point(a.x, a.y);
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
  mline line1=new mline(points[a], points[b]);
  mline line2=new mline(points[c], points[d]);
  int counterll=0;
  int counterlr=0;
  int counterrl=0;
  int counterrr=0;
  for (int i = 0; i < points.length; i++) {
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==-1  ) {
      counterll++;
    }
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==-1  ) {
      counterrl++;
    }
    if (whichSide(line1, points[i])==-1 && whichSide(line2, points[i])==1  ) {
      counterlr++;
    }
    if (whichSide(line1, points[i])==1 && whichSide(line2, points[i])==1  ) {
      counterrr++;
    }
  }
  print(a+" "+b+" "+counterll+"\n");
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
    text(i, points[i].x+10, points[i].y);
    point(points[i].x, points[i].y);
  }
}

/*
//Function to draw the moving line. We actually just draw a very long segment. 
 void drawLine()
 {
 PVector temp=PVector.sub(a, b);
 temp.setMag(3000);
 strokeWeight(3);
 line(b.x+temp.x, b.y+temp.y, b.x-temp.x, b.y-temp.y);
 }*/

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
    if (angleDist(currentSlope, slopes[currentCenter][i])<min )
    {
      minind=i;
      min=angleDist(currentSlope, slopes[currentCenter][i]);
    }
  }
  return minind;
}

//Calculates the required angle of turning from one angle to an other. The angles should be given between -pi/2 and pi/2. The result is between 0 and PI.
float angleDist(float angleFrom, float angleTo)
{
  if (angleFrom<=angleTo)
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
  if ( (l.a.x-p.x)*(l.b.y-p.y)-(l.a.y-p.y)*(l.b.x-p.x)<0 )
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