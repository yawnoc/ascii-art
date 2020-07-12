## new_image = image_increase_contrast (old_image, m)
##
## Increase image contrast using hyperbolic tangent transformation.
##
## Specifically, the old and new intensities x and y are related by
##   y = 1/2 + tanh ((2x - 1) m) / (2 tanh (m)),
## which fixes the intensities 0, 1/2, and 1.
## The slope at x = 1/2 is m / tanh (m), an increasing function of m,
## which is 1 at m = 0, and m when m is infinite.

function new_image = image_increase_contrast (old_image, m)
  
  if m == 0
    
    new_image = old_image;
    
  else
    
    transformation = @(x) 1/2 + tanh ((2*x - 1) * m) / (2 * tanh (m));
    new_image = transformation (old_image);
    
  endif
  
endfunction
