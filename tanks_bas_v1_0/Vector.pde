public static class VecMath {

  public static float dot(PVector v, PVector w) {
    return ((v.x * w.x) + ( v.y * w.y));
  }
  public static float dot(Vector2D v, Vector2D w) {
    return ((float)((v.x * w.x) + ( v.y * w.y)));
  }
  public static float dot(float x1, float y1, float x2, float y2) {
    return ((x1 * x2) + ( y1 * y2));
  }

  public static PVector normalize(PVector v) {
    float mag = mag(v.x, v.y);
    return new PVector(v.x/mag, v.y/mag);
  }

  public static PVector normalize(float x, float y) {
    float mag = mag(x, y);
    return new PVector(x/mag, y/mag);
  }

  public static PVector normalize(Vector2D v) {
    float mag = mag((float)v.x, (float)v.y);
    return new PVector((float)v.x/mag, (float)v.y/mag);
  }
  
  public static PVector direction(float x1, float y1, float x2, float y2){
  
    return new PVector(x2-x1, y2-y1);
    
  }  
  public static Vector2D direction2D(float x1, float y1, float x2, float y2){
    return new Vector2D(x2-x1, y2-y1);
  }
  
  public static float dotAngle(PVector v, PVector w){
   float rad = dot(v, w)/(mag(v.x, v.y)*mag(w.x, w.y));
   return degrees(rad);
  }
}
