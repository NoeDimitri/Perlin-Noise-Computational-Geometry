import java.util.*;
import java.lang.Math;

final Integer PERMUTATION_SIZE = 255;

//public interface colorInterface{
 
//  color selectColor(int value);
  
//}

public class Noise
{
  private ArrayList<Integer> permutation;
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
    switch(v % 2)
    {
      case 0:
        return new PVector(-1.0, 0);
      case 1:
        return new PVector(1.0, 0);
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
  public float Noise1d(float x)
  { 
    // For determining which cell we are in
    int X = (int)Math.floor(x) % PERMUTATION_SIZE;
    
    // Offset
    float xf = (float)(x-Math.floor(x));
    
    PVector topRight = new PVector(xf-1.0, 0);
    PVector topLeft = new PVector(xf, 0);
    
    Integer valueRight = permutation.get(permutation.get(X+1)+Y+1);
    Integer valueLeft = permutation.get(permutation.get(X)+Y+1);
    
    float dotRight = topRight.dot(getConstantVector(valueRight));
    float dotLeft = topLeft.dot(getConstantVector(valueLeft));
    
    float u = Fade(xf);
    
    return lerp(
      dotLeft,
      dotRight,
      u
    );
  }

  // Generates Noise up to a certain octave
  public Float octaveNoise(int x, float amplitude, float frequency)
  {
    Float result = 0.0;
    for(int octave = 0; octave < numOctaves; octave++)
    {
       float n = amplitude * Noise1d(x * frequency);
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

  // Call this when you want to draw the noise to the screen
  public void updateNoise()
  {
    background(255);
    for(int x = 0; x < width; x++)
    {

         
        float n = octaveNoise(x,amplitude, frequency); 
         n += 1.0;
         n *= 0.5;
         
         color pixelColor = selectColor(n);
         
         pixels[x + ((int)Math.floor(height/2.0 - (n*height/2.0)) + 5)*width] = pixelColor;

      
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
    updateNoise();
  }
  
  // Yoinked this code off the internet heheh
  public void testRuntime()
  {
      long startTimeNanoSecond = System.nanoTime();
      long startTimeMilliSecond = System.currentTimeMillis();
      updateNoise();
      long endTimeNanoSecond = System.nanoTime();
      long endTimeMilliSecond = System.currentTimeMillis();
      System.out.println("Time Taken in "+(endTimeNanoSecond - startTimeNanoSecond) + " ns");
      System.out.println("Time Taken in "+(endTimeMilliSecond - startTimeMilliSecond) + " ms");
  }
  
  // The Code below are simple different setter functions :D
  
  // setter method for changing the octave
  public void modifyOctave(int dif)
  {
      // add dif and make sure it's at least 1
      perlinObj.numOctaves = max(numOctaves + dif, 1);
      println("Modified number of octaves: " + numOctaves);
      perlinObj.updateNoise();  
  }
  
  public void modifyFrequency(float dif)
  {
      
      if (perlinObj.frequency + dif <= 0)
      {
         println("Error: Negative frequency");
         return;
      }
      frequency += dif;
      println(String.format("Modified frequency: %.3f", frequency));
      perlinObj.updateNoise();  
  }
  
  public void modifyAmplitude(float dif)
  {
      perlinObj.amplitude += dif;
      println("Modified amplitude: " + amplitude);
      perlinObj.updateNoise();  
  }
  
  public void modifyAmplitudeDecay(float dif)
  {
      if (perlinObj.amplitudeDecayRate + dif <= 0)
      {
         println("Error: invalid amplitude decay");
         return;
      }
      perlinObj.amplitudeDecayRate += dif;
      println(String.format("Modified amplitudeDecayRate: %.2f", amplitudeDecayRate));
      perlinObj.updateNoise();  
  }
  
  public void modifyfrequencyGrowthRate(float dif)
  {
      if (perlinObj.frequencyGrowthRate + dif <= 0)
      {
         println("Error: invalid amplitude decay");
         return;
      }
      perlinObj.frequencyGrowthRate += dif;
      println(String.format("Modified frequencyGrowthRate: %.2f", frequencyGrowthRate));
      perlinObj.updateNoise();  
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
