## array = image_subdivide (image_, [array_rows, array_columns])
##
## Subdivide image into cell array of equally-sized blocks.
##
## If the image cannot be subdivided evenly
## for the given number of resultant array rows and array columns,
## excess from the bottom and the right is discarded.

function array = image_subdivide (image_, array_size)
  
  [image_height, image_width] = size (image_);
  
  array_rows = array_size(1);
  array_columns = array_size(2);
  
  block_height = idivide (image_height, array_rows);
  block_width = idivide (image_width, array_columns);
  
  truncated_image_height = block_height * array_rows;
  truncated_image_width = block_width * array_columns;
  truncated_image = image_(1:truncated_image_height, 1:truncated_image_width);
  
  array = mat2cell(
    truncated_image,
    block_height(ones (array_rows, 1)),
    block_width(ones (array_columns, 1))
  );
  
endfunction
