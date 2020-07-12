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
## 0. Preprocess image
## ----------------------------------------------------------------
##   a) Convert the image to greyscale.
##   b) TODO: increase contrast of the image.
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
## 2. Resize image and subdivide into array of blocks
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
##   U+0020 SPACE through U+007E TILDE, arranged in a row from left to right.
## "method" ("cubic")
##   Method for image-resizing interpolation. See image_resize.m.
## "output" ("")
##   File name to write ASCII art to. If non-empty, must be *.html or *.txt.
## "p" (2)
##   Parameter for p-norm. See nearest_neighbour.m.

function character_array = image_to_ascii (varargin)
  
  ## ----------------------------------------------------------------
  ## -2. Constants
  ## ----------------------------------------------------------------
  
  CODE_POINT_FIRST = 0x0020;
  CODE_POINT_LAST = 0x007E;
  CODE_POINTS = CODE_POINT_FIRST : CODE_POINT_LAST;
  CODE_POINT_COUNT = numel (CODE_POINTS);
  
  MESSAGE_PREFIX = "image_to_ascii: ";
  
  ## ----------------------------------------------------------------
  ## -1. Process arguments
  ## ----------------------------------------------------------------
  
  BLOCK_SIZE_SPEC_DEFAULT = 3;
  
  PROPERTY_DEFAULTS = {
    "glyphs", "resources/dejavu_sans_mono_glyphs.png", ...
    "method", "cubic", ...
    "output", "", ...
    "p", 2, ...
  };
  
  [
    regular_arguments, ...
    glyphs_image_file_name, ...
    resizing_method, ...
    output_file_name, ...
    norm_p, ...
  ] ...
    = parseparams (varargin, PROPERTY_DEFAULTS{:});
  
  regular_argument_count = numel (regular_arguments);
  
  if (regular_argument_count < 2 || regular_argument_count > 3)
    print_usage;
  endif;
  
  image_spec = regular_arguments{1};
  if ischar (image_spec)
    image_ = imread (image_spec);
  else
    image_ = image_spec;
  endif
  
  characters_per_line = regular_arguments{2};
  
  if (regular_argument_count < 3)
    block_size_spec = BLOCK_SIZE_SPEC_DEFAULT;
  else
    block_size_spec = regular_arguments{3};
  endif
  if isscalar (block_size_spec)
    block_height = block_width = block_size_spec;
  else
    block_height = block_size_spec (1);
    block_width = block_size_spec (2);
  endif
  
  block_flattened_size = block_height * block_width;
  
  ## ----------------------------------------------------------------
  ## 0. Preprocess image
  ## ----------------------------------------------------------------
  
  image_ = image_to_greyscale (image_);
  
  [image_height, image_width] = size (image_);
  
  ## ----------------------------------------------------------------
  ## 1. Process glyphs and build data set
  ## ----------------------------------------------------------------
  
  glyphs_image = imread (glyphs_image_file_name);
  glyphs_image = image_to_greyscale (glyphs_image);
  glyphs_image_width = columns (glyphs_image);
  if (mod (glyphs_image_width, CODE_POINT_COUNT) != 0)
    error_message = sprintf (
      [
        "Glyph image width is not divisible by %i, " ...
        "the number of characters from U+0020 SPACE to U+007E TILDE." ...
      ],
      CODE_POINT_COUNT
    );
    error_message = formatted_message (error_message);
    error (error_message);
  endif
  
  glyph_height = rows (glyphs_image);
  glyph_width = glyphs_image_width / CODE_POINT_COUNT;
  glyph_aspect_ratio = glyph_height / glyph_width;
  
  glyphs_array = image_subdivide (glyphs_image, [1, CODE_POINT_COUNT]);
  
  glyph_data_set = zeros (CODE_POINT_COUNT, block_flattened_size);
  for i = 1 : CODE_POINT_COUNT
    glyph = glyphs_array{i};
    glyph = image_resize (glyph, [block_height, block_width]);
    flattened_glyph = glyph(:)';
    glyph_data_set(i,:) = flattened_glyph;
  endfor
  
  ## ----------------------------------------------------------------
  ## 2. Resize image and subdivide into array of blocks
  ## ----------------------------------------------------------------
  
  character_array_columns = characters_per_line;
  character_cell_width = image_width / character_array_columns;
  character_cell_height = character_cell_width * glyph_aspect_ratio;
  character_array_rows = ceil (image_height / character_cell_height);
  character_array_size = [character_array_rows, character_array_columns];
  
  resized_image_height = character_array_rows * block_height;
  resized_image_width = character_array_columns * block_width;
  resized_image_size = [resized_image_height, resized_image_width];
  
  resized_image = image_resize (image_, resized_image_size);
  
  blocks_array = image_subdivide (resized_image, character_array_size);
  
  ## ----------------------------------------------------------------
  ## Infinity
  ## ----------------------------------------------------------------
  
  character_array = [];
  
endfunction

function formatted_message = format_message (message)
  
  formatted_message = sprintf ("image_to_ascii: %s", message);
  
endfunction
