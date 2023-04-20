import java.util.*;
import java.lang.Math;

final Integer PERMUTATION_SIZE = 255;

public class Perlin
{
  private ArrayList<Integer> permutation;
  private Float amplitude;
  private Float frequency;
  private int numOctaves;
  
  Perlin()
  {
      permutation = createPermutation();
      
      // Default values
      frequency = 0.005;
      amplitude =  1.0;
      numOctaves = 8;
    
  }
  
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
  private PVector getConstantVector(Integer v)
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
  public float Noise2d(float x, float y)
  { 
    // For determining which cell we are in
    int X = (int)Math.floor(x) % PERMUTATION_SIZE;
    int Y = (int)Math.floor(y) % PERMUTATION_SIZE;
    
    // Offset
    float xf = (float)(x-Math.floor(x));
    float yf = (float)(y-Math.floor(y));
    
    PVector topRight = new PVector(xf-1.0, yf-1.0);
    PVector topLeft = new PVector(xf, yf-1.0);
    PVector bottomRight = new PVector(xf-1.0, yf);
    PVector bottomLeft = new PVector(xf, yf);
    
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

  // Generates Noise up to a certain octave
  public Float octaveNoise(int x, int y, int numOctaves, Float amplitude, Float frequency)
  {
    Float result = 0.0;
    for(int octave = 0; octave < numOctaves; octave++)
    {
       float n = amplitude * Noise2d(x * frequency, y * frequency);
       result += n;
       
       amplitude *= 0.5;
       frequency *= 2.0;
    }
    
    // just checks to make sure we do not overflow
    result = min(1, result);
    result = max(-1, result);
    
    return result;
  }

  // Call this when you want to draw the noise to the screen
  public void updateNoise()
  {
    for(int y = 0; y < height; y++)
    {
       for(int x = 0; x < width; x++)
       {
         
          float n = octaveNoise(x, y, 8, 1.0, 0.005); 
           n += 1.0;
           n *= 0.5;
           
           color pixelColor;
           
           float c = Math.round(255*n);
           pixelColor = color(c);
           
           pixels[x + y*width] = pixelColor;
           
       }
      
    }
    updatePixels();
  }
  
  public void regeneratePermutation()
  {
    permutation = createPermutation();
    updateNoise();
  }
}
