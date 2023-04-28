import java.util.*;
import java.lang.Math;

final Integer PERMUTATION_SIZE = 255;
final Integer GRID_SIZE_BASE = 256;

// Much of the perlin noise code was sourced from the following blog post!
// I'll leave comments above the code that came from these posts.
// https://rtouti.github.io/graphics/perlin-noise-algorithm

public class Noise
{
  private ArrayList<Integer> permutation;
  private ArrayList<Float> gridValues;
  private Float amplitude;
  private Float frequency;
  private int numOctaves;
  private float amplitudeDecayRate;
  private float frequencyGrowthRate;
  private int colorMode;
  private int noiseType;
  
  Noise()
  {
      permutation = createPermutation();
      gridValues = generateValues(GRID_SIZE_BASE);
      
      // Default values
      frequency = 0.005;
      
      // Around 5 is a good amount
      amplitude =  2.0;
      numOctaves = 3;
      amplitudeDecayRate = 0.5;
      frequencyGrowthRate = 2.0;
      
      colorMode = 2;
      noiseType = 0;
    
  }
  
  Noise(float frequencyBase, float amplitudeBase, int numOctavesBase, float amplitudeDecayBase, float frequencyGrowthBase, int coloringMode, int noiseMode)
  {
      permutation = createPermutation();
      gridValues = generateValues(GRID_SIZE_BASE);
      
      // Default values
      frequency = frequencyBase;
      amplitude =  amplitudeBase;
      numOctaves = numOctavesBase;
      
      amplitudeDecayRate = amplitudeDecayBase;
      frequencyGrowthRate = frequencyGrowthBase;
      
      // For colorMode: 0 = noise, 1 = caves, 2 = lakes
      colorMode = coloringMode;
      
      // For noiseType: 0 = Perlin, 1 = Value
      noiseType = noiseMode;
  }
  
  // For creating and shuffling permutation array List
  // Sourced from blog post
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
  // Modified from original blog post
  private PVector getConstantVector(Integer v)
  {
    switch(v % 4)
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
  // From Ken Perlin's originally blog post
  public float Fade(float t)
  {
    //return t;
    return ((6*t - 15) * t + 10)*t*t*t; 
  }
  
  // Function to call to generate a noise value using Perlin noise algorithm
  // Sourced largely from blog post
  public float perlinNoise2d(float x, float y)
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

  // Generates Perlin Noise up to a certain octave
  // Modified variant from blog post
  public Float octaveNoise(int x, int y, float amplitude, float frequency)
  {
    Float result = 0.0;
    for(int octave = 0; octave < numOctaves; octave++)
    {
      float n;
      if (noiseType == 0) { 
        n = amplitude * perlinNoise2d(x * frequency, y * frequency);
      }
      else {
        n = valueNoise2D(x, y, amplitude, frequency);
      }
      result += n;
       
       // two hyper parameters here, can maybe modify rate that these change
      amplitude *= amplitudeDecayRate;
      frequency *= frequencyGrowthRate;
      
      result = min(1, result);
      result = max(-1, result);
    }
    
    // just checks to make sure we do not overflow

    
    return result;
  }
  
  // Function generating random values for n x n grid, returning an ArrayList<Float> of randomly generated values of length n^2
  public ArrayList<Float> generateValues(int n) {
    ArrayList<Float> vals = new ArrayList<Float>();
    Random rand = new Random();
    
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        vals.add((rand.nextFloat() * 2) - 1);
      }
    }
    return vals;
  }
  
  // Function generating a noise value using Value noise algorithm
  // Inputs: integers x and y (coordinates for input point)
  //         float amplitude: affects the severity/intensity of the noise values
  //         float frequency: affects the overall size of the picture / how much noise is being fit into the screen
  // 
  // Output: a float noise value to be used in the coloring functions later
  public float valueNoise2D (int x, int y, float amplitude, float frequency) {
    float transformedX = (float)(x) * frequency;
    float transformedY = (float)(y) * frequency;
    
    // First, determine which grid cell that (x,y) is in
    int gridX = (int)(transformedX % (GRID_SIZE_BASE));
    int gridY = (int)(transformedY % (GRID_SIZE_BASE));
    
    // Now, determine the value of (x,y) based on interpolating from the values of the grid vertices
    float topLeftVal, topRightVal, bottomLeftVal, bottomRightVal;
    topLeftVal = gridValues.get((GRID_SIZE_BASE * gridY) + gridX);
    topRightVal = gridX != GRID_SIZE_BASE - 1 ? gridValues.get((GRID_SIZE_BASE * gridY) + gridX + 1) : gridValues.get((GRID_SIZE_BASE * gridY));
    bottomLeftVal = gridY != GRID_SIZE_BASE - 1 ? gridValues.get((GRID_SIZE_BASE * (gridY + 1)) + gridX) : gridValues.get(gridX);
    bottomRightVal = gridX != GRID_SIZE_BASE - 1 ? (gridY != GRID_SIZE_BASE - 1 ? gridValues.get((GRID_SIZE_BASE * (gridY + 1)) + gridX + 1) : gridValues.get(gridX + 1)) : (gridY != GRID_SIZE_BASE - 1 ? gridValues.get((GRID_SIZE_BASE * (gridY+1))) : gridValues.get(0));
    
    float xOffset = (float)(transformedX - Math.floor(transformedX));
    float yOffset = (float)(transformedY - Math.floor(transformedY));
    
    // Applying a smoothing function to the offsets
    xOffset = xOffset * xOffset * (3 - (2 * xOffset));
    yOffset = yOffset * yOffset * (3 - (2 * yOffset));
    
    return (amplitude * lerp(
      lerp(topLeftVal, topRightVal, xOffset),
      lerp(bottomLeftVal, bottomRightVal, xOffset),
      yOffset
    ));
  }

  // Call this when you want to draw the noise to the screen
  public void updateNoise()
  {
    for(int y = 0; y < height; y++)
    {
       for(int x = 0; x < width; x++)
       {
         float n = octaveNoise(x, y, amplitude, frequency); 
         n += 1.0;
         n *= 0.5;

         color pixelColor = selectColor(n);
           
         pixels[x + y*width] = pixelColor;
           
       }
      
    }
    updatePixels();
  }
  
  private color selectColor(float noiseValue)
  {
    switch(colorMode)
    {
      case 0:
        float c = Math.round(255*noiseValue);
        return(color(c));
      case 1:
        if(noiseValue > 0.80) return color(255);
        //else if (noiseValue > 0.001) return color(#363636);
        //else return color(#66ccff);
        else return color(#363636);
      case 2:
        //if (noiseValue >= 0.99) return color (#0066cc);
        if(noiseValue >= 0.80) return color(#3399ff);
        else if (noiseValue >= 0.65) return color(#ffcc99);
        else if (noiseValue >= 0.25) return color(#00cc66);
        else if (noiseValue >= 0.04) return color(#009933);
        else return color(#336600);
    }
    
    float c = Math.round(255*noiseValue);
    return(color(c));
  }
  
  public void regeneratePermutation()
  {
    println("generating new permutation");
    permutation = createPermutation();
    gridValues = generateValues(GRID_SIZE_BASE);
    updateNoise();
  }
  
  // Yoinked this code off the internet heheh
  public void testRuntime()
  {
      //long startTimeNanoSecond = System.nanoTime();
      long startTimeMilliSecond = System.currentTimeMillis();
      updateNoise();
      //long endTimeNanoSecond = System.nanoTime();
      long endTimeMilliSecond = System.currentTimeMillis();
      //System.out.println("Time Taken in "+(endTimeNanoSecond - startTimeNanoSecond) + " ns");
      System.out.println("Time Taken in "+(endTimeMilliSecond - startTimeMilliSecond) + " ms");
  }
  
  // The Code below are simple different setter functions :D
  
  // setter method for changing the octave
  public void modifyOctave(int dif)
  {
      // add dif and make sure it's at least 1
      numOctaves = max(numOctaves + dif, 1);
      println("Modified number of octaves: " + numOctaves);
      updateNoise();  
  }
  
  public void modifyFrequency(float dif)
  {
      
      if (frequency + dif <= 0)
      {
         println("Error: Negative frequency");
         return;
      }
      frequency += dif;
      println(String.format("Modified frequency: %.3f", frequency));
      updateNoise();  
  }
  
  public void modifyAmplitude(float dif)
  {
      amplitude += dif;
      println("Modified amplitude: " + amplitude);
      updateNoise();  
  }
  
  public void modifyAmplitudeDecay(float dif)
  {
      if (amplitudeDecayRate + dif <= 0)
      {
         println("Error: invalid amplitude decay");
         return;
      }
      amplitudeDecayRate += dif;
      println(String.format("Modified amplitudeDecayRate: %.2f", amplitudeDecayRate));
      updateNoise();  
  }
  
  public void modifyfrequencyGrowthRate(float dif)
  {
      if (frequencyGrowthRate + dif <= 0)
      {
         println("Error: invalid amplitude decay");
         return;
      }
      frequencyGrowthRate += dif;
      println(String.format("Modified frequencyGrowthRate: %.2f", frequencyGrowthRate));
      updateNoise();  
  }
  
  public void changeTerrainMode()
  {
    colorMode = (colorMode + 1)%3;
    updateNoise();
    
    switch(colorMode)
    {
      case 0:
        println("Terrain Mode: Display Noise");
        break;
      case 1:
        println("Terrain Mode: Caves");
        break;
      case 2:
        println("Terrain Mode: Lakes");
        break;
    }
    
  }
  
  
}
