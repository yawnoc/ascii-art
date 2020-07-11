## image_ = image_read_greyscale (file_name)
##
## Read an image from file to a matrix of greyscale intensities.
## Natural range [0, 1] is used.
## Assumes the read image is either RGB (for which rgb2gray will work)
## or already greyscale (for which rgb2gray will raise an error).

function image_ = image_read_greyscale (file_name)
  
  image_ = imread (file_name);
  image_ = im2double (image_);
  
  try
    image_ = rgb2gray (image_);
  catch
    image_ = image_;
  end_try_catch
  
endfunction
