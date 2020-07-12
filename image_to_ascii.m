## character_array = image_to_ascii (image_, characters_per_line)
## character_array = image_to_ascii (image_file_name, characters_per_line)
## character_array = image_to_ascii (..., block_size_scalar)
## character_array = image_to_ascii (..., [block_height, block_width])
## character_array = image_to_ascii (..., property, value, ...)
##
## Convert image to ASCII art character array.
##
## The algorithm is thus:
## ----------------------------------------------------------------
## 0. Import image
## ----------------------------------------------------------------
##   a) If an image file name is supplied, read the image.
##   b) Convert the image to greyscale.
## ----------------------------------------------------------------
## 1. Process glyphs and build data set
## ----------------------------------------------------------------
##   a) Import the glyphs image file.
##   b) Compute the glyph aspect ratio.
##   c) Subdivide the glyphs image file into a cell array,
##        with one glyph per subimage.
##   d) Resize each glyph subimage to the given block size.
##   e) Build a data set matrix whose rows are flattened glyph subimages.
## ----------------------------------------------------------------
## 2. Resize image into array of blocks
## ----------------------------------------------------------------
##   a) Compute the size of the ASCII art character array
##      for the given character per line and glyph aspect ratio.
##   b) Compute the size of the resized image,
##      which is the size of the image formed by replacing each character
##      of the character array with a block of the given block size.
##   c) Resize the image.
##   d) Subdivide the resized image into an array of blocks,
##      with the array being the size of the character array
##      and the blocks therefore being the given block size.
## ----------------------------------------------------------------
## 3. Select best characters
## ----------------------------------------------------------------
##   a) For each block in the array of blocks,
##      flatten the block and find the index of the nearest neighbour
##      in the glyph data set.
##   b) Convert the glyph index to its corresponding code point.
##      Thus build an array of code points.
##   c) Convert the code point array to a character array.
## ----------------------------------------------------------------
## 4. Write to file (if specified)
## ----------------------------------------------------------------
##   a) Convert the character array to a string.
##   b) Fill the appropriate template.
##   c) Write to file.
##
## Available properties (default value):
## "glyphs" ("resources/dejavu_sans_mono_glyphs.png")
##   Image file containing glyphs for the 95 printable ASCII characters
##   U+0020 SPACE through U+007E Tilde, arranged in a row from left to right.
## "method" ("cubic")
##   Method for image-resizing interpolation. See image_resize.m.
## "output" ("")
##   File name to write ASCII art to. If non-empty, must be *.html or *.txt.
## "p" (2)
##   Parameter for p-norm. See nearest_neighbour.m.

function character_array = image_to_ascii (varargin)
  
  character_array = [];
  
endfunction
