Perlin perlinObj;
int modifyMode;

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  perlinObj = new Perlin();
  perlinObj.updateNoise();

  modifyMode = 1;
}

void draw() {}

// This is for modifying parameters of your shapes :D
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
    
  }
  
  
}
