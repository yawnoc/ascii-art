## greyscale_matrix = image_file_to_greyscale_matrix (file_name)
##
## Load image from file and convert to greyscale matrix of intensities.
## Natural range [0, 1] is used.
## Assumes the loaded image is either RGB (for which rgb2gray will work)
## or already greyscale (for which rgb2gray will raise an error).

function greyscale_matrix = image_file_to_greyscale_matrix (file_name)
  
  image_ = imread (file_name);
  image_ = im2double (image_);
  
  try
    greyscale_matrix = rgb2gray (image_);
  catch
    greyscale_matrix = image_;
  end_try_catch
  
endfunction
