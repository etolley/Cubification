import java.util.Arrays; 

public class GridClusteringStrategy extends ClusteringStrategy {
  int nx;
  int ny;
  int gridx[] ;
  int gridy[] ;
  public GridClusteringStrategy(int x, int y, PImage in_img) {
    super(x*y, in_img);
    nx = x;
    ny = y;
    gridx = new int[nx];
    gridy = new int[ny];
  }

  public void initializeCentroids() {
    for (int i = 0; i < nx; i++) {
      gridx[i] = int(random(width));
      for (int j = 0; j < ny; j++) {
        gridy[j] = int(random(height));
      }
    }
    //sort arrays
    Arrays.sort(gridx);
    Arrays.sort(gridy);

    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {

        //location of new pixel
        int p = gridy[j]*width + gridx[i];

        // index of new pixel in centroids
        int index = i + j*nx;

        centroids[index] = p;
        clustered_pixels[index] = new ArrayList();
        clustered_pixels[index].add(centroids[index]);
      }
    }
  }

  public void clusterPixels() {
    for (int i = 0; i < nclusters; i++)
      clustered_pixels[i].clear();
    // iterate through all pixels and add to 'closest' centroid
    for (int p = 0; p < width*height; p++) {
      int pw = p%width;
      int ph = p/width;

      // find gridy closest to pw
      int mind = width;
      int mini = -1;
      for (int i = 0; i < nx; i++) {

        int d = abs(gridx[i] - pw);
        if (d < mind) {
          mind = d;
          mini = i;
        }
      }
      // find gridx closest to ph
      mind = height;
      int minj = -1;
      for (int j = 0; j < ny; j++) {
        int d = abs(gridy[j] - ph);
        if (d < mind) {
          mind = d;
          minj = j;
        }
      }
      int index = mini + minj*nx;
      clustered_pixels[index].add(p);
    }
  }
  public void updateCentroids() {
    int newgridx [] = new int [nx];
    int newgridy [] = new int [ny];
    int oldgridx [] = gridx.clone();
    int oldgridy [] = gridy.clone();

    if (nx == 1) 
      newgridx[0] = int(random(width));
    if (ny == 1) 
      newgridy[0] = int(random(height));

    // select new random values
    for (int i = 0; i < nx; i++) {
      float startval = 0;
      if (i > 0) startval = gridx[i-1]*0.5 + gridx[i]*0.5;
      float endval = width;
      if (i < nx-1) endval = gridx[i]*0.5 + gridx[i+1]*0.5;
      newgridx[i] = int(random(startval, endval));
    }
    for (int i = 0; i < ny; i++) {
      float startval = 0;
      if (i > 0) startval = gridy[i-1]*0.5 + gridy[i]*0.5;
      float endval = width;
      if (i < ny-1) endval = gridy[i]*0.5 + gridy[i+1]*0.5;
      newgridy[i] = int(random(startval, endval));
    }
    
    float old_var = getTotalVar();
    
    gridx = newgridx;
    gridy = newgridy;
    clusterPixels();
    
    float new_var = getTotalVar();
    
    if (old_var < new_var){
      gridx = oldgridx;
      gridy = oldgridy;
      newgridx = null;
      newgridy = null;
    }else{
      print(frameCount, " updating grid");
      oldgridx = null;
      oldgridy = null;
    }
    
    
  }
}
