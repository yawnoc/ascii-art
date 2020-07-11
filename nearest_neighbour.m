## [nearest_, distance, index_] = nearest_neighbour (point, data)
## [nearest_, distance, index_] = nearest_neighbour (..., p)
##
## Find nearest neighbour to point among data by p-norm.
## Default p is 2 (Euclidean norm).
##
## The query point is to be a row vector,
## and the data set is to be a matrix of rows with the same number of columns.

function [nearest_, distance, index_] = nearest_neighbour (point, data, p = 2)
  
  displacements = data - point;
  distances = norm (displacements, p, "rows");
  
  [distance, index_] = min (distances);
  nearest_ = data(index_,:);
  
endfunction
