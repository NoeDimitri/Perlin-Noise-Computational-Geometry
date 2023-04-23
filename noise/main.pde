Noise perlinObj;
Noise valueObj;
int modifyMode;

// Defaults for the noise objects
Float amplitudeDefault = .005;
Float frequencyDefault = 2.0;
int numOctavesDefault = 3;
float amplitudeDecayRateDefault = 0.5;
float frequencyGrowthRateDefault = 2.0;
int colorModeDefault = 2; // 0 = basic noise, 1 = caves, 2 = lakes
int noiseTypeDefault = 0; // 0 = Perlin noise, 1 = Value noise

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  //perlinObj = new Noise();
  perlinObj = new Noise(amplitudeDefault, frequencyDefault, numOctavesDefault, amplitudeDecayRateDefault, frequencyGrowthRateDefault, colorModeDefault, 0);
  valueObj = new Noise(amplitudeDefault, frequencyDefault, numOctavesDefault, amplitudeDecayRateDefault, frequencyGrowthRateDefault, colorModeDefault, 1);
  perlinObj.updateNoise();

  modifyMode = 1;
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
 */
void keyTyped()
{
  switch(key)
  {
    case 'r':
      perlinObj.regeneratePermutation();
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
      perlinObj.modifyOctave(1*modifyMode);
      break;
    case 'i':
      perlinObj.modifyFrequency(0.001*modifyMode);
      break; 
    case 'o':
      perlinObj.modifyAmplitude(1.0*modifyMode);
      break; 
    case 'p':
      perlinObj.modifyAmplitudeDecay(0.1*modifyMode);
      break; 
    case '[':
      perlinObj.modifyfrequencyGrowthRate(0.1*modifyMode);
      break; 
    case ' ':
      perlinObj.changeTerrainMode();
      break;
    case 'z':
      perlinObj.testRuntime();
      break;
    
  }
  
  
}
