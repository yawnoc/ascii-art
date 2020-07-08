## block_array = matrix_to_block_array (
##   matrix, array_columns, block_aspect_ratio
## )
##
## Subdivide matrix into cell array of blocks.
## Block aspect ratio is block rows (height) divided by block columns (width).
## If the matrix cannot be subdivided evenly,
## excess from the bottom and the right is discarded.

function block_array = matrix_to_block_array (
  matrix, array_columns, block_aspect_ratio
)
  
  [matrix_rows, matrix_columns] = size (matrix);
  
  block_columns = idivide (matrix_columns, array_columns);
  truncated_matrix_columns = block_columns * array_columns;
  
  block_rows = round (block_aspect_ratio * block_columns);
  array_rows = idivide (matrix_rows, block_rows);
  truncated_matrix_rows = block_rows * array_rows;
  
  truncated_matrix = ...
    matrix(1:truncated_matrix_rows, 1:truncated_matrix_columns);
  
  block_rows_list = block_rows(ones (array_rows, 1));
  block_columns_list = block_columns(ones (array_columns, 1));
  
  block_array = ...
    mat2cell (truncated_matrix, block_rows_list, block_columns_list);
  
endfunction
