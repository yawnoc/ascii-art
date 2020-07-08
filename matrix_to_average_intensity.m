## average_intensity = matrix_to_average_intensity (matrix)
##
## Compute average intensity of (greyscale) matrix.

function average_intensity = matrix_to_average_intensity (matrix)
  
  average_intensity = mean (matrix(:));
  
endfunction
