## nit = matrix_to_nit (matrix, threshold)
##
## Convert matrix to 9-bit representation, called "nit":
## 1. Subdivide matrix into 3-by-3 blocks
## 2. Compute whether average intensity of each block exceeds threshold
## 3. Recast resulting boolean values as bits in a bit vector
## 4. Convert bit vector to integer.
## A nit is a crappy approximation of the "shape" of an image.

function nit = matrix_to_nit (matrix, threshold)
  
  NIT_SIZE_LINEAR = 3;
  NIT_SIZE = NIT_SIZE_LINEAR ^ 2;
  
  [matrix_rows, matrix_columns] = size (matrix);
  matrix_aspect_ratio = matrix_rows / matrix_columns;
  
  block_array = ...
    matrix_to_block_array(matrix, NIT_SIZE_LINEAR, matrix_aspect_ratio);
  
  bit_vector = zeros (1, NIT_SIZE);
  
  for i = 1 : NIT_SIZE
    
    block = block_array{i};
    
    average_intensity = matrix_to_average_intensity(block);
    
    bit_vector(i) = average_intensity > threshold;
    
  endfor
  
  nit = bit_vector_to_integer (bit_vector);
  
endfunction
