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

  public void initializeCentroids(int seed) {
    randomSeed(seed);
    for (int i = 0; i < nx; i++) 
      gridx[i] = int(random(width));
    for (int j = 0; j < ny; j++) 
      gridy[j] = int(random(height));


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

  public void initializeCentroids() {
    int dx = width/nx;
    for (int i = 0; i < nx; i++) 
      gridx[i] = (i+1)*dx - dx/2;
    int dy = height/ny;
    for (int j = 0; j < ny; j++) 
      gridy[j] = (j+1)*dy - dy/2;

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
    //int startcluster =  millis();
    for (int i = 0; i < nclusters; i++)
      clustered_pixels[i].clear();

    // add pixels to corresponding grid square
    for (int i = 0; i < nx; i++) {
      int startx = 0;
      if (i > 0) startx = int(gridx[i-1]*0.5 + gridx[i]*0.5);
      int endx = width;
      if (i < nx-1) endx = int(gridx[i]*0.5 + gridx[i+1]*0.5);
      for (int j = 0; j < ny; j++) {
        int starty = 0;
        if (j > 0) starty = int(gridy[j-1]*0.5 + gridy[j]*0.5);
        int endy = height;
        if (j < ny-1) endy = int(gridy[j]*0.5 + gridy[j+1]*0.5);

        // iterate over pixels
        for (int px = startx; px < endx; px ++) {
          for (int py = starty; py < endy; py ++) {
            int pindex = px + py*width;
            if (pindex > width*height) print(pindex, ", ", px, ", ", py, "\n");
            clustered_pixels[i+j*nx].add(pindex);
          }
        }
      }
    }
    //print("Total time to cluster pixels: ",   millis()-startcluster , "\n");
  }

  public boolean updateCentroids() {
    int newgridx [] = gridx.clone();
    int newgridy [] = gridy.clone();
    int oldgridx [] = gridx.clone();
    int oldgridy [] = gridy.clone();

    boolean updated = false;

    for (int i = 0; i < nx; i++) {
      float startval = 0;
      if (i > 0) startval = gridx[i-1]*0.5 + gridx[i]*0.5;
      float endval = width;
      if (i < nx-1) endval = gridx[i]*0.5 + gridx[i+1]*0.5;

      // gentle step
      newgridx[i] = int( oldgridx[i]* 0.5 + 0.5*random(startval, endval));

      float old_var = getTotalVar();//getVarX(i);
      gridx = newgridx;
      clusterPixels();
      float new_var = getTotalVar();//getVarX(i);

      // go back to old grid if variance didn't impove
      if (old_var < new_var) { 
        newgridx[i] = oldgridx[i];
        gridx = newgridx;
        clusterPixels();
      } else updated = true;
    }
    for (int j = 0; j < ny; j++) {
      float startval = 0;
      if (j > 0) startval = gridy[j-1]*0.5 + gridy[j]*0.5;
      float endval = height;
      if (j < ny-1) endval = gridy[j]*0.5 + gridy[j+1]*0.5;

      // gentle step
      newgridy[j] = int( oldgridy[j]* 0.5 + 0.5*random(startval, endval));

      float old_var = getTotalVar();//getVarY(j);
      gridy = newgridy;
      clusterPixels();
      float new_var = getTotalVar();//getVarY(j);

      // go back to old grid if variance didn't impove
      if (old_var < new_var) { 
        newgridy[j] = oldgridy[j];
        gridy = newgridy;
        clusterPixels();
      } else updated = true;
    }
    updateScreenColors();
    return updated;
  }

  protected float getVarX(int xi) {
    float totalvar = 0;
    int starti = max(0, xi-1);
    int endi = min(nx, xi+1);
    for (int i =starti; i<endi; i++ ) {
      for (int j = 0; j < ny; j++) {
        int index = i + nx*j;
        int avgcolor = getAvgColor(clustered_pixels[index]);
        float var = getVarColor(clustered_pixels[index], avgcolor);
        int npix = clustered_pixels[index].size();
        float dsize = abs(npix-width*height/nx*ny);
        totalvar += var*dsize;
      }
    }
    return totalvar;
  }

  protected float getVarY(int yj) {
    float totalvar = 0;
    int startj = max(0, yj-1);
    int endj = min(ny, yj+1);
    for (int i =0; i<nx; i++ ) {
      for (int j = startj; j < endj; j++) {
        int index = i + nx*j;
        int avgcolor = getAvgColor(clustered_pixels[index]);
        float var = getVarColor(clustered_pixels[index], avgcolor);
        int npix = clustered_pixels[index].size();
        float dsize = abs(npix-width*height/nx*ny);
        totalvar += var*dsize;
      }
    }
    return totalvar;
  }

  protected float getTotalVar() {
    loadAvgColors();
    float totalvar = 0;
    for (int i = 0; i < nclusters; i++) {
      //int avgcolor = getAvgColor(clustered_pixels[i]);
      
      // cluster uniformity
      int avgcolor = avg_colors[i];
      float var = getVarColor(clustered_pixels[i], avgcolor);
      
      // cluster contrast
      int x = i%nx;
      int y = i/nx;
      int neighbor_x[] = {x-1, x-1, x-1,   x,   x, x+1, x+1, x+1};
      int neighbor_y[] = {y-1,   y, y+1, y-1, y+1, y-1,   y, y+1};
      int n_neighbors = 0;
      float dcolor = 0;
      for(int nex = 0; nex < 8; nex++){
        for(int ney = 0; ney < 8; ney++){
          if (neighbor_x[nex] < 0 || neighbor_x[nex] >= nx ) continue;
          if (neighbor_y[ney] < 0 || neighbor_y[ney] >= ny ) continue;
          n_neighbors ++;
          int neighbor_index = neighbor_x[nex] + nx*neighbor_y[ney];
          int neighbor_color = avg_colors[neighbor_index];
          dcolor += colordistance(neighbor_color, avgcolor);
        }
      }
      dcolor/= n_neighbors;
      
      // cluster size
      int npix = clustered_pixels[i].size();
      float dsize = abs(npix-width*height/nx*ny);
      
      totalvar += var/ (dcolor*dcolor);
    }
    return totalvar;
  }
}
