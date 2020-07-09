## integer = bit_vector_to_integer (bit_vector)
##
## Convert vector of bits to integer.
## First bit is most significant.
## (Built-in bin2dec requires string input.)

function integer = bit_vector_to_integer (bit_vector)
  
  highest_exponent = numel (bit_vector) - 1;
  
  powers_of_2 = 2 .^ (highest_exponent : -1 : 0);
  
  integer = sum (bit_vector .* powers_of_2);
  
endfunction
