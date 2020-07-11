## ascii_art = image_file_to_ascii_art (
##   file_name, characters_per_line, property, value, ...
## )
## Load image from file and convert to ASCII art.
## Returns ASCII art character array.
## The following properties may be set:
## * "output" (default: "")
##   Name of output file.
##   If empty, ASCII art is not written to output file.
##   If non-empty, must be *.html or *.txt.

function ascii_art = image_file_to_ascii_art (
  file_name, characters_per_line, varargin
)
  MESSAGE_PREFIX = "image_file_to_ascii_art: ";
  
  DEFAULT_PROPERTIES = {
    "output", "", ...
  };
  
  [~, output_file_name] = ...
    parseparams (varargin, DEFAULT_PROPERTIES{:});
  
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
  
  PRINTABLE_ASCII_CODE_POINT_FIRST = 0x0020;
  
  GLYPH_ASPECT_RATIO = 2;
  
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
    "glyphs/precomputed_average_intensities.txt";
  GLYPH_AVERAGE_INTENSITIES_TABLE = ...
    dlmread (PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE);
  
  SORTED_CODE_POINTS_VECTOR = GLYPH_AVERAGE_INTENSITIES_TABLE(:,1);
  GLYPH_AVERAGE_INTENSITIES_VECTOR = GLYPH_AVERAGE_INTENSITIES_TABLE(:,2);
  
  greyscale_matrix = image_read_greyscale (file_name);
  greyscale_matrix = increase_contrast (greyscale_matrix);
  
  characters_per_line = floor (characters_per_line); 
  
  block_array = matrix_to_block_array (
    greyscale_matrix,
    characters_per_line,
    GLYPH_ASPECT_RATIO
  );
  
  ascii_art = zeros (size (block_array));
  
  for i = 1 : numel (block_array)
    
    block = block_array{i};
    
    block_average_intensity = matrix_to_average_intensity (block);
    
    average_intensity_index = ...
      lookup (GLYPH_AVERAGE_INTENSITIES_VECTOR, block_average_intensity);
    
    best_code_point = SORTED_CODE_POINTS_VECTOR(average_intensity_index);
    
    ascii_art(i) = best_code_point;
    
  endfor
  
  ascii_art = char (ascii_art);
  
  if !strcmp (output_type, "none")
    
    ascii_art_string = character_array_to_string (ascii_art);
    
  endif
  
  switch (output_type)
    
    case "html"
      
      ascii_art_string = escape_html_syntax_characters (ascii_art_string);
      
      output_template_html = fileread (OUTPUT_TEMPLATE_HTML_FILE);
      title_string = escape_html_syntax_characters (file_name);
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, output_template_html, title_string, ascii_art_string);
      fclose (file_id);
    
    case "txt"
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, "%s", ascii_art_string);
      fclose (file_id);
    
  endswitch
  
endfunction
