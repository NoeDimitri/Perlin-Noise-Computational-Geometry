ArrayList<Integer> permutation;

void setup()
{
  size(500,500);
  background(255);
  loadPixels();
  
  Perlin perlinObj = new Perlin();
  perlinObj.updateNoise();

}
