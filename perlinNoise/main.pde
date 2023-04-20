final Float FREQUENCY = 0.03;

ArrayList<Integer> permutation;

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  permutation = createPermutation();

  for(int y = 0; y < height; y++)
  {
     for(int x = 0; x < width; x++)
     {
       
        float n = octaveNoise(x, y, 8, 1.0, 0.005); 
         n += 1.0;
         n /= 2.0;
         
         color pixelColor;
         
         float c = Math.round(255*n);
         pixelColor = color(c,c,c);
         
         pixels[x + y*width] = pixelColor;
         
       
     }
    
  }
  updatePixels();
}

public void generateNoise(Float samplingFrequency, Float amplitude)
{
  for(int y = 0; y < height; y++)
  {
     for(int x = 0; x < width; x++)
     {
       
        float n = Noise2d(x*samplingFrequency, y*samplingFrequency, permutation); 
         n += 1.0;
         n /= 2.0;
         
         float c = Math.round(255*n);
         color greyscale = color(c,c,c);
         
         pixels[x + y*width] = greyscale;
         
     }
    
  }
  updatePixels(); 
}

public Float octaveNoise(int x, int y, int numOctaves, Float amplitude, Float frequency)
{
  Float result = 0.0;
  for(int octave = 0; octave < numOctaves; octave++)
  {
     float n = amplitude * Noise2d(x * frequency, y * frequency, permutation);
     result += n;
     
     amplitude *= 0.5;
     frequency *= 2.0;
  }
  
  return result;
}
