## greyscale_matrix = image_file_to_greyscale_matrix (file_name)
##
## Load image from file and convert to greyscale matrix of intensities.

function greyscale_matrix = image_file_to_greyscale_matrix (file_name)
  
  image_ = imread (file_name);
  
  try
    greyscale_matrix = rgb2gray (image_);
  catch
    greyscale_matrix = image_;
  end_try_catch
  
endfunction
