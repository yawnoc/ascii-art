## distance = nit_distance (nit_a, nit_b)
##
## Compute distance between two nits,
## which is the Hamming distance between the corresponding 9-bit strings.

function distance = nit_distance (nit_a, nit_b)
  
  NIT_SIZE = 9;
  
  bit_discrepancies = bitxor (nit_a, nit_b);
  bit_discrepancies_vector = bitget (bit_discrepancies, NIT_SIZE : -1 : 1);
  
  distance = sum (bit_discrepancies_vector);
  
endfunction
