## new_image = image_resize (old_image, [new_height, new_width], method)
##
## Resize greyscale image using interpolation.
## Default method is "cubic", usually called 'bicubic'.
##
## Available methods are those for the built-in interp2.

function new_image = image_resize (old_image, new_size, method = "cubic")
  
  [old_height, old_width] = size (old_image);
  
  new_height = new_size(1);
  new_width = new_size(2);
  
  new_x_coordinates = linspace (1, old_width, new_width);
  new_y_coordinates = linspace (1, old_height, new_height);
  
  [new_x_grid, new_y_grid] = meshgrid (new_x_coordinates, new_y_coordinates);
  
  new_image = interp2 (old_image, new_x_grid, new_y_grid, method);
  
endfunction
