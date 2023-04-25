Noise perlinObj;
Noise valueObj;
int modifyMode;
boolean perlinOn;

// Defaults for the noise objects
Float amplitudeDefault = .005;
Float frequencyDefault = 2.0;
int numOctavesDefault = 1;
float amplitudeDecayRateDefault = 0.5;
float frequencyGrowthRateDefault = 2.0;
int colorModeDefault = 0; // 0 = basic noise, 1 = caves, 2 = lakes
int noiseTypeDefault = 0; // 0 = Perlin noise, 1 = Value noise

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  perlinObj = new Noise(amplitudeDefault, frequencyDefault, numOctavesDefault, amplitudeDecayRateDefault, frequencyGrowthRateDefault, colorModeDefault, 0);
  valueObj = new Noise(amplitudeDefault, frequencyDefault, numOctavesDefault, amplitudeDecayRateDefault, frequencyGrowthRateDefault, colorModeDefault, 1);
  
  perlinObj.updateNoise();

  modifyMode = 1;
  perlinOn = true;
}

void draw() {}

/* The below is for modifying parameters of the noise :D
 *
 * Keybinds:
 *  'r' = Regenerate permutation (will shuffle the noise pattern)
 *  'q' = Toggles the modification mode (between adding and subtracting)
 *  'u' = Modifies # of octaves
 *  'i' = Modifies frequency
 *  'o' = Modifies amplitude
 *  'p' = Modifies amplitude decay rate
 *  '[' = Modifies frequency growth rate
 *  SPACE = Toggles the display color mode (basic noise, caves, lakes)
 *  'z' = Prints the runtime to console for generating the noise
 *  't' = Toggles between using the Perlin Noise and Value Noise
 */
void keyTyped()
{
  switch(key)
  {
    case 'r':
      if (perlinOn) {  
        perlinObj.regeneratePermutation();
      }
      else valueObj.regeneratePermutation();
      break;
    case 'q':
      modifyMode *= -1;
      switch(modifyMode)
      {
        case 1:
          println("Mode modified: Adding");
          break;
        case -1:
          println("Mode modified: Subtracting");
          break;
      }
      break;
    case 'u':
      if (perlinOn) perlinObj.modifyOctave(1*modifyMode);
      else valueObj.modifyOctave(1*modifyMode);
      break;
    case 'i':
      if (perlinOn) perlinObj.modifyFrequency(0.001*modifyMode);
      else valueObj.modifyFrequency(0.001*modifyMode);
      break; 
    case 'o':
      if (perlinOn) perlinObj.modifyAmplitude(1.0*modifyMode);
      else valueObj.modifyAmplitude(1.0*modifyMode);
      break; 
    case 'p':
      if (perlinOn) perlinObj.modifyAmplitudeDecay(0.1*modifyMode);
      else valueObj.modifyAmplitudeDecay(0.1*modifyMode);
      break; 
    case '[':
      if (perlinOn) perlinObj.modifyfrequencyGrowthRate(0.1*modifyMode);
      else valueObj.modifyfrequencyGrowthRate(0.1*modifyMode);
      break; 
    case ' ':
      if (perlinOn) perlinObj.changeTerrainMode();
      else valueObj.changeTerrainMode();
      break;
    case 'z':
      if (perlinOn) perlinObj.testRuntime();
      else valueObj.testRuntime();
      break;
    case 't':
      if (perlinOn) {
        perlinOn = false;
        valueObj.updateNoise();
        println("Switching to value noise.");
      }
      else {
        perlinOn = true;
        perlinObj.updateNoise();
        println("Switching to Perlin noise.");
      }
      break;
    case 'g':
      for(int y = 0; y < height; y++) {
       for(int x = 0; x < width; x++) {
         float n = OpenSimplex2S.noise2(32205, x, y); 
         n += 1.0;
         n *= 0.5;
         color pixelColor = color(Math.round(255*n));  
         pixels[x + y*width] = pixelColor;
       }
      }
      updatePixels();
      break;
    
  }
  
  
}
