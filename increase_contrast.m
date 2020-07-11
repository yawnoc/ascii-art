## new_image = increase_contrast (image_)
##
## Increase the contrast of an image, using smoothstep of order 2.
##   S_2 (x) = 6 x^5 - 15 x^4 + 10 x^3
## See <https://en.wikipedia.org/wiki/Smoothstep>.
## Assumes intensities are in the natural range [0, 1].

function new_image = increase_contrast (image_)
  
  new_image = polyval ([6, -15, 10, 0, 0, 0], image_);
  
endfunction
