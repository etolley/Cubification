import java.util.ArrayList;

public class ClusteringStrategy {
  int nclusters;
  int centroids[] ;
  ArrayList<Integer>[] clustered_pixels;
  PImage data_img;

  public ClusteringStrategy(int n, PImage in_img) {
    data_img = in_img;
    nclusters = n; 
    centroids = new int[nclusters];
    clustered_pixels = new ArrayList[nclusters];
  }

  public void clusterPixels() {
    for (int i = 0; i < nclusters; i++)
      clustered_pixels[i].clear();
    // iterate through all pixels and add to 'closest' centroid
    for (int p = 0; p < width*height; p++) {
      int pw = p%width;
      int ph = p/width;
      float min = 99999;
      int mini = -1;
      for (int i = 0; i < nclusters; i++) {
        int c = centroids[i];
        int cw = c%width;
        int ch = c/width;
        float d = distance(cw, pw, ch, ph);
        //d*= colordistance( img.pixels[c], img.pixels[p])/255;
        //d += colordistance( img.pixels[c], img.pixels[p]);
        if (min > d) {
          min = d;
          mini = i;
        }
      }
      clustered_pixels[mini].add(p);
    }
  }

  public void updateScreenColors() {
    loadPixels();
    for (int i = 0; i < nclusters; i++) {
      int avgcolor = getAvgColor(clustered_pixels[i]);
      //setColor(clustered_pixels[i], avgcolor);
      for (int p = 0; p < clustered_pixels[i].size(); p++) {
        pixels[clustered_pixels[i].get(p)] = avgcolor;
      }
    }
    updatePixels();
  }

  public void updateCentroids() {
    for (int i = 0; i < nclusters; i++) {
      int n = clustered_pixels[i].size();
      float avg_w = 0;
      float avg_h = 0;
      for (int p = 0; p < n; p++) {
        avg_w += p%width;
        avg_h += p/width;
      }
      avg_w /= n;
      avg_h /= n;

      int new_loc = int(avg_h)*width+int(avg_w);

      print(i, "previous centroid: ", centroids[i]%width, ", ", centroids[i]/width, "\n");
      print(i, "new centroid: ", avg_w, ", ", avg_h, "\n");
      centroids[i] = new_loc;
      clustered_pixels[i].clear();
    }
  }

  public void initializeCentroids(int seed) {
    randomSeed(seed);
    initializeCentroids();
  }

  public void initializeCentroids() {
    int npixels = width*height;
    for (int i = 0; i < nclusters; i++) {
      centroids[i] = int(random(npixels));
      clustered_pixels[i] = new ArrayList();
      clustered_pixels[i].add(centroids[i]);
    }
  }

  protected float distance(float x1, float x2, float y1, float y2) {
    //float d = abs(x1 - x2) + abs(y1-y2);
    //float d = max(abs(x1 - x2), abs(y1-y2));
    float dx = abs(x1 - x2);
    float dy = abs(y1-y2);
    //float d = sqrt(dx*dx+dy*dy);
    float d;
    d = dx+dy;
    return d;
  }

  protected float colordistance(int c1, int c2) {
    float dr = red(c1) - red(c2);
    float dg = green(c1) - green(c2);
    float db = blue(c1) - blue(c2);
    return sqrt(dr*dr + dg*dg + db*db);
  }

  protected int getAvgColor(ArrayList<Integer> pix) {
    float reds = 0;
    float greens = 0;
    float blues = 0;
    int n = pix.size();
    for (int i = 0; i < n; i++) {
      int p = pix.get(i);
      reds += red(img.pixels[p]);
      greens+= green(img.pixels[p]);
      blues+= blue(img.pixels[p]);
    }
    return color(reds/n, greens/n, blues/n);
  }

  protected float getVarColor(ArrayList<Integer> pix, int avgcolor) {
    float reds = 0;
    float greens = 0;
    float blues = 0;
    float avgr = red(avgcolor);
    float avgg = green(avgcolor);
    float avgb = blue(avgcolor);
    int n = pix.size();
    for (int i = 0; i < n; i++) {
      int p = pix.get(i);
      float r = red(img.pixels[p]);
      float g = green(img.pixels[p]);
      float b = blue(img.pixels[p]);
      reds += r*r-avgr*avgr;
      greens += g*g-avgg*avgg;
      blues += b*b-avgb*avgb;
    }
    return sqrt(reds + greens +blues)/n;
  }

  protected float getTotalVar() {
    float totalvar = 0;
    for (int i = 0; i < nclusters; i++) {
      int avgcolor = getAvgColor(clustered_pixels[i]);
      float var = getVarColor(clustered_pixels[i], avgcolor);
      totalvar += var*clustered_pixels[i].size();
    }
    return totalvar;
  }
}
