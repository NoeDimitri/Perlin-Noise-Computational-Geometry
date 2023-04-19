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
     permutation.add(permutation[i]);
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
public double Fade(float t)
{
  return ((6*t - 15) * t + 10)*t*t*t; 
}

// Function to call to generate a noise value
public float Noise2d(double x, double y)
{
  // For determining which cell we are in
  double X = Math.floor(x) % PERMUTATION_SIZE;
  double Y = Math.floor(y) % PERMUTATION_SIZE;
  
  // Offset
  double xf = x-Math.floor(x);
  double yf = y-Math.flooryx);
  
  PVector topRight = new PVector(1.0-xf, yf);
  PVector topLeft  = new PVector(xf, yf);
  PVector bottomRight = new PVector(1.0-xf, 1.0-yf);
  PVector bottomLeft = new PVector(xf, 1.0-yf);
  
  
}
