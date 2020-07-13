## character_array = image_to_ascii (image_, characters_per_line)
## character_array = image_to_ascii (image_file_name, characters_per_line)
## character_array = image_to_ascii (..., block_size_scalar)
## character_array = image_to_ascii (..., [block_height, block_width])
## character_array = image_to_ascii (..., property, value, ...)
##
## Convert image to ASCII art character array.
## Default block size specification is [5, 3].
##
## Available properties (default value):
## "glyphs" ("resources/dejavu_sans_mono_glyphs.png")
##   Image file containing glyphs for the 95 printable ASCII characters
##   U+0020 SPACE through U+007E TILDE, arranged in a row from left to right.
## "m" (1.6)
##   Parameter for increasing contrast. See image_increase_contrast.m.
## "method" ("cubic")
##   Method for image-resizing interpolation. See image_resize.m.
## "output" ("")
##   File name to write ASCII art to. If non-empty, must be *.html or *.txt.
## "p" (1.3)
##   Parameter for p-norm. See nearest_neighbour.m.
##
## The algorithm is thus:
## ----------------------------------------------------------------
## 0. Preprocess image
## ----------------------------------------------------------------
## (a) Convert the image to greyscale.
## (b) Increase the contrast of the image.
## ----------------------------------------------------------------
## 1. Process glyphs and build data set
## ----------------------------------------------------------------
## (a) Import the glyphs image file.
## (b) Compute the glyph aspect ratio.
## (c) Subdivide the glyphs image file into a cell array,
##     with one glyph per subimage.
## (d) Compute the average intensity of each glyph subimage.
## (e) Resize each glyph subimage to the given block size.
## (f) Build a data set matrix whose rows are the
##     flattened resized glyph subimages.
## (g) Normalise the glyph average intensities in (d) to the range [0, 1].
## (h) Adjust the data set so that its average intensities (row averages)
##     are close to the normalised glyph average intensities in (g).
## ----------------------------------------------------------------
## 2. Resize image and subdivide into array of blocks
## ----------------------------------------------------------------
## (a) Compute the size of the ASCII art character array
##     for the given characters per line and glyph aspect ratio.
## (b) Compute the size of the resized image,
##     which is the size of the image formed by replacing each character
##     of the character array with a block of the given block size.
## (c) Resize the image.
## (d) Subdivide the resized image into an array of blocks,
##     with the array being the size of the character array
##     and the blocks therefore being the given block size.
## ----------------------------------------------------------------
## 3. Select best characters
## ----------------------------------------------------------------
## (a) For each block in the array of blocks,
##     flatten the block and find the index of the nearest neighbour
##     in the glyph data set.
## (b) Convert the glyph index to its corresponding code point.
##     Thus build an array of code points.
## (c) Convert the code point array to a character array.
## ----------------------------------------------------------------
## 4. Write to file (if specified)
## ----------------------------------------------------------------
## (a) Convert the character array to a string.
## (b) Fill the appropriate template.
## (c) Write to file.

function character_array = ...
  image_to_ascii (image_spec, characters_per_line, varargin)
  
  ## ----------------------------------------------------------------
  ## -2. Constants
  ## ----------------------------------------------------------------
  
  CODE_POINT_FIRST = 0x0020;
  CODE_POINT_LAST = 0x007E;
  CODE_POINTS = CODE_POINT_FIRST : CODE_POINT_LAST;
  CODE_POINT_COUNT = numel (CODE_POINTS);
  
  ## ----------------------------------------------------------------
  ## -1. Process arguments
  ## ----------------------------------------------------------------
  
  BLOCK_SIZE_SPEC_DEFAULT = [5, 3];
  
  PROPERTY_DEFAULTS = {
    "glyphs", "resources/dejavu_sans_mono_glyphs.png", ...
    "m", 1.6, ...
    "method", "cubic", ...
    "output", "", ...
    "p", 1.3, ...
  };
  
  [regular_optional_arguments, ...
    glyphs_image_file_name, ...
    contrast_m, ...
    resizing_method, ...
    output_file_name, ...
    norm_p, ...
  ] ...
    = parseparams (varargin, PROPERTY_DEFAULTS{:});
  
  if ischar (image_spec)
    image_ = imread (image_spec);
  else
    image_ = image_spec;
  endif
  
  if numel (regular_optional_arguments) > 0
    block_size_spec = regular_optional_arguments{1};
  else
    block_size_spec = BLOCK_SIZE_SPEC_DEFAULT;
  endif
  if isscalar (block_size_spec)
    block_height = block_width = block_size_spec;
  else
    block_height = block_size_spec (1);
    block_width = block_size_spec (2);
  endif
  
  if (strcmp (output_file_name, ""))
    output_type = "none";
  elseif (! isempty (regexp (output_file_name, "\.html$")))
    output_type = "html";
  elseif (! isempty (regexp (output_file_name, "\.txt$")))
    output_type = "txt";
  else
    error_message = format_message ("\"output\" must be *.html or *.txt");
    error (error_message);
  endif
  
  ## ----------------------------------------------------------------
  ## 0. Preprocess image
  ## ----------------------------------------------------------------
  
  image_ = image_to_greyscale (image_);
  image_ = image_increase_contrast (image_, contrast_m);
  
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
        "Glyph image width %i is not divisible by %i, " ...
        "the number of characters from U+0020 SPACE to U+007E TILDE." ...
      ],
      glyphs_image_width,
      CODE_POINT_COUNT
    );
    error_message = format_message (error_message);
    error (error_message);
  endif
  
  glyph_height = rows (glyphs_image);
  glyph_width = glyphs_image_width / CODE_POINT_COUNT;
  glyph_aspect_ratio = glyph_height / glyph_width;
  
  glyphs_array = image_subdivide (glyphs_image, [1, CODE_POINT_COUNT]);
  
  glyph_average_intensities = zeros (CODE_POINT_COUNT, 1);
  
  block_flattened_length = block_height * block_width;
  glyph_data_set = zeros (CODE_POINT_COUNT, block_flattened_length);
  
  for i = 1 : CODE_POINT_COUNT
    glyph = glyphs_array{i};
    glyph_average_intensities(i) = mean (glyph(:));
    glyph = image_resize (glyph, [block_height, block_width], resizing_method);
    flattened_glyph = glyph(:)';
    glyph_data_set(i,:) = flattened_glyph;
  endfor
  
  min_average_intensity = min (glyph_average_intensities);
  max_average_intensity = max (glyph_average_intensities);
  normalised_glyph_average_intensities = (
    (glyph_average_intensities - min_average_intensity)
      / (max_average_intensity - min_average_intensity)
  );
  
  glyph_data_set_average_intensities = mean (glyph_data_set, 2);
  
  average_intensity_adjustments = ...
    normalised_glyph_average_intensities - glyph_data_set_average_intensities;
  
  glyph_data_set += average_intensity_adjustments;
  
  glyph_data_set = max (glyph_data_set, 0);
  glyph_data_set = min (glyph_data_set, 1);
  
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
  
  resized_image = image_resize (image_, resized_image_size, resizing_method);
  
  blocks_array = image_subdivide (resized_image, character_array_size);
  
  ## ----------------------------------------------------------------
  ## 3. Select best characters
  ## ----------------------------------------------------------------
  
  best_glyph_index_array = zeros (character_array_size);
  
  for i = 1 : numel (blocks_array)
    
    block = blocks_array{i};
    flattened_block = block(:)';
    
    [~, ~, best_glyph_index] = ...
      nearest_neighbour (flattened_block, glyph_data_set, norm_p);
    
    best_glyph_index_array(i) = best_glyph_index;
    
  endfor
  
  code_point_array = CODE_POINTS(best_glyph_index_array);
  
  character_array = char (code_point_array);
  
  ## ----------------------------------------------------------------
  ## 4. Write to file (if specified)
  ## ----------------------------------------------------------------
  
  if strcmp (output_type, "none")
    return
  endif
  
  ascii_art_string = make_string (character_array);
  
  file_id = fopen (output_file_name, "w");
  
  switch (output_type)
    case "html"
      title_string = escape_html (output_file_name);
      ascii_art_string = escape_html (ascii_art_string);
      output_template_html = fileread ("resources/output_template.html");
      output_string = ...
        sprintf (output_template_html, title_string, ascii_art_string);
    case "txt"
      output_string = ascii_art_string;
  endswitch
  
  fprintf (file_id, "%s", output_string);
  fclose (file_id);
  
endfunction

function formatted_message = format_message (message)
  
  formatted_message = sprintf ("image_to_ascii: %s", message);
  
endfunction
