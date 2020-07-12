## new_image = image_to_greyscale (old_image)
##
## Convert image to double-precision greyscale.

function new_image = image_to_greyscale (old_image)
  
  new_image = im2double (old_image);
  
  try
    new_image = rgb2gray (new_image);
  catch
    # Image is not RGB, presumably already greyscale.
  end_try_catch
  
endfunction
