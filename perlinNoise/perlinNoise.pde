import java.util.*;
import java.lang.Math;

final Integer PERMUTATION_SIZE = 255;

// For creating and shuffling permutation array List
public ArrayList<Integer> createPermutation()
{
ArrayList<Integer> permutation = new ArrayList<Integer>();
  
  for(Integer i = 0; i < PERMUTATION_SIZE + 1; i++)
  {
     permutation.add(i);
  }
  
  Collections.shuffle(permutation);
  
  // do we need this?
  for(Integer i = 0; i < PERMUTATION_SIZE + 1; i++)
  {
     permutation.add(permutation.get(i));
  }
  
  return permutation;
 
}


// Lookup table for the cosntantVectors
public PVector getConstantVector(Integer v)
{
  switch(v % 3)
  {
    case 0:
      return new PVector(1.0, 1.0);
    case 1:
      return new PVector(-1.0, 1.0);
    case 2:
      return new PVector(-1.0, -1.0);
    default:
      return new PVector(1.0, -1.0);
    
  }
  
}

// Ease curve for assigning a interpolation value
public float Fade(float t)
{
  return ((6*t - 15) * t + 10)*t*t*t; 
}

// Function to call to generate a noise value
public float Noise2d(float x, float y, ArrayList<Integer> permutation)
{ 
  // For determining which cell we are in
  int X = (int)Math.floor(x) % PERMUTATION_SIZE;
  int Y = (int)Math.floor(y) % PERMUTATION_SIZE;
  
  // Offset
  float xf = (float)(x-Math.floor(x));
  float yf = (float)(y-Math.floor(y));
  
  PVector topRight = new PVector(xf-1.0, yf);
  PVector topLeft = new PVector(xf, yf);
  PVector bottomRight = new PVector(xf-1.0, yf-1.0);
  PVector bottomLeft = new PVector(xf, yf-1.0);
  
  Integer valueTopRight = permutation.get(permutation.get(X+1)+Y+1);
  Integer valueTopLeft = permutation.get(permutation.get(X)+Y+1);
  Integer valueBottomRight = permutation.get(permutation.get(X+1)+Y);
  Integer valueBottomLeft = permutation.get(permutation.get(X)+Y);
  
  float dotTopRight = topRight.dot(getConstantVector(valueTopRight));
  float dotTopLeft = topLeft.dot(getConstantVector(valueTopLeft));
  float dotBottomRight = bottomRight.dot(getConstantVector(valueBottomRight));
  float dotBottomLeft = bottomLeft.dot(getConstantVector(valueBottomLeft));
  
  float u = Fade(xf);
  float v = Fade(yf);
  
  return lerp(
    lerp(dotBottomLeft, dotTopLeft, v),
    lerp(dotBottomRight, dotTopRight, v),
    u
  );
}

void setup()
{
  size(300, 300);
  background(255);
  ArrayList<Integer> permutation = createPermutation();
  loadPixels();

  for(int y = 0; y < 300; y++)
  {
     for(int x = 0; x < 300; x++)
     {
       
        float n = Noise2d(x*0.01, y*0.01, permutation); 
         n += 1.0;
         n /= 2.0;
         
         float c = Math.round(255*n);
         color greyscale = color(c,c,c);
         
         pixels[x + y*300] = greyscale;
         
       
     }
    
  }
  updatePixels();
  
}
