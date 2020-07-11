## ascii_art = image_read_to_ascii (file_name, columns_, property, value, ...)
##
## Read an image from file and convert to an ASCII art character array.
## The following properties may be set:
## - "output"
##   Name of output file, default "".
##   If empty, ASCII art is not written to an output file.
##   If non-empty, must be *.html or *.txt.

function ascii_art = image_read_to_ascii (file_name, columns_, varargin)
  
  MESSAGE_PREFIX = "image_read_to_ascii: ";
  
  ## ----------------------------------------------------------------
  ## Parse property/value pairs
  ## ----------------------------------------------------------------
  
  DEFAULT_PROPERTIES = {
    "output", "", ...
  };
  
  [~, output_file_name] = ...
    parseparams (varargin, DEFAULT_PROPERTIES{:});
  
  ## ----------------------------------------------------------------
  ## Configure output
  ## ----------------------------------------------------------------
  
  if strcmp (output_file_name, "")
    
    output_type = "none";
    
  elseif !isempty (regexp (output_file_name, "\.html$"))
    
    output_type = "html";
    
    OUTPUT_TEMPLATE_HTML_FILE = "output_template.html";
    
    if strcmp (output_file_name, OUTPUT_TEMPLATE_HTML_FILE)
      error ([MESSAGE_PREFIX, "You fool. Don't overwrite the template file!"]);
    endif
    
  elseif !isempty (regexp (output_file_name, "\.txt$"))
    
    output_type = "txt";
    
  else
    
    error ([MESSAGE_PREFIX, "\"output\" must be *.html or *.txt"]);
    
  endif
  
  ## ----------------------------------------------------------------
  ## Constants
  ## ----------------------------------------------------------------
  
  GLYPH_ASPECT_RATIO = 2;
  
  ## ----------------------------------------------------------------
  ## Load precomputed glyph average intensities
  ## ----------------------------------------------------------------
  
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
    "glyphs/precomputed_average_intensities.txt";
  GLYPH_AVERAGE_INTENSITIES_TABLE = ...
    dlmread (PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE);
  
  code_points = GLYPH_AVERAGE_INTENSITIES_TABLE(:,1);
  average_intensities = GLYPH_AVERAGE_INTENSITIES_TABLE(:,2);
  
  ## ----------------------------------------------------------------
  ## Read image and preprocess
  ## ----------------------------------------------------------------
  
  image_ = image_read_greyscale (file_name);
  image_ = increase_contrast (image_);
  
  ## ----------------------------------------------------------------
  ## Subdivide image into array of blocks
  ## ----------------------------------------------------------------
  
  columns_ = floor (columns_); 
  
  subdivided_image = subdivide_matrix (image_, columns_, GLYPH_ASPECT_RATIO);
  
  ## ----------------------------------------------------------------
  ## Select best character for each block
  ## ----------------------------------------------------------------
  
  ascii_art_code_points = zeros (size (subdivided_image));
  
  for i = 1 : numel (subdivided_image)
    
    block = subdivided_image{i};
    
    block_average_intensity = matrix_average (block);
    
    average_intensity_index = ...
      lookup (average_intensities, block_average_intensity);
    
    best_code_point = code_points(average_intensity_index);
    
    ascii_art_code_points(i) = best_code_point;
    
  endfor
  
  ## ----------------------------------------------------------------
  ## Return
  ## ----------------------------------------------------------------
  
  ascii_art = char (ascii_art_code_points);
  
  ## ----------------------------------------------------------------
  ## Export
  ## ----------------------------------------------------------------
  
  if !strcmp (output_type, "none")
    
    ascii_art_string = make_string (ascii_art);
    
  endif
  
  switch (output_type)
    
    case "html"
      
      ascii_art_string = escape_html (ascii_art_string);
      
      output_template_html = fileread (OUTPUT_TEMPLATE_HTML_FILE);
      title_string = escape_html (file_name);
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, output_template_html, title_string, ascii_art_string);
      fclose (file_id);
    
    case "txt"
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, "%s", ascii_art_string);
      fclose (file_id);
    
  endswitch
  
endfunction
