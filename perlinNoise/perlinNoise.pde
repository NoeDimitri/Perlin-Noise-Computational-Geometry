import java.util.*;
import java.lang.Math;

final Integer PERMUTATION_SIZE = 255;

//public interface colorInterface{
 
//  color selectColor(int value);
  
//}

public class Perlin
{
  private ArrayList<Integer> permutation;
  private Float amplitude;
  private Float frequency;
  private int numOctaves;
  private float amplitudeDecayRate;
  private float frequencyGrowthRate;
  private int colorMode;
  
  Perlin()
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
    
  }
  
  Perlin(float frequencyBase, float amplitudeBase, int numOctavesBase)
  {
      permutation = createPermutation();
      
      // Default values
      frequency = frequencyBase;
      amplitude =  amplitudeBase;
      numOctaves = numOctavesBase;
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
  public Float octaveNoise(int x, int y, float amplitude, float frequency)
  {
    Float result = 0.0;
    for(int octave = 0; octave < numOctaves; octave++)
    {
       float n = amplitude * Noise2d(x * frequency, y * frequency);
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
    updateNoise();
  }
  
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
