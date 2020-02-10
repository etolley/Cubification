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
    int npixels = width*height;
    for (int i = 0; i < nx; i++) {
      gridx[i] = int(random(width));
      for (int j = 0; j < ny; j++) {
        gridy[j] = int(random(height));

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

  protected float distance(float x1, float x2, float y1, float y2) {
    float dx = abs(x1 - x2);
    float dy = abs(y1-y2);
    float d = max(dx, dy);
    return d;
  }
}
