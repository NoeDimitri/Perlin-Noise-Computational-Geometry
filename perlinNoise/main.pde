Perlin perlinObj;

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  perlinObj = new Perlin();
  perlinObj.updateNoise();

}

void draw() {}


void keyTyped()
{
  
  if (key == 'r')
  {
    perlinObj.regeneratePermutation();
  }
  
}
