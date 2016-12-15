int numberOfPoints=10;
PVector[] points=new PVector[numberOfPoints];

//Initialization
void setup()
{
  size(600, 600);
  randomPoints();
}

//Drawing function called for every frame.
void draw()
{
  //translate(width/2, height/2);
  strokeWeight(10);
  drawPoints();
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
  for (int i = 0; i < points.length; i++) {
   point(points[i].x,points[i].y);
  }
}