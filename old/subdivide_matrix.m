## array = subdivide_matrix (matrix, array_columns, block_aspect_ratio)
##
## Subdivide a matrix into a cell array of blocks.
## The block aspect ratio is the block height (number of rows)
## divided by the block width (number of columns).
## If the matrix cannot be subdivided evenly
## for the given number of array columns and block aspect ratio,
## excess from the bottom and the right is discarded.

function array = subdivide_matrix (matrix, array_columns, block_aspect_ratio)
  
  [matrix_rows, matrix_columns] = size (matrix);
  
  block_width = idivide (matrix_columns, array_columns);
  truncated_matrix_columns = block_width * array_columns;
  
  block_height = round (block_aspect_ratio * block_width);
  array_rows = idivide (matrix_rows, block_height);
  truncated_matrix_rows = block_height * array_rows;
  
  truncated_matrix = ...
    matrix(1:truncated_matrix_rows, 1:truncated_matrix_columns);
  
  array = mat2cell(
    truncated_matrix,
    block_height(ones (array_rows, 1)),
    block_width(ones (array_columns, 1))
  );
  
endfunction
