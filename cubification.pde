PImage img;


ClusteringStrategy myClustering;
void setup() {
  size(640, 640);
  frameRate(1);
  // Images must be in the "data" directory to load correctly
  img = loadImage("square-abstract-color-composition-with-wood-toy-building-blocks-isolated-H8CGH9.jpg");
  //img = loadImage("img_pagoda.jpg");
  //img = loadImage("img_sun.jpg");
  img.resize(width, height);
  img.loadPixels();
  //myClustering = new ClusteringStrategy(6, img);
  myClustering = new GridClusteringStrategy(4,4, img);
  myClustering.initializeCentroids(1);
}

void draw() {
  image(img, 0, 0, width, height);
  img.loadPixels();
  
  // cluster pixels
  myClustering.clusterPixels();

  // show current colors
  myClustering.updateScreenColors();

  //updateCentroids();
}
