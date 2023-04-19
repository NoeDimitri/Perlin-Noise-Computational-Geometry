import java.util.*;


// For creating and shuffling permutation 
ArrayList<Integer> permutation = new ArrayList<Integer>();

for(Integer i = 0; i < 256; i++)
{
   permutation.add(i);
}

Collections.shuffle(permutation);
