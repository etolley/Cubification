PImage img;
int framesSaved;

ClusteringStrategy myClustering;
void setup() {
  size(640, 640);
  frameRate(5);
  framesSaved = 0;
  // Images must be in the "data" directory to load correctly
  //img = loadImage("square-abstract-color-composition-with-wood-toy-building-blocks-isolated-H8CGH9.jpg");
  img = loadImage("city.png");
  //img = loadImage("img_sun.jpg");
  //img = loadImage("mona.png");
  img.resize(width, height);
  img.loadPixels();
  //myClustering = new ClusteringStrategy(6, img);
  myClustering = new GridClusteringStrategy(30,30, img);
  myClustering.initializeCentroids(1);
 
}

void draw() {
  image(img, 0, 0, width, height);
  img.loadPixels();
  
  // cluster pixels
  myClustering.clusterPixels();

  // show current colors
  myClustering.updateScreenColors();

  boolean updated = myClustering.updateCentroids();
  if(updated && framesSaved < 30){
    saveFrame("pago-####.png");
    framesSaved++;
  }
}
